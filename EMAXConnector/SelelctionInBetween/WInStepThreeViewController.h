//
//  WInStepThreeViewController.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/26.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "WInStepOneViewController.h"
#import "W001ConnectorManager.h"

@interface WInStepThreeViewController : UIViewController

@property (nonatomic, strong) ConnectorCustomizer *customizer;

@property (nonatomic, strong) W001ConnectorManager *mgr;

@property (nonatomic, copy) NSString *mac;

@property (copy, nonatomic) NSString *ssid;
@property (copy, nonatomic) NSString *auth;
@property (copy, nonatomic) NSString *encry;

@end
