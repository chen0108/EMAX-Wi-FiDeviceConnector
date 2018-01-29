//
//  StepOneViewController.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/22.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "ConnectorManager.h"
#import "ConnectorCustomizer.h"
#import "UIImage+tint.h"

#define kDevice_Is_iPhoneX      ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define kStatusH                (kDevice_Is_iPhoneX? 44 : 20)
#define kNavbarH                44
#define kSBottom                (kDevice_Is_iPhoneX ? 34 : 0)

#define kNavStatusBarHeigth     (kStatusH+kNavbarH)

#define kScreenWidth            [UIScreen mainScreen].bounds.size.width
#define kScreenHeight           [UIScreen mainScreen].bounds.size.height
#define kScreenScale            kScreenWidth / 375 // refer - iPhone6

#define kLocalizedString(Str)   NSLocalizedString(Str, nil)


#define kPadding 20

@interface StepOneViewController : UIViewController

@property (nonatomic, strong) ConnectorCustomizer *customizer;

@end

