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
    @"LSD_WIFI:AT+WSCAN\r\n"                // 扫描热点
    @"LSD_WIFI:AT+WSKEY=%@,%@,%@\r\n",      // 设置Wi-Fi密码 加密方式
    @"LSD_WIFI:AT+WSKEY=OPEN,NONE\r\n",     // 设置开放的Wi-Fi
    @"LSD_WIFI:AT+WSSSID=%@\r\n",           // 设置SSID
    @"LSD_WIFI:AT+WSMAC\r\n",               // 获取设备MAC
};

static NSString * const W002Commonds[] = {
    @"HF-A11ASSISTHREAD",                   // 连接测试
    @"AT+WSCAN",                            // 扫描热点
    @"AT+WSKEY=%@,%@,%@",                   // 设置Wi-Fi密码 加密方式
    @"AT+WSKEY=OPEN,NONE",                  // 设置开放的Wi-Fi
    @"AT+WSSSID=%@",                        // 设置SSID
    @"AT+WSMAC",                            // 获取设备MAC
    @"AT+WMODE=APSTA"                       // 设备工作模式
    @"AT+NETP=UDP,CLIENT,%@,%@",            // 设置设备服务端端口、地址
    @"AT+WSLK",                             // 查寻STA连接状态
    @"AT+ENTM",                             // 模块进入透传模式
    @"AT+Z",                                // 重启模块
};

typedef enum : NSUInteger {
    CommondIdx_Test,
    CommondIdx_Scan,
    CommondIdx_Psw,
    CommondIdx_PswOpen,
    CommondIdx_SSID,
    CommondIdx_Mac,
    CommondIdx_Mode,
    CommondIdx_Net,
    CommondIdx_WSLK,
    CommondIdx_ENTM,
    CommondIdx_Reboot,
} CommondIdx;

typedef void(^TasksBlock)(NSString *msg);

@interface ConnectorHelper() <GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@property (nonatomic, strong) NSArray *moduleCmds;


@property (nonatomic, strong) NSMutableArray<NSString *> *commands;
@property (nonatomic, strong) NSMutableArray<TasksBlock> *tasks;

@end

@implementation ConnectorHelper {
    NSInteger _taskPointer;
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
- (ConnectorHelper *(^)(void))connectToDevice {
    ConnectorHelper *(^block)(void) = ^(void) {
        _taskPointer = -1;
        
        NSError *error = nil;
        if ([_udpSocket connectToHost:self.host onPort:self.port error:&error] == false) {
            NSLog(@"Error connecting: %@", error);
            self.resultBlock(false, _taskPointer);
        };
        
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 总超时判断
            if (_taskPointer != weakSelf.commands.count - 1) {
                self.resultBlock(false, _taskPointer);
                [weakSelf.udpSocket close];
            }
        });
        
        return self;
    };
    
    return block;
}

- (ConnectorHelper *(^)(void))connectionTest {
    [self.commands addObject:self.moduleCmds[CommondIdx_Test]];
    return ^ConnectorHelper *(void) {
        TasksBlock block = ^(NSString *msg){
            if ([msg hasSuffix:@"LSD_F205"]) {
                NSArray *arr = [msg componentsSeparatedByString:@","];
                self.connectionTestResult([arr.firstObject uppercaseString]);
                [self nextCommond];
            }
        };
        
        [self.tasks addObject:block];
        
        return self;
    };
}

- (ConnectorHelper *(^)(void))scanWiFi {
    [self.commands addObject:self.moduleCmds[CommondIdx_Scan]];
    ConnectorHelper *(^block)(void) = ^(void) {
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
//                    [infos.lastObject hasPrefix:self.ssid]
                    self.scanWiFiResult(infos.lastObject, auth, encry);
                } else if([auth hasPrefix:@"OPEN"]) {
                    self.scanWiFiResult(infos.lastObject, @"OPEN", @"NONE");
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
//            [self.commands addObject:[NSString stringWithFormat:@"LSD_WIFI:AT+WSKEY=%@,%@,%@\r\n",auth, encry, psw]];
            [self.commands addObject:[NSString stringWithFormat:self.moduleCmds[CommondIdx_Psw],auth, encry, psw]];
        } else {
            [self.commands addObject:self.moduleCmds[CommondIdx_PswOpen]];
        }
        TasksBlock block = ^(NSString *msg){
            if ([msg containsString:@"+ok"]) {
                [self nextCommond];
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
            if ([msg containsString:@"+ok"]) {
                [self nextCommond];
            }
        };
        [self.tasks addObject:block];
        
        return self;
    };
    
    return block;
}

- (ConnectorHelper *(^)(void))getMac {
    [self.commands addObject:self.moduleCmds[CommondIdx_Mac]];
    ConnectorHelper *(^block)(void) = ^(void) {
        TasksBlock block = ^(NSString *msg){
            if ([msg containsString:@"+ok"]) {
                NSArray *arr = [msg componentsSeparatedByString:@"="];
                if (arr != nil && arr.count == 2) {
                    NSString *mac = [arr[1] substringToIndex:12];
                    self.getMacResult(mac);
                    [self nextCommond];
                }
            }
        };
        [self.tasks addObject:block];
        
        return self;
    };
    
    return block;

}

- (void)nextCommond {
    if (_taskPointer < (NSInteger)self.commands.count) {
        NSString *instruction = self.commands[(_taskPointer + 1)];
        NSData *data = [instruction dataUsingEncoding:NSUTF8StringEncoding];
        [self.udpSocket sendData:data withTimeout:30 tag:(_taskPointer + 1)];
    } else {
        // Succeed finnish all commond
    }
}

#pragma mark -
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"+=+= Did connect +=+=");
    
    NSError *error = nil;
    if ([sock receiveOnce:&error]) {
        
        [self nextCommond]; // 前导指令
        
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_taskPointer == 0) {
                // 失败
                weakSelf.resultBlock(false, _taskPointer);
                [sock close];
            }
        });
    } else {
        NSLog(@"Error receiving: %@", error);
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    _taskPointer++;
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
    if ([sock receiveOnce:&error]) {
        self.tasks[_taskPointer](msg);
    } else {
        NSLog(@"Error receiving: %@", error);
    }
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
