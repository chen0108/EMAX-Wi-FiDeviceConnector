//
//  TestHelperViewController.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/19.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "TestHelperViewController.h"
#import "ConnectorHelper.h"
#import "UIImage+tint.h"
#import "W001ConnectorManager.h"

@interface TestHelperViewController ()

@property (nonatomic, strong) UIButton *nextStepBtn;

@property (nonatomic, strong) ConnectorHelper *mgr;

@property (nonatomic, strong) UIView *loadingView;

@property (nonatomic, strong) UILabel *statusLb;

@property (nonatomic, strong) W001ConnectorManager *mgr1;

@end

@implementation TestHelperViewController

- (ConnectorHelper *)mgr {
    if (_mgr == nil) {
//        _mgr = [[ConnectorHelper alloc] initWithHost:@"11.11.11.254" port:8800 module:WiFiModule_W001];
        _mgr = [[ConnectorHelper alloc] initWithHost:@"10.10.100.255" port:48899 module:WiFiModule_W002];
    }
    
    return _mgr;
}

- (W001ConnectorManager *)mgr1 {
    if (_mgr1 == nil) {
        _mgr1 = [[W001ConnectorManager alloc] initWithHost:@"11.11.11.254" port:8800];
    }
    
    return _mgr1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *nextStepBtn =             [[UIButton alloc] initWithFrame:CGRectMake(kPadding * 2, kScreenHeight - 40 - (40 * kScreenScale), kScreenWidth - (kPadding * 4), 40)];
    nextStepBtn.layer.cornerRadius =    10;
    nextStepBtn.layer.masksToBounds =   YES;
//    nextStepBtn.enabled = [[ConnectorHelper currentSSID] isEqualToString:self.customizer.deviceSSID];
    [nextStepBtn setTitle:EMAXConnectorLocalizedString(@"Next") forState:UIControlStateNormal];
    [nextStepBtn setTitleColor:self.customizer.btnTextColor forState:UIControlStateNormal];
    [nextStepBtn setBackgroundImage:[UIImage imageWithColor:self.customizer.tintColor] forState:UIControlStateNormal];
    [nextStepBtn setTitle:[NSString stringWithFormat:EMAXConnectorLocalizedString(@"Please connect %@"), self.customizer.deviceSSID] forState:UIControlStateDisabled];
    [nextStepBtn setBackgroundImage:[UIImage imageWithColor:[self.customizer.tintColor colorWithAlphaComponent:0.4]] forState:UIControlStateDisabled];
    [nextStepBtn addTarget:self action:@selector(nextStepAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:nextStepBtn];
    _nextStepBtn = nextStepBtn;
}

- (void)nextStepAction {
/*
    self.mgr.connectionTestResult = ^(ConnectorHelper *helper, NSString *mac) {
        NSLog(@"*=*=%s=*=* Mac: %@", __func__, mac);
    };
    
//    self.mgr.scanWiFiResult = ^(ConnectorHelper *helper, NSString *ssid, NSString *auth, NSString *encry) {
//        NSLog(@"*=*=%s=*=* \n ssid: %@ \n auth: %@ \n encry: %@", __func__, ssid, auth, encry);
//        if ([ssid hasPrefix:@"ezdeiMac"]) {
//            helper.setPsw(@"ezde", auth, encry).setSSID(@"ezdeiMac").begin();
//        }
//    };

    self.mgr.resultBlock = ^(ConnectorHelper *helper, BOOL isSuccess, NSInteger taskPointer) {
        NSLog(@"*=*=%s=*=* :%d %ld", __func__, isSuccess, (long)taskPointer);
    };

    self.mgr.connectToDeviceAndBegin();//.connectionTest();//.scanForSSIDAndSetPsw(@"ezdeiMac", @"ezdeimac");
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        self.mgr.setAPWorkMode().begin();
    //    });
    */
    
    self.mgr1.resultBlock = ^(BaseConnectorManager *mgr, BOOL isSuccess, NSInteger taskPointer) {
        NSLog(@"*=*=%s=*=* :%d %ld", __func__, isSuccess, (long)taskPointer);
    };
    self.mgr1.scanWiFiResult = ^(W001ConnectorManager *mgr, NSString *ssid, NSString *auth, NSString *encry) {
        NSLog(@"*=*=%s=*=* \n ssid: %@ \n auth: %@ \n encry: %@", __func__, ssid, auth, encry);
    };
    self.mgr1.connectionTestResult = ^(W001ConnectorManager *helper, NSString *mac) {
        NSLog(@"*=*=%s=*=* Mac: %@", __func__, mac);
    };
    [self.mgr1 connectToDevice:^(W001ConnectorManager *mgr) {
        mgr.connectionTest().scanWiFi().begin();
    }];

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
    
    self.statusLb.text = @"";
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

@end
