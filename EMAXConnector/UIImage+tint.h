//
//  UIImage+tint.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/22.
//  Copyright © 2018年 emax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum __UIImageTintedStyle
{
    UIImageTintedStyleKeepingAlpha      = 1,
    UIImageTintedStyleOverAlpha         = 2
} UIImageTintedStyle;

@interface UIImage (tint)

- (UIImage*)tintedImageWithColor:(UIColor*)color style:(UIImageTintedStyle)tintStyle;

+ (UIImage*)imageWithColor:(UIColor*)color;

@end
