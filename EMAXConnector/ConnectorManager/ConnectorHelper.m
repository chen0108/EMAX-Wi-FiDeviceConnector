//
//  ConnectorHelper.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/16.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "ConnectorHelper.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "GCDAsyncUdpSocket.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

/*
 // ***************************************
 APP对模块操作流程
 // ***************************************
 UDP发送                         模块应答
 HF-A11ASSISTHREAD              返回设备名称+ip+mac
 +ok         +ok
 //可以开始发送下面指令（每个AT指令后面要+/r）
 AT+WMODE=APSTA                 +ok           设备工作模式
 
 AT+NETP=UDP,CLIENT,10000,47.52.149.125
 AT+WSMAC                       +ok=fd152436  获取设备MAC(建议去掉)
 AT+WSCAN                       +ok           查找AP
 AT+WSSSID=T                    +ok           写SSID
 AT+WSKEY=WPA2PSK,AES,88888888  +ok  写密码
 AT+WSLK                        +ok=T(MAC)    查寻STA连接状态
 AT+ENTM                        +ok           模块进入透传模式
 AT+Z                           +ok           重启模块
 */

static NSString * const W001Commonds[] = {
    @"LSD_WIFI",                            // 连接测试
    @"LSD_WIFI:AT+WSCAN\r\n",                // 扫描热点
    @"LSD_WIFI:AT+WSKEY=%@,%@,%@\r\n",      // 设置Wi-Fi密码 加密方式
    @"LSD_WIFI:AT+WSKEY=OPEN,NONE\r\n",     // 设置开放的Wi-Fi
    @"LSD_WIFI:AT+WSSSID=%@\r\n",           // 设置SSID
    @"LSD_WIFI:AT+WSMAC\r\n",               // 获取设备MAC
};

static NSString * const W002Commonds[] = {
    @"AT+HF-A11ASSISTHREAD\r",                   // 1 连接测试
    @"AT+WSCAN",                            // 4 扫描热点
    @"AT+WSKEY=%@,%@,%@",                   // 5 设置Wi-Fi密码 加密方式
    @"AT+WSKEY=OPEN,NONE",                  // 6 设置开放的Wi-Fi
    @"AT+WSSSID=%@",                        // 6 设置SSID
    @"AT+WSMAC",                            // * 获取设备MAC
    @"AT+WMODE=APSTA\r",                    // 2 设置设备工作模式
    @"AT+NETP=UDP,CLIENT,%@,%@",            // 3 设置设备服务端端口、地址
    @"AT+WSLK",                             // 7 查寻STA连接状态
    @"AT+ENTM",                             // 8 模块进入透传模式
    @"AT+Z",                                // 9 重启模块
};

typedef enum : NSUInteger {
    CommondIdx_Test,
    CommondIdx_Scan,
    CommondIdx_Psw,
    CommondIdx_PswOpen,
    CommondIdx_SSID,
    CommondIdx_Mac,
    CommondIdx_APMode,
    CommondIdx_Net,
    CommondIdx_WSLK,
    CommondIdx_ENTM,
    CommondIdx_Reboot,
} CommondIdx;

typedef void(^TasksBlock)(NSString *msg);

@interface ConnectorHelper() <GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@property (nonatomic, strong) NSArray *moduleCmds;

@property (nonatomic, strong) NSTimer *timeoutTimer;

@property (nonatomic, strong) NSMutableArray<NSString *> *commands;
@property (nonatomic, strong) NSMutableArray<TasksBlock> *tasks;

@end

@implementation ConnectorHelper {
    NSInteger _taskPointer;
    BOOL _receiveWiFiInfo;
}

- (NSArray *)moduleCmds {
    if (_moduleCmds == nil) {
        if (self.module == WiFiModule_W001) {
            _moduleCmds = [NSArray arrayWithObjects:W001Commonds count:6];
        } else if (self.module == WiFiModule_W002) {
            _moduleCmds = [NSArray arrayWithObjects:W002Commonds count:11];
        }
    }
    
    return _moduleCmds;
}

- (NSMutableArray *)commands {
    if (_commands == nil) {
        _commands = [NSMutableArray array];
    }
    
    return _commands;
}
- (NSMutableArray *)tasks {
    if (_tasks == nil) {
        _tasks = [NSMutableArray array];
    }
    
    return _tasks;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (instancetype)initWithHost:(NSString *)host port:(uint16_t)port module:(WiFiModule)module
{
    self = [super init];
    if (self) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _host = host;
        _port = port;
        _module = module;
    }
    return self;
}

