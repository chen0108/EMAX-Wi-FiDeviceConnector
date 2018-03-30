//
//  StepThreeViewController.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/23.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "StepOneViewController.h"

@interface StepThreeViewController : UIViewController

@property (nonatomic, strong) ConnectorCustomizer *customizer;

@property (copy, nonatomic) NSString *ssid;
@property (copy, nonatomic) NSString *psw;

@end
