//
//  UIImage+tint.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/22.
//  Copyright © 2018年 emax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum __EmaxImageTintedStyle
{
    EmaxImageTintedStyleKeepingAlpha      = 1,
    EmaxImageTintedStyleOverAlpha         = 2
} EmaxImageTintedStyle;

@interface UIImage (tint)

- (UIImage*)emax_tintedImageWithColor:(UIColor*)color style:(EmaxImageTintedStyle)tintStyle;

+ (UIImage*)emax_imageWithColor:(UIColor*)color;

@end