#pragma mark -
- (ConnectorHelper *(^)(void))connectToDeviceAndBegin {
    ConnectorHelper *(^block)(void) = ^(void) {
        _taskPointer = 0;
        [self.commands removeAllObjects];
        [self.tasks removeAllObjects];
        
        [self.commands addObject:@"connectToDevice"]; // 无实际用途 表示成任务
        TasksBlock block = ^(NSString *msg){
            NSLog(@"*=*=Connected block=*=* :%@", msg);
        };
        [self.tasks addObject:block];
        
        if (_udpSocket.isConnected) {
            [self udpSocket:_udpSocket didConnectToAddress:_udpSocket.connectedAddress];
        } else {
            NSError *error = nil;
            if ([_udpSocket bindToPort:self.port error:&error] == false) {
                NSLog(@"Error bindToPort: %@", error);
                self.resultBlock(self, false, _taskPointer);
            }
            if ([_udpSocket connectToHost:self.host onPort:self.port error:&error] == false) {
                NSLog(@"Error connecting: %@", error);
                self.resultBlock(self, false, _taskPointer);
            };
        }
        return self;
    };
    
    return block;
}

- (ConnectorHelper *(^)(void))connectionTest {
    return ^ConnectorHelper *(void) {
        [self.commands addObject:self.moduleCmds[CommondIdx_Test]];
        
        TasksBlock block = [self connectionTestTasksBlockWithModule:self.module];
        [self.tasks addObject:block];
        
        return self;
    };
}
- (TasksBlock)connectionTestTasksBlockWithModule:(WiFiModule)module {
    TasksBlock block;
    if (module == WiFiModule_W001) {
        block = ^(NSString *msg){
            if ([msg hasSuffix:@"LSD_F205"]) {
                NSArray *arr = [msg componentsSeparatedByString:@","];
                self.connectionTestResult(self, [arr.firstObject uppercaseString]);
                [self nextCommond];
            }
        };
    } else if (module == WiFiModule_W002) {
        block = ^(NSString *msg){
            NSLog(@"*=*=%s=*=* :%@", __func__, msg);
        };

    }
    return block;
}

- (ConnectorHelper *(^)(void))setAPWorkMode {
    return ^ConnectorHelper *(void) {
        if (self.module == WiFiModule_W002) {
            [self.commands addObject:self.moduleCmds[CommondIdx_APMode]];
            
            TasksBlock block = ^(NSString *msg){
                NSLog(@"*=*=%s=*=* :%@", __func__, msg);
            };
            [self.tasks addObject:block];
        } else {
            NSLog(@"*=*=%s=*=* : Error module", __func__);
        }
        
        return self;
    };
}

- (ConnectorHelper *(^)(void))scanWiFi {
    ConnectorHelper *(^block)(void) = ^(void) {
        [self.commands addObject:self.moduleCmds[CommondIdx_Scan]];
        _receiveWiFiInfo = YES;
        TasksBlock block = ^(NSString *msg){
            if ([msg containsString:@"Infra     "]) {
                NSArray *infos = [msg componentsSeparatedByString:@"  \""];
                
                NSArray *temArr = [infos[1] componentsSeparatedByString:@" "];
                NSString *auth = temArr.firstObject;
                if (temArr.count >= 2) { // 判断是否是加密Wi-Fi
                    if ([auth isEqualToString:@"WPA/WPA2"]) {
                        auth = @"WPAPSK";
                    } else {
                        auth = [auth stringByAppendingString:@"PSK"];
                    }
                    NSString *encry = [temArr.lastObject stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    self.scanWiFiResult(self, infos.lastObject, auth, encry);
                } else if([auth hasPrefix:@"OPEN"]) {
                    self.scanWiFiResult(self, infos.lastObject, @"OPEN", @"NONE");
                }
            }
        };
        
        [self.tasks addObject:block];
        
        return self;
    };
    
    return block;
}

- (ConnectorHelper *(^)(NSString *psw, NSString *auth, NSString *encry))setPsw {
    ConnectorHelper *(^block)(NSString *, NSString *, NSString *) = ^(NSString *psw, NSString *auth, NSString *encry) {
        if (psw) {
            [self.commands addObject:[NSString stringWithFormat:self.moduleCmds[CommondIdx_Psw],auth, encry, psw]];
        } else {
            [self.commands addObject:self.moduleCmds[CommondIdx_PswOpen]];
        }
        TasksBlock block = ^(NSString *msg){
            _receiveWiFiInfo = NO;
            if ([msg containsString:@"+ok"]) {
                [self nextCommond];
            } else if ([msg containsString:@"+ERR=-4"]) {
                self.resultBlock(self, NO, _taskPointer);
            }
        };
        [self.tasks addObject:block];

        return self;
    };
    
    return block;

}

- (ConnectorHelper *(^)(NSString *ssid))setSSID {
    ConnectorHelper *(^block)(NSString *) = ^(NSString *ssid) {
        [self.commands addObject:[NSString stringWithFormat:self.moduleCmds[CommondIdx_SSID],ssid]];
        TasksBlock block = ^(NSString *msg){
            _receiveWiFiInfo = NO;
            if ([msg containsString:@"+ok"]) {
                [self nextCommond];
            }
        };
        [self.tasks addObject:block];
        
        return self;
    };
    
    return block;
}

- (ConnectorHelper *(^)(NSString *, NSString *))scanForSSIDAndSetPsw {
    ConnectorHelper *(^block)(NSString *, NSString *) = ^(NSString *ssid, NSString *psw) {
        self.scanWiFi();
        self.scanWiFiResult = ^(ConnectorHelper *helper, NSString *ssidT, NSString *auth, NSString *encry) {
            NSLog(@"*=*=*=*=* \n ssid: %@ \n auth: %@ \n encry: %@", ssid, auth, encry);
            if (_receiveWiFiInfo && [ssidT hasPrefix:ssid]) {
                helper.setPsw(psw, auth, encry).setSSID(@"ezdeiMac").begin();
            }
        };
        
        return self;
    };
    
    return block;
}

- (ConnectorHelper *(^)(void))getMac {
    ConnectorHelper *(^block)(void) = ^(void) {
        [self.commands addObject:self.moduleCmds[CommondIdx_Mac]];
        TasksBlock block = ^(NSString *msg){
            if ([msg containsString:@"+ok"]) {
                NSArray *arr = [msg componentsSeparatedByString:@"="];
                if (arr != nil && arr.count == 2) {
                    NSString *mac = [arr[1] substringToIndex:12];
                    self.getMacResult(self, mac);
                    [self nextCommond];
                }
            }
        };
        [self.tasks addObject:block];
        
        return self;
    };
    
    return block;
}

#pragma mark -
- (ConnectorHelper *(^)(void))begin {
    ConnectorHelper *(^block)(void) = ^(void) {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:20.f target:self selector:@selector(timeout) userInfo:nil repeats:NO];

        [self nextCommond];
        return self;
    };
    return block;
}

