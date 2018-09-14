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
    self.title = EMAXConnectorLocalizedString(@"Active your device");

    UIImageView *stepImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"wifi_2" inBundle:kConnectorBundle compatibleWithTraitCollection:nil] emax_tintedImageWithColor:self.customizer.tintColor style:EmaxImageTintedStyleKeepingAlpha]];
    [stepImgView setFrame:CGRectMake(kPadding, kNavStatusBarHeigth + 25, kEMAXScreenWidth - (kPadding * 2), 22)];
    [stepImgView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:stepImgView];

    UIImageView *guideImgView = [[UIImageView alloc] initWithImage:self.customizer.deviceSettingGuide];
    guideImgView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:guideImgView];

    
    UIButton *nextStepBtn =             [[UIButton alloc] initWithFrame:CGRectMake(kPadding * 2, kEMAXScreenHeight - 40 - (40 * kEMAXScreenScale), kEMAXScreenWidth - (kPadding * 4), 40)];
    nextStepBtn.backgroundColor =       self.customizer.tintColor;
    nextStepBtn.layer.cornerRadius =    10;
    nextStepBtn.layer.masksToBounds =   YES;
    [nextStepBtn setTitle:EMAXConnectorLocalizedString(@"Next") forState:UIControlStateNormal];
    [nextStepBtn setTitleColor:self.customizer.btnTextColor forState:UIControlStateNormal];
    [nextStepBtn addTarget:self action:@selector(nextStepAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:nextStepBtn];

    guideImgView.frame = CGRectMake(0, CGRectGetMaxY(stepImgView.frame), kEMAXScreenWidth, nextStepBtn.frame.origin.y - CGRectGetMaxY(stepImgView.frame));

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.customizer.StepViewDidAppear) {
        self.customizer.StepViewDidAppear(self, 2);
    }
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
