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
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
