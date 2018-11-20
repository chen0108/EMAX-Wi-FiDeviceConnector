// GlobalTool.m 
// Wi-FiDeviceConnector 
// 
// Created by HCC on 2018/11/20. 
// Copyright © 2018 emax. All rights reserved. 
//

#import "GlobalTool.h"

@implementation GlobalTool

/**
 >>  跳转到wifi设置  */
+ (void)jumpToWifiSettings{
    ///私有api混淆
    NSData *encryptString = [[NSData alloc] initWithBytes:(unsigned char []){0x41,0x70,0x70,0x2d,0x50,0x72,0x65,0x66,0x73,0x3a,0x72,0x6f,0x6f,0x74,0x3d,0x57,0x49,0x46,0x49} length:19];
    NSString *string = [[NSString alloc] initWithData:encryptString encoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:string];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
