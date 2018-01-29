//
//  StepOneViewController.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/22.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "StepVCHeader.h"
#import "ConnectorManager.h"
#import "ConnectorCustomizer.h"

#define kPadding 20

@interface StepOneViewController : UIViewController

@property (nonatomic, strong) ConnectorCustomizer *customizer;

@end

