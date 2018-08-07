//
//  W001ConnectorManager.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/29.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "W001ConnectorManager.h"

static NSString * const W001Commonds[] = {
    @"LSD_WIFI",                            // 连接测试
    @"LSD_WIFI:AT+WSCAN\r\n",                // 扫描热点
    @"LSD_WIFI:AT+WSKEY=%@,%@,%@\r\n",      // 设置Wi-Fi密码 加密方式
    @"LSD_WIFI:AT+WSKEY=OPEN,NONE\r\n",     // 设置开放的Wi-Fi
    @"LSD_WIFI:AT+WSSSID=%@\r\n",           // 设置SSID
    @"LSD_WIFI:AT+WSMAC\r\n",               // 获取设备MAC
};

typedef enum : NSUInteger {
    W001CommondIdx_Test,
    W001CommondIdx_Scan,
    W001CommondIdx_Psw,
    W001CommondIdx_PswOpen,
    W001CommondIdx_SSID,
    W001CommondIdx_Mac,
} W001CommondIdx;

@interface W001ConnectorManager()

@end

@implementation W001ConnectorManager

- (void)connectToDevice:(void(^)(W001ConnectorManager *mgr))didConnectedblock {
    __weak typeof(self) weakSelf = self;
    self.didBeginReceiving = ^{ // 连接成功后便开始 接收数据
        didConnectedblock(weakSelf);
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

- (W001ConnectorManager *(^)(void))connectionTest {
    return ^W001ConnectorManager *(void) {
        [self.commands addObject:W001Commonds[W001CommondIdx_Test]];
        
        HandleDataBlock block = ^(NSString *msg){
            if ([msg hasSuffix:@"LSD_F205"]) {
                NSArray *arr = [msg componentsSeparatedByString:@","];
                if (self.connectionTestResult) {
                    self.connectionTestResult(self, [arr.firstObject uppercaseString]);
                }
                [self next];
            };
        };
        [self.taskRetHandlers addObject:block];
        
        return self;
    };
}

- (W001ConnectorManager *(^)(void))scanWiFi {
    return ^W001ConnectorManager *(void) {
        [self.commands addObject:W001Commonds[W001CommondIdx_Scan]];
        //        _receiveWiFiInfo = YES;
        HandleDataBlock block = ^(NSString *msg){
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
        
        [self.taskRetHandlers addObject:block];
        
        return self;
    };
}

- (W001ConnectorManager *(^)(NSString *psw, NSString *auth, NSString *encry))setPsw {
    W001ConnectorManager *(^block)(NSString *, NSString *, NSString *) = ^(NSString *psw, NSString *auth, NSString *encry) {
        if (psw) {
            [self.commands addObject:[NSString stringWithFormat:W001Commonds[W001CommondIdx_Psw], auth, encry, psw]];
        } else {
            [self.commands addObject:W001Commonds[W001CommondIdx_PswOpen]];
        }
        HandleDataBlock block = ^(NSString *msg){
//            _receiveWiFiInfo = NO;
            if ([msg containsString:@"+ok"]) {
                [self next];
            } else if ([msg containsString:@"+ERR=-4"]) {
                [self taskFailed];
            }
        };
        [self.taskRetHandlers addObject:block];
        
        return self;
    };
    
    return block;
    
}

- (W001ConnectorManager *(^)(NSString *ssid))setSSID {
    W001ConnectorManager *(^block)(NSString *) = ^(NSString *ssid) {
        [self.commands addObject:[NSString stringWithFormat:W001Commonds[W001CommondIdx_SSID],ssid]];
        HandleDataBlock block = ^(NSString *msg){
//            _receiveWiFiInfo = NO;
            if ([msg containsString:@"+ok"]) {
                [self next];
            } else if ([msg containsString:@"+ERR=-4"]) {
                [self taskFailed];
            }
        };
        [self.taskRetHandlers addObject:block];
        
        return self;
    };
    
    return block;
}

- (W001ConnectorManager *(^)(NSString *, NSString *))scanForSSIDAndSetPsw {
    W001ConnectorManager *(^block)(NSString *, NSString *) = ^(NSString *ssid, NSString *psw) {
        self.scanWiFi().setSSID(ssid);
        self.scanWiFiResult = ^(BaseConnectorManager *mgr, NSString *ssidT, NSString *auth, NSString *encry) {
            NSLog(@"*=*=*=*=* \n ssid: %@ \n auth: %@ \n encry: %@", ssid, auth, encry);
            if ([ssidT hasPrefix:ssid]) {
                
                ((W001ConnectorManager *)mgr).setPsw(psw, auth, encry).begin();
            }
        };
        
        return self;
    };
    
    return block;
}

- (W001ConnectorManager *(^)(void))getMac {
    W001ConnectorManager *(^block)(void) = ^(void) {
        [self.commands addObject:W001Commonds[W001CommondIdx_Mac]];
        HandleDataBlock block = ^(NSString *msg){
            if ([msg containsString:@"+ok"]) {
                NSArray *arr = [msg componentsSeparatedByString:@"="];
                if (arr != nil && arr.count == 2) {
                    NSString *mac = [arr[1] substringToIndex:12];
                    self.getMacResult(self, mac);
                    [self next];
                }
            }
        };
        [self.taskRetHandlers addObject:block];
        
        return self;
    };
    
    return block;
}


@end