- (void)timeout {
    if (_taskPointer < self.commands.count - 1) {
        self.resultBlock(self, false, _taskPointer);
        [self.udpSocket close];
    }
}

- (void)nextCommond {
    self.resultBlock(self, true, _taskPointer);
    if (_taskPointer < (NSInteger)self.commands.count - 1) {
        NSString *instruction = self.commands[(_taskPointer + 1)];
        NSData *data = [instruction dataUsingEncoding:NSUTF8StringEncoding];
        [self.udpSocket sendData:data withTimeout:20 tag:(_taskPointer + 1)];
    } else {
        NSLog(@"*=*=%s=*=* :\nSucceed finnish all commond", __func__);
    }
}

#pragma mark -
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"+=+= Did connect +=+=");
    
    self.tasks[_taskPointer]([NSString stringWithFormat:@"%@", address]);
    
    NSError *error = nil;
    if ([sock receiveOnce:&error]) {
        
        self.begin();
        
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_taskPointer == 0) {
                // 失败
                weakSelf.resultBlock(self, false, _taskPointer);
                [sock close];
            }
        });
    } else {
        NSLog(@"Error receiving: %@", error);
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"+=+= Did send data with tag: +=+=\n%ld", tag);
    _taskPointer++;
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"+=+= Did not send data with tag: +=+=\n%ld dueToError:%@", tag, error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg == nil) {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        NSLog(@"+=+= Receive Unknown message from: +=+=\n%@:%hu", host, port);
        return;
    }
    
    NSLog(@"+=+= Received massage: +=+=\n%@", msg);
    
    NSError *error = nil;
    if ([sock receiveOnce:&error] && _taskPointer < self.tasks.count) {
        self.tasks[_taskPointer](msg);
    } else {
        NSLog(@"Error receiving: %@", error);
    }
}

- (void)dealloc {
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
}
#pragma mark -
// 当前 wLan ssid
+ (NSString *)currentSSID {
    NSString *ssid = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (wifiInterfaces == nil) {
        return @"Jump to Settings";
    } else {
        NSArray *ifs = (__bridge NSArray *)wifiInterfaces;
        for (NSString *ifnam in ifs) {
            CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            if (dictRef) {
                NSDictionary *info = (__bridge id)dictRef;
                
                if (info[@"SSID"]) {
                    ssid = info[@"SSID"];
                    break;
                }
                
                CFRelease(dictRef);
            }
        }
        CFRelease(wifiInterfaces);
        
        return ssid;
    }
}

- (BOOL)isConnected {
    return self.udpSocket.isConnected;
}

@end
