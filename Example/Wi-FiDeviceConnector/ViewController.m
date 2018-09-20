//
//  ViewController.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/26.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "ViewController.h"
#import "StepOneViewController.h"
#import "WInStepOneViewController.h"
#import "TestHelperViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [UIView new];
    self.title = @"WiFi配对";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.row) {
        case 0:
            [self pair001Action];
            break;
        case 1:
            [self pair002Host:nil port:nil];
            break;
        case 2:
            [self pair003Action];
            break;
        default:
            break;
    }
}

- (void)pair001Action{
    
    ConnectorCustomizer *customizer = [ConnectorCustomizer new];
    customizer.tintColor = [UIColor orangeColor];
    customizer.deviceSettingGuide = [UIImage imageNamed:@"deviceSettingGuide_cn"];
    customizer.wifiSettingGuide = [UIImage imageNamed:@"wifiSettingGuide"];
    customizer.deviceSSID = @"LivingSmart";
    customizer.host = @"11.11.11.254";
    customizer.port = 8800;
    customizer.successBlock = ^(UIViewController *vc, NSString *deviceMAC) {
        NSLog(@"*******配对成功, mac : %@",deviceMAC);
    };
    
    StepOneViewController *vc = [StepOneViewController new];
    vc.customizer = customizer;
    // Same background color in the next three ViewController
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pair002Host:(NSString *)host port:(NSString *)port{
    
    ConnectorCustomizer *customizer = [ConnectorCustomizer new];
    customizer.tintColor = UIColor.orangeColor;
    customizer.textColor = UIColor.orangeColor;
    customizer.btnTextColor = UIColor.whiteColor;
    customizer.deviceSettingGuide = [UIImage imageNamed:@"deviceSettingGuide_cn"];
    customizer.wifiSettingGuide = [UIImage imageNamed:@"wifiSettingGuide"];
    customizer.deviceSSID = @"LivingSmart";
    customizer.host = @"10.10.100.254";
    customizer.port = 48899;
    if (host.length > 0 && port.length > 0) {
        customizer.serverHost = host;
        customizer.serverPort = port;
    }
    customizer.module = DeviceModule_W002;
    customizer.successBlock = ^(UIViewController *vc, NSString *deviceMAC) {
        // 配对成功
        NSLog(@"*******配对成功, mac : %@",deviceMAC);
    };
    StepOneViewController *vc = [StepOneViewController new];
    vc.customizer = customizer;
    // Same background color in the next three ViewController
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pair003Action{
    
    __weak  typeof(self)this = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入服务器地址" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"host";
        textField.text = @"192.168.200.101";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"port";
        textField.text = @"17000";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf0 = alertController.textFields.firstObject;
        UITextField *tf1 = alertController.textFields.lastObject;
        [this pair002Host:tf0.text port:tf1.text];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    //present出AlertView
    [self presentViewController:alertController animated:true completion:nil];
}









- (IBAction)newStyleAction {
    ConnectorCustomizer *customizer = [ConnectorCustomizer new];
    customizer.tintColor = [UIColor orangeColor];
    customizer.deviceSettingGuide = [UIImage imageNamed:@"deviceSettingGuide_cn"];
    customizer.wifiSettingGuide = [UIImage imageNamed:@"wifiSettingGuide"];
    customizer.deviceSSID = @"LivingSmart";
    customizer.host = @"11.11.11.254";
    customizer.port = 8800;
    customizer.successBlock = ^(UIViewController *vc, NSString *deviceMAC) {
        
    };
    
    WInStepOneViewController *vc = [WInStepOneViewController new];
    vc.customizer = customizer;
    // Same background color in the next three ViewController
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];

}


@end
