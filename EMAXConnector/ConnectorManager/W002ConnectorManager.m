//
//  W002ConnectorManager.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/4/2.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "W002ConnectorManager.h"

static NSString * const W002Commonds[] = {
    @"HF-A11ASSISTHREAD",                   // 1 连接测试
    @"+ok",                                 // 2 确认步骤‘1’返回无误
    @"AT+NETP=UDP,CLIENT,%@,%@\r\n",        // 3 设置设备服务端端口、地址
    @"AT+WSCAN\r\n",                        // 4 扫描热点
    @"AT+WSSSID=%@\r",                      // 5 设置SSID
    @"AT+WSKEY=OPEN,NONE,%@\r",             // 6 设置Wi-Fi密码 加密方式 (模块升级，不需要传加密方式)
    @"AT+WSKEY=OPEN,NONE\r",                // 6 设置开放的Wi-Fi
    @"AT+WMODE=STA\r",                    // 7 设置设备工作模式
    @"AT+Z\r",                            // 10 重启模块
    @"AT+WSMAC",                            // * 获取设备MAC
//    @"AT+WMODE=APSTA\r",                    // 3 设置设备工作模式
//    @"AT+WSLK",                             // 8 查寻STA连接状态
//    @"AT+ENTM",                             // 9 模块进入透传模式
};

typedef enum : NSUInteger {
    W002CommondIdx_Test,
    W002CommondIdx_Confirm,
    W002CommondIdx_Net,
    W002CommondIdx_Scan,
    W002CommondIdx_SSID,
    W002CommondIdx_Psw,
    W002CommondIdx_PswOpen,
    W002CommondIdx_STAMode,
    W002CommondIdx_Reboot,
    W002CommondIdx_Mac,
//    W002CommondIdx_APMode,
//    W002CommondIdx_WSLK,
//    W002CommondIdx_ENTM,
} W002CommondIdx;

 /*
 //连接初始化
 val CMD_CONNECT = "HF-A11ASSISTHREAD"
 //发送OK
 val CMD_SET_OK = "+ok"
 //设置IP
 val CMD_SET_NETP = "AT+NETP=UDP,CLIENT,10000,47.52.149.125\r\n"
 // 写SSID
 val CMD_SET_SSSID = "AT+WSSSID="
 //写密码
 val CMD_SET_SSKEY = "AT+WSKEY="
 
 val CMD_SET_STA = "AT+WMODE=STA\r\n"
 //重启模块
 val CMD_SET_Z = "AT+Z\r\n"
 */


@implementation W002ConnectorManager

- (void)connectToDevice:(void(^)(W002ConnectorManager *mgr))didConnectedBlock {

    __weak typeof(self) weakSelf = self;
    self.didBeginReceiving = ^{ // 连接成功后便开始 接收数据
        didConnectedBlock(weakSelf);
    };
    
    [self initTaskChains];
    
    if (self.isConnected) {
        self.didBeginReceiving();
    } else {
        NSError *error = nil;
        if ([self.udpSocket connectToHost:self.host onPort:self.port error:&error] == false) {
            NSLog(@"Error connecting: %@", error);
            [self taskFailed];
        };
    }
}

- (W002ConnectorManager *(^)(void))connectionTest {
    return ^W002ConnectorManager *(void) {
        [self.commands addObject:W002Commonds[W002CommondIdx_Test]];
        
        HandleDataBlock testBlock = ^(NSString *msg){
            
            NSArray *components = [msg componentsSeparatedByString:@","];
            if (components.count == 3 && [components[0] isEqualToString:self.host]) {
                
                self.connectionTestResult(self, components[1]);
                [self next];
                // 发送 +ok，无返回 延迟后继续下一个任务
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.taskRetHandlers[self.taskPointer](nil);
                });
            } else {
                [self taskFailed];
            }
        };

        [self.taskRetHandlers addObject:testBlock];
        
        [self.commands addObject:W002Commonds[W002CommondIdx_Confirm]];
        
        HandleDataBlock confirmBlock = ^(NSString *msg) {
            [self next];
        };
        [self.taskRetHandlers addObject:confirmBlock];

        return self;
    };
}

//- (W002ConnectorManager *(^)(void))confirmTestResult {
//    return ^W002ConnectorManager *(void) {
//        [self.commands addObject:W002Commonds[W002CommondIdx_Confirm]];
//
//        HandleDataBlock block = ^(NSString *msg) {
//            NSLog(@"*=*=ConfirmTestResult=*=* :\nNone handle block");
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self next];
//            });
//        };
//        [self.tasks addObject:block];
//
//        return self;
//    };
//}

// (default: 47.52.149.125: 10000)
- (W002ConnectorManager *(^)(NSString *, NSString *))setNETP {
    return ^W002ConnectorManager *(NSString *host, NSString *port) {
        [self.commands addObject:[NSString stringWithFormat:W002Commonds[W002CommondIdx_Net], port, host]];
        
        HandleDataBlock block = ^(NSString *msg) {
            NSLog(@"*=*=%s=*=* :%@", __func__, msg);
        };
        
        [self.taskRetHandlers addObject:block];
        
        return self;
    };
}

