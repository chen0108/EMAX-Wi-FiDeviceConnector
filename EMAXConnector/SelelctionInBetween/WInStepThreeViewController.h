//
//  WInStepThreeViewController.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/26.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "WInStepOneViewController.h"
#import "ConnectorHelper.h"

@interface WInStepThreeViewController : UIViewController

@property (nonatomic, strong) ConnectorCustomizer *customizer;

@property (nonatomic, strong) ConnectorHelper *mgr;

@property (nonatomic, copy) NSString *mac;

@property (copy, nonatomic) NSString *ssid;
@property (copy, nonatomic) NSString *auth;
@property (copy, nonatomic) NSString *encry;

@end
