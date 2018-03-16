//
//  ViewController.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/26.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "ViewController.h"
#import "StepOneViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)didClickBtn {
    ConnectorCustomizer *customizer = [ConnectorCustomizer new];
    customizer.tintColor = [UIColor orangeColor];
    customizer.deviceSettingGuide = [UIImage imageNamed:@"deviceSettingGuide_cn"];
    customizer.wifiSettingGuide = [UIImage imageNamed:@"wifiSettingGuide"];
    customizer.deviceSSID = @"LivingSmart";
    customizer.host = @"11.11.11.254";
    customizer.port = 8800;
    customizer.successBlock = ^(UIViewController *vc, NSString *deviceMAC) {

    };
    
    StepOneViewController *vc = [StepOneViewController new];
    vc.customizer = customizer;
    // Same background color in the next three ViewController
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)newStyleAction {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
