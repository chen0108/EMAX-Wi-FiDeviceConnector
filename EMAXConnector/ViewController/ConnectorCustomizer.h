//
//  ConnectorCustomizer.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/26.
//  Copyright © 2018年 emax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectorCustomizer : NSObject

/**
 default is blackColor */
@property (nonatomic, strong) UIColor *tintColor;
/**
 default is blackColor */
@property (nonatomic, strong) UIColor *textColor;
/**
 default is whiteColor */
@property (nonatomic, strong) UIColor *btnTextColor;


/**
 指导用户开启设备AP模式的图片（在步骤2中展示）
 The image guide shows in step 2, which is to guide users how to turn on device AP mode.
 */
@property (nonatomic, strong) UIImage *deviceSettingGuide;
/**
 指导用户连接设备Wi-Fi的图片（在步骤3中展示）
 The guiding image shows in step 3, which is to guide users connect to device's Wi-Fi.
 */
@property (nonatomic, strong) UIImage *wifiSettingGuide;

/**
 default is "LivingSmart" */
@property (nonatomic, copy) NSString *deviceSSID;
/**
 default is "11.11.11.254" */
@property (nonatomic, copy) NSString *host;
/**
 default is 8800 */
@property (nonatomic, assign) uint16_t port;

/**
 All done block */
@property (nonatomic, copy) void(^successBlock)(UIViewController *vc);

@end