- (W002ConnectorManager *(^)(void))scanWiFi {
    return ^W002ConnectorManager *(void) {
        [self.commands addObject:W002Commonds[W002CommondIdx_Scan]];
        
        HandleDataBlock block = ^(NSString *msg) {
            // Ch,SSID,BSSID,Security,Indicator
            // 10,ezdeiMac,58:40:4E:E4:B3:50,WPA2PSK/AES,100
            NSArray *components = [msg componentsSeparatedByString:@","];
            if ([components.lastObject isEqualToString:@"Indicator\r\n"] == false) {
                
                NSUInteger cmptsCount = components.count;
                if (cmptsCount > 1) {
                    
                    NSString *ssid = components[1];
                    if (cmptsCount > 5) {
                        // 大于5，表明 SSID 中包含 ','
                        NSInteger ssidCommaCount = cmptsCount - 5;
                        for (int i = 2; i < 2 + ssidCommaCount; i++) {
                            ssid = [ssid stringByAppendingFormat:@",%@", components[i]];
                        }
                    }
                    
                    NSArray *secCompts = [components[cmptsCount - 2] componentsSeparatedByString:@"/"];
                    NSString *auth = secCompts.firstObject;
                    NSString *encry = secCompts.lastObject;
                    
                    self.scanWiFiResult == nil ? : self.scanWiFiResult(self, ssid, auth, encry);
                } else if ([msg containsString:@"+ok"]) {
                    [self next];
                }
            }
        };
        
        [self.taskRetHandlers addObject:block];
        
        return self;
    };
}

- (W002ConnectorManager *(^)(NSString *))setSSID {
    return ^W002ConnectorManager *(NSString *ssid) {
        [self.commands addObject:[NSString stringWithFormat:W002Commonds[W002CommondIdx_SSID], ssid]];
        
        HandleDataBlock block = ^(NSString *msg) {
            if ([msg containsString:@"+ok"]) {
                [self next];
            } else if ([msg containsString:@"+ERR"]) {
                [self taskFailed];
            }
        };
        
        [self.taskRetHandlers addObject:block];
        
        return self;
    };
}

- (W002ConnectorManager *(^)(NSString *, NSString *, NSString *))setPsw {
    return ^W002ConnectorManager *(NSString *psw, NSString *auth, NSString *encry) {
        if (psw) {
            [self.commands addObject:[NSString stringWithFormat:W002Commonds[W002CommondIdx_Psw], psw]];
        } else {
            [self.commands addObject:W002Commonds[W002CommondIdx_PswOpen]];
        }
        
        HandleDataBlock block = ^(NSString *msg) {
            if ([msg containsString:@"+ok"]) {
                [self next];
            } else if ([msg containsString:@"+ERR"]) {
                [self taskFailed];
            }
        };

        [self.taskRetHandlers addObject:block];
        
        return self;
    };
}

- (W002ConnectorManager *(^)(NSString *, NSString *))scanForSSIDAndSetPsw {
    W002ConnectorManager *(^block)(NSString *, NSString *) = ^(NSString *ssid, NSString *psw) {
        self.scanWiFi().setSSID(ssid);
        self.scanWiFiResult = ^(BaseConnectorManager *mgr, NSString *ssidT, NSString *auth, NSString *encry) {
            NSLog(@"\n*=*=*=*=* \n ssid: %@ \n auth: %@ \n encry: %@", ssidT, auth, encry);
            
            if ([ssidT hasPrefix:ssid]) {
                ((W002ConnectorManager *)mgr).setPsw(psw, auth, encry).setSTAWorkMode().setRebootDevice();
            }
        };
        
        return self;
    };
    
    return block;
}

- (W002ConnectorManager *(^)(void))setSTAWorkMode {
    return ^W002ConnectorManager *(void) {
        [self.commands addObject:W002Commonds[W002CommondIdx_STAMode]];
        
        HandleDataBlock block = ^(NSString *msg) {
            if ([msg containsString:@"+ok"]) {
                [self next];
            } else if ([msg containsString:@"+ERR"]) {
                [self taskFailed];
            }
        };

        [self.taskRetHandlers addObject:block];
        
        return self;
    };
}

- (W002ConnectorManager *(^)(void))setRebootDevice {
    return ^W002ConnectorManager *(void) {
        [self.commands addObject:W002Commonds[W002CommondIdx_Reboot]];
        
        HandleDataBlock block = ^(NSString *msg) {
            if ([msg containsString:@"+ok"]) {
                [self next];
            } else if ([msg containsString:@"+ERR"]) {
                [self taskFailed];
            }
        };

        [self.taskRetHandlers addObject:block];
        
        return self;
    };
}

- (W002ConnectorManager *(^)(void))getMac {
    W002ConnectorManager *(^block)(void) = ^(void) {
        [self.commands addObject:W002Commonds[W002CommondIdx_Mac]];
        
        HandleDataBlock block = ^(NSString *msg){
            NSLog(@"*=*=%s=*=* :%@", __func__, msg); // wyntemp
        };
        
        [self.taskRetHandlers addObject:block];
        
        return self;
    };
    
    return block;
}


@end
