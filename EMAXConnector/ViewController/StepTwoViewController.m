//
//  StepTwoViewController.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/23.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "StepTwoViewController.h"
#import "StepThreeViewController.h"

@interface StepTwoViewController ()

@end

@implementation StepTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = kLocalizedString(@"Active your device");

    UIImageView *stepImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Connector.bundle/wifi_2"] tintedImageWithColor:self.customizer.tintColor style:UIImageTintedStyleKeepingAlpha]];
    [stepImgView setFrame:CGRectMake(kPadding, kNavStatusBarHeigth + 25, kScreenWidth - (kPadding * 2), 22)];
    [stepImgView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:stepImgView];

    UIImageView *guideImgView = [[UIImageView alloc] initWithImage:self.customizer.deviceSettingGuide];
    guideImgView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:guideImgView];

    
    UIButton *nextStepBtn =             [[UIButton alloc] initWithFrame:CGRectMake(kPadding * 2, kScreenHeight - 40 - (40 * kScreenScale), kScreenWidth - (kPadding * 4), 40)];
    nextStepBtn.backgroundColor =       self.customizer.tintColor;
    nextStepBtn.layer.cornerRadius =    10;
    nextStepBtn.layer.masksToBounds =   YES;
    [nextStepBtn setTitle:kLocalizedString(@"Next") forState:UIControlStateNormal];
    [nextStepBtn setTitleColor:self.customizer.btnTextColor forState:UIControlStateNormal];
    [nextStepBtn addTarget:self action:@selector(nextStepAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:nextStepBtn];

    guideImgView.frame = CGRectMake(0, CGRectGetMaxY(stepImgView.frame), kScreenWidth, nextStepBtn.frame.origin.y - CGRectGetMaxY(stepImgView.frame));

}

- (void)nextStepAction {
    StepThreeViewController *vc = [StepThreeViewController new];
    vc.customizer = self.customizer;
    vc.ssid = self.ssid;
    vc.psw = self.psw;
    vc.view.backgroundColor = self.view.backgroundColor;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
