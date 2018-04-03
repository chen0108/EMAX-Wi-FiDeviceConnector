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
    @"+ok"                                  // 2 确认步骤‘1’返回无误
    @"AT+WMODE=APSTA\r",                    // 3 设置设备工作模式
    @"AT+NETP=UDP,CLIENT,%@,%@",            // 4 设置设备服务端端口、地址
    @"AT+WSCAN",                            // 5 扫描热点
    @"AT+WSKEY=%@,%@,%@",                   // 6 设置Wi-Fi密码 加密方式
    @"AT+WSKEY=OPEN,NONE",                  // 6 设置开放的Wi-Fi
    @"AT+WSSSID=%@",                        // 7 设置SSID
    @"AT+WSMAC",                            // * 获取设备MAC
    @"AT+WSLK",                             // 8 查寻STA连接状态
    @"AT+ENTM",                             // 9 模块进入透传模式
    @"AT+Z",                                // 10 重启模块
};

typedef enum : NSUInteger {
    W002CommondIdx_Test,
    W002CommondIdx_Confirm,
    W002CommondIdx_APMode,
    W002CommondIdx_Net,
    W002CommondIdx_Scan,
    W002CommondIdx_Psw,
    W002CommondIdx_PswOpen,
    W002CommondIdx_SSID,
    W002CommondIdx_Mac,
    W002CommondIdx_WSLK,
    W002CommondIdx_ENTM,
    W002CommondIdx_Reboot,
} W002CommondIdx;


@implementation W002ConnectorManager

- (void)connectToDevice:(void(^)(W002ConnectorManager *mgr))didConnectedblock {
    __weak typeof(self) weakSelf = self;
    self.didBeginReceiving = ^{ // 连接成功后便开始 接收数据
        didConnectedblock(weakSelf);
    };
    
    [self initTaskChains];
    
    [self.commands addObject:@"connectToDevice"]; // 无实际用途 表示一项任务
    HandleDataBlock block = ^(NSString *msg){
        NSLog(@"*=*=Connected block=*=* :%@", msg);
    };
    [self.tasks addObject:block];
    
    NSError *error = nil;
    [self.udpSocket enableBroadcast:YES error:&error];
    [self.udpSocket bindToPort:self.port error:&error];
    [self.udpSocket receiveOnce:&error];
    
    if (error) {
        NSLog(@"Error connecting: %@", error);
        self.resultBlock(self, false, self.taskPointer);
    };
}

- (W002ConnectorManager *(^)(void))connectionTest {
    return ^W002ConnectorManager *(void) {
        [self.commands addObject:W002Commonds[W002CommondIdx_Test]];
        
        HandleDataBlock block = ^(NSString *msg){
            NSLog(@"*=*=%s=*=* :%@", __func__, msg);
        };

        [self.tasks addObject:block];
        
        return self;
    };
}

- (W002ConnectorManager *(^)(void))confirmTestResult {
    return ^W002ConnectorManager *(void) {
        [self.commands addObject:W002Commonds[W002CommondIdx_Confirm]];
        
        
        return self;
    };
}

- (W002ConnectorManager *(^)(void))setAPWorkMode {
    return ^W002ConnectorManager *(void) {
        [self.commands addObject:W002Commonds[W002CommondIdx_APMode]];
        
        HandleDataBlock block = ^(NSString *msg) {
            NSLog(@"*=*=%s=*=* :%@", __func__, msg);
        };
        
        [self.tasks addObject:block];
        
        return self;
    };
}

@end
