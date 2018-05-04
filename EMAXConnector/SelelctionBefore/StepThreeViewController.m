//
//  StepThreeViewController.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/23.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "StepThreeViewController.h"
#import "W001ConnectorManager.h"
#import "W002ConnectorManager.h"

@interface StepThreeViewController ()

@property (nonatomic, strong) UIButton *nextStepBtn;

@property (nonatomic, strong) UIView *loadingView;

@property (nonatomic, strong) BaseConnectorManager *mgr;

@property (nonatomic, strong) UILabel *statusLb;

@property (nonatomic, copy) NSString *deviceMAC;

@end

@implementation StepThreeViewController

- (BaseConnectorManager *)mgr {
    if (_mgr == nil) {
        if (self.customizer.module == DeviceModule_W001) {
            _mgr = [[W001ConnectorManager alloc] initWithHost:self.customizer.host port:self.customizer.port];
        } else if (self.customizer.module == DeviceModule_W002) {
            _mgr = [[W002ConnectorManager alloc] initWithHost:self.customizer.host port:self.customizer.port];
        }
    }
    
    return _mgr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = EMAXConnectorLocalizedString(@"Connect to your device");

    UIImageView *stepImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Connector.bundle/wifi_3"] tintedImageWithColor:self.customizer.tintColor style:UIImageTintedStyleKeepingAlpha]];
    [stepImgView setFrame:CGRectMake(kPadding, kNavStatusBarHeigth + 25, kScreenWidth - (kPadding * 2), 22)];
    [stepImgView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:stepImgView];

    UIImageView *guideImgView = [[UIImageView alloc] initWithImage:self.customizer.wifiSettingGuide];
    guideImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:guideImgView];
    
    UIButton *nextStepBtn =             [[UIButton alloc] initWithFrame:CGRectMake(kPadding * 2, kScreenHeight - 40 - (40 * kScreenScale), kScreenWidth - (kPadding * 4), 40)];
    nextStepBtn.layer.cornerRadius =    10;
    nextStepBtn.layer.masksToBounds =   YES;
    nextStepBtn.enabled = [[W001ConnectorManager currentSSID] isEqualToString:self.customizer.deviceSSID];
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
    [self showConfirmAlertViewWithMsg:[NSString stringWithFormat:EMAXConnectorLocalizedString(@"Go to Wi-Fi settings, choose %@ and then back to app to complete the setting."), self.customizer.deviceSSID] shouldJump:!self.nextStepBtn.isEnabled confirmBlock:nil];
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,onNetworkChange, CFSTR("com.apple.system.config.network_change"), NULL,CFNotificationSuspensionBehaviorDeliverImmediately);
}
static StepThreeViewController *selfClass = nil;
static void onNetworkChange(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){ // 函数
    NSString* notifyName = (__bridge NSString *) name;
    if ([notifyName isEqualToString:@"com.apple.system.config.network_change"]) {
        [selfClass onNetworkChange];
    }
}
- (void)onNetworkChange {
    self.nextStepBtn.enabled = [[W001ConnectorManager currentSSID] isEqualToString:self.customizer.deviceSSID];
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


#pragma mark -
- (void)nextStepAction {
    [self showLoadingView];
    // 0:连接  1:测试  2:扫描  3:设置密码  4:设置ssid
//    self.mgr.connectToDeviceAndBegin().connectionTest().scanForSSIDAndSetPsw(self.ssid, self.psw);
    
    if (self.customizer.module == DeviceModule_W001) {
        [(W001ConnectorManager *)self.mgr connectToDevice:^(W001ConnectorManager *mgr) {
            mgr.connectionTest().scanForSSIDAndSetPsw(self.ssid, self.psw).begin();
        }];
    } else if (self.customizer.module == DeviceModule_W002) {
        [(W002ConnectorManager *)self.mgr connectToDevice:^(W002ConnectorManager *mgr) {
            mgr.connectionTest().scanForSSIDAndSetPsw(self.ssid, self.psw).begin();
        }];
    }

    __weak typeof(self) weakSelf = self;
    self.mgr.connectionTestResult = ^(BaseConnectorManager *mgr, NSString *mac) {
        NSLog(@"*=*=%s=*=* Mac: %@", __func__, mac);
        weakSelf.deviceMAC = mac;
    };
    
    self.mgr.resultBlock = ^(BaseConnectorManager *mgr, BOOL isSuccess, NSInteger taskPointer) {
        NSLog(@"*=*= ResultBlock =*=* :%d %ld", isSuccess, taskPointer);
        if (isSuccess) {
            NSString *msg = [weakSelf messageWithTask:(taskPointer + 1) isSuccess:YES];
            weakSelf.statusLb.text = msg;
            if (taskPointer == 4) {
                [weakSelf dismissLoadingView];
                [weakSelf showConfirmAlertViewWithMsg:msg shouldJump:YES confirmBlock:^{
                    if (weakSelf.customizer.successBlock) {
                        weakSelf.customizer.successBlock(weakSelf, weakSelf.deviceMAC);
                    }
                }];
            }
        } else {
            [weakSelf dismissLoadingView];
            NSString *msg = [weakSelf messageWithTask:taskPointer isSuccess:NO];
            [weakSelf showConfirmAlertViewWithMsg:msg shouldJump:NO confirmBlock:nil];
        }
    };
}

- (NSString *)messageWithTask:(NSInteger)taskPointer isSuccess:(BOOL)isSuccess {
    NSString *msg = nil;
    switch (taskPointer) { // 0:连接  1:测试  2:扫描  3:设置密码  4:设置ssid
        case 0: {
            msg = EMAXConnectorLocalizedString(@"Initializing connection");
            break;
        }
        case 1: {
            msg = EMAXConnectorLocalizedString(@"Test connection");
            break;
        }
        case 2: {
            msg = EMAXConnectorLocalizedString(@"Scaning Wi-Fi");
            break;
        }
        case 3: {
            msg = EMAXConnectorLocalizedString(@"Setting Wi-Fi SSID");

            break;
        }
        case 4: { // 最后一个任务
//            if (isSuccess) {
//                msg = EMAXConnectorLocalizedString(@"Connection sucessful, please press and hold WiFi button for 3 seconds again to complete the setting.");
//            } else {
                msg = EMAXConnectorLocalizedString(@"Setting Wi-Fi PIN");
//            }
            break;
        }
        case 5: {
            if (isSuccess) {
                msg = EMAXConnectorLocalizedString(@"Connection sucessful, please press and hold WiFi button for 3 seconds again to complete the setting.");
            }
            break;
        }
        default:
            break;
    }
    if (isSuccess == NO) {
        msg = [msg stringByAppendingString:EMAXConnectorLocalizedString(@"error!")];
    }
    return msg;
}

- (UILabel *)statusLb {
    if (_statusLb == nil) {
        _statusLb = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.center.y + 44, kScreenWidth, 20)];
        _statusLb.textAlignment = NSTextAlignmentCenter;
        _statusLb.textColor = [UIColor whiteColor];
        _statusLb.font = [UIFont systemFontOfSize:12];
    }
    
    return _statusLb;
}
- (void)showLoadingView {
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
    [self.view.window addSubview:maskView];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 57, 57)];
    container.backgroundColor = [UIColor whiteColor];
    container.layer.cornerRadius = 5;
    container.layer.masksToBounds = YES;
    container.center = self.view.center;
    [maskView addSubview:container];
    
    UIImage *img = [[UIImage imageNamed:@"Connector.bundle/circle"] tintedImageWithColor:self.customizer.tintColor style:UIImageTintedStyleKeepingAlpha];
    UIImageView *circle = [[UIImageView alloc] initWithImage:img];
    [circle sizeToFit];
    circle.center = CGPointMake(28.5, 28.5);
    [container addSubview:circle];
    [self startAnimation:circle];
    
    self.statusLb.text = [self messageWithTask:0 isSuccess:YES];
    [maskView addSubview:self.statusLb];
    
    _loadingView = maskView;
}
- (void)dismissLoadingView {
    [_loadingView removeFromSuperview];
    _loadingView = nil;
}

- (void)startAnimation:(UIImageView *)imageView {
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 2.2f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = CGFLOAT_MAX;
    [imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


- (void)showConfirmAlertViewWithMsg:(NSString *)msg shouldJump:(BOOL)shouldJump confirmBlock:(void (^)(void))block {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:EMAXConnectorLocalizedString(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (block) {
            block();
        }
        if (shouldJump) {
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
