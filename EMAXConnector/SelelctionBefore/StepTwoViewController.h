//
//  StepTwoViewController.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/23.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "StepOneViewController.h"

@interface StepTwoViewController : UIViewController

@property (nonatomic, strong) ConnectorCustomizer *customizer;

@property (strong, nonatomic) NSString *ssid;
@property (strong, nonatomic) NSString *psw;

@end
