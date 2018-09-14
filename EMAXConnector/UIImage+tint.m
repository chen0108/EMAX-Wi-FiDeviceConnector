//
//  UIImage+tint.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/22.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "UIImage+tint.h"


@implementation UIImage (tint)

- (UIImage*)emax_tintedImageWithColor:(UIColor*)color style:(EmaxImageTintedStyle)tintStyle
{
    if (!color)
        return self;
    
    CGFloat scale = self.scale;
    CGSize size = CGSizeMake(scale * self.size.width, scale * self.size.height);
    
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    // ---
    
    if (tintStyle == EmaxImageTintedStyleOverAlpha)
    {
        [color setFill];
        CGContextFillRect(context, rect);
    }
    
    // draw alpha-mask
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, self.CGImage);
    
    if (tintStyle == EmaxImageTintedStyleKeepingAlpha)
    {
        CGContextSetBlendMode(context, kCGBlendModeSourceIn);
        [color setFill];
        CGContextFillRect(context, rect);
    }
    
    // ---
    CGImageRef bitmapContext = CGBitmapContextCreateImage(context);
    
    UIImage *coloredImage = [UIImage imageWithCGImage:bitmapContext scale:scale orientation:UIImageOrientationUp];
    
    CGImageRelease(bitmapContext);
    
    UIGraphicsEndImageContext();
    
    return coloredImage;
}

+ (UIImage*)emax_imageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f,0.0f,1.0f,1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context= UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);

    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();UIGraphicsEndImageContext();
    return theImage;
    
}


@end
