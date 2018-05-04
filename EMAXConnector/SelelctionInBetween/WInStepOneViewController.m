//
//  WInStepOneViewController.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/26.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "WInStepOneViewController.h"
#import "WInStepTwoViewController.h"
#import "BaseConnectorManager.h"

@interface WInStepOneViewController ()

@property (nonatomic, strong) UIButton *nextStepBtn;

@end

@implementation WInStepOneViewController {
    BOOL _shouldAutoPushing; // 跳转设置页连接上Wi-Fi后，才能自动跳转
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = EMAXConnectorLocalizedString(@"Connect to your device");
    
    UIImageView *stepImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Connector.bundle/wifi_1"] tintedImageWithColor:self.customizer.tintColor style:UIImageTintedStyleKeepingAlpha]];
    [stepImgView setFrame:CGRectMake(kPadding, kNavStatusBarHeigth + 25, kScreenWidth - (kPadding * 2), 22)];
    [stepImgView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:stepImgView];
    
    UIImageView *guideImgView = [[UIImageView alloc] initWithImage:self.customizer.wifiSettingGuide];
    guideImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:guideImgView];
    
    UIButton *nextStepBtn =             [[UIButton alloc] initWithFrame:CGRectMake(kPadding * 2, kScreenHeight - 40 - (40 * kScreenScale), kScreenWidth - (kPadding * 4), 40)];
    nextStepBtn.layer.cornerRadius =    10;
    nextStepBtn.layer.masksToBounds =   YES;
    nextStepBtn.enabled = [[BaseConnectorManager currentSSID] isEqualToString:self.customizer.deviceSSID];
    [nextStepBtn setTitle:EMAXConnectorLocalizedString(@"Next") forState:UIControlStateNormal];
    [nextStepBtn setTitleColor:self.customizer.btnTextColor forState:UIControlStateNormal];
    [nextStepBtn setBackgroundImage:[UIImage imageWithColor:self.customizer.tintColor] forState:UIControlStateNormal];
    [nextStepBtn setTitle:[NSString stringWithFormat:EMAXConnectorLocalizedString(@"Please connect %@"), self.customizer.deviceSSID] forState:UIControlStateDisabled];
    [nextStepBtn setBackgroundImage:[UIImage imageWithColor:[self.customizer.tintColor colorWithAlphaComponent:0.4]] forState:UIControlStateDisabled];
    [nextStepBtn addTarget:self action:@selector(nextStepAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:nextStepBtn];
    _nextStepBtn = nextStepBtn;
    
    guideImgView.frame = CGRectMake(0, CGRectGetMaxY(stepImgView.frame), kScreenWidth, kScreenHeight * 0.5);
    
    /* * */
    [self showConfirmAlertViewWithMsg:[NSString stringWithFormat:EMAXConnectorLocalizedString(@"Go to Wi-Fi settings, choose %@ and then back to app to continue."), self.customizer.deviceSSID] shouldJump:!self.nextStepBtn.isEnabled confirmBlock:nil];
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,onNetworkChange, CFSTR("com.apple.system.config.network_change"), NULL,CFNotificationSuspensionBehaviorDeliverImmediately);
}
static WInStepOneViewController *selfClass = nil;
static void onNetworkChange(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){ // 函数
    NSString *notifyName = (__bridge NSString *) name;
    NSLog(@"*=*=notifyName=*=* :\n%@", notifyName);

    if ([notifyName isEqualToString:@"com.apple.system.config.network_change"]) {
        [selfClass onNetworkChange];
    }
}
- (void)onNetworkChange {
    if (_shouldAutoPushing == YES && [[BaseConnectorManager currentSSID] isEqualToString:self.customizer.deviceSSID]) {
        _shouldAutoPushing = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.53f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self nextStepAction];
            self.nextStepBtn.enabled = true;
        });
    }
}
- (void)dealloc {
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.apple.system.config.network_change"), NULL);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    selfClass = self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.customizer.StepViewDidAppear) {
        self.customizer.StepViewDidAppear(self, 1);
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    selfClass = nil;
}

- (void)nextStepAction {
    WInStepTwoViewController *vc = [WInStepTwoViewController new];
    vc.customizer = self.customizer;
    vc.view.backgroundColor = self.view.backgroundColor;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showConfirmAlertViewWithMsg:(NSString *)msg shouldJump:(BOOL)shouldJump confirmBlock:(void (^)(void))block {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:EMAXConnectorLocalizedString(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (block) {
            block();
        }
        if (shouldJump) {
            _shouldAutoPushing = YES;
            NSURL *url = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                if (@available(iOS 10, *)) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }
    }]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:ac animated:YES completion:nil];
    });
}

@end
