//
//  Connector.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/29.
//  Copyright © 2018年 emax. All rights reserved.
//

#ifndef Connector_h
#define Connector_h

#import "UIImage+tint.h"
// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.
#define kDevice_Is_iPhoneX      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define kStatusH                (kDevice_Is_iPhoneX? 44 : 20)
#define kNavbarH                44
#define kSBottom                (kDevice_Is_iPhoneX ? 34 : 0)

#define kNavStatusBarHeigth     (kStatusH+kNavbarH)

#define kScreenWidth            MainScreenWidth()
#define kScreenHeight           MainScreenHeight()
#define kScreenScale            kScreenWidth / 375 // refer - iPhone6

#define kLocalizedString(Str)   NSLocalizedString(Str, nil)

static __inline__ CGFloat MainScreenWidth()
{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height;
}

static __inline__ CGFloat MainScreenHeight()
{
    return UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
}

#endif /* Connector_h */
