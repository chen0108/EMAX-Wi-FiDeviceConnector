//
//  WInStepThreeViewController.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/26.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "WInStepThreeViewController.h"

@interface WInStepThreeViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *wlanPswTF;

@property (nonatomic, strong) UIButton *nextStepBtn;

@property (nonatomic, strong) UIView *loadingView;

@property (nonatomic, strong) UILabel *statusLb;

@end

@implementation WInStepThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *stepImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Connector.bundle/wifi_3"] tintedImageWithColor:self.customizer.tintColor style:UIImageTintedStyleKeepingAlpha]];
    [stepImgView setFrame:CGRectMake(kPadding, kNavStatusBarHeigth + 25, kScreenWidth - (kPadding * 2), 22)];
    [stepImgView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:stepImgView];
    
    UILabel *ssidKeyLb =            [[UILabel alloc] initWithFrame:CGRectMake(kPadding, kScreenHeight * 0.25f + kNavStatusBarHeigth, 0, 0)];
    ssidKeyLb.font =                [UIFont systemFontOfSize:16];
    ssidKeyLb.textColor =           [self.customizer.textColor colorWithAlphaComponent:0.5];
    ssidKeyLb.text =                @"Wi-Fi SSID";
    [ssidKeyLb sizeToFit];
    [self.view addSubview:ssidKeyLb];
    
    UILabel *ssidValueLb =          [UILabel new];
    ssidValueLb.frame =             CGRectMake(CGRectGetMaxX(ssidKeyLb.frame) + 20, ssidKeyLb.frame.origin.y, kScreenWidth * 0.5, 20);
    ssidValueLb.font =              [UIFont systemFontOfSize:16];
    ssidValueLb.textColor =         self.customizer.textColor;
    ssidValueLb.text =              self.ssid;
    ssidValueLb.textAlignment =     NSTextAlignmentCenter;
    [self.view addSubview:ssidValueLb];
    
    UITextField *wlanPswTF =        [[UITextField alloc] initWithFrame:CGRectMake(kPadding, CGRectGetMaxY(ssidKeyLb.frame) + 40, kScreenWidth - (kPadding * 2), 35)];
    wlanPswTF.returnKeyType =       UIReturnKeyNext;
    wlanPswTF.secureTextEntry =     true;
    wlanPswTF.font =                [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    wlanPswTF.textColor =           [self.customizer.textColor colorWithAlphaComponent:0.7];
    wlanPswTF.tintColor =           self.customizer.tintColor;
    wlanPswTF.delegate =            self;
    [self.view addSubview:wlanPswTF];
    CALayer *bottomBorder =         [CALayer layer];
    bottomBorder.frame =            CGRectMake(0.0f, wlanPswTF.frame.size.height - 0.5, wlanPswTF.frame.size.width, 0.5);
    bottomBorder.backgroundColor =  [UIColor blackColor].CGColor;
    [wlanPswTF.layer addSublayer:bottomBorder];
    _wlanPswTF = wlanPswTF;
    
    UIButton *radioBtn =            [[UIButton alloc] initWithFrame:CGRectMake(kPadding + 6, CGRectGetMaxY(wlanPswTF.frame) + 20, 130, 40)];
    radioBtn.imageEdgeInsets =      UIEdgeInsetsMake(0, -10, 0, 0);
    radioBtn.titleLabel.font =      [UIFont systemFontOfSize:13];
    [radioBtn setTitle:EMAXConnectorLocalizedString(@"display password") forState:UIControlStateNormal];
    [radioBtn setTitleColor:self.customizer.textColor forState:UIControlStateNormal];
    [radioBtn setImage:[[UIImage imageNamed:@"Connector.bundle/wifi_radio0_btn"] tintedImageWithColor:self.customizer.tintColor style:UIImageTintedStyleKeepingAlpha] forState:UIControlStateNormal];
    [radioBtn setImage:[[UIImage imageNamed:@"Connector.bundle/wifi_radio1_btn"] tintedImageWithColor:self.customizer.tintColor style:UIImageTintedStyleKeepingAlpha] forState:UIControlStateSelected];
    [radioBtn addTarget:self action:@selector(didClickRadioBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:radioBtn];
    [radioBtn sizeToFit];
    CGRect rect = radioBtn.frame;
    rect.size.height = 40;
    [radioBtn setFrame:rect];
    
    /* * * */
    UIButton *nextStepBtn =             [[UIButton alloc] initWithFrame:CGRectMake(kPadding * 2, kScreenHeight - 40 - (40 * kScreenScale), kScreenWidth - (kPadding * 4), 40)];
    nextStepBtn.layer.cornerRadius =    10;
    nextStepBtn.layer.masksToBounds =   YES;
    [nextStepBtn setTitle:EMAXConnectorLocalizedString(@"Next") forState:UIControlStateNormal];
    [nextStepBtn setTitleColor:self.customizer.btnTextColor forState:UIControlStateNormal];
    [nextStepBtn setBackgroundImage:[UIImage imageWithColor:self.customizer.tintColor] forState:UIControlStateNormal];
    [nextStepBtn setBackgroundImage:[UIImage imageWithColor:[self.customizer.tintColor colorWithAlphaComponent:0.4]] forState:UIControlStateDisabled];
    [nextStepBtn addTarget:self action:@selector(nextStepAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:nextStepBtn];
    _nextStepBtn = nextStepBtn;
    
    UILabel *notiLb =        [[UILabel alloc] init];
    notiLb.backgroundColor = [UIColor clearColor];
    notiLb.font =            [UIFont systemFontOfSize:14];
    notiLb.text =            EMAXConnectorLocalizedString(@"This device do NOT support 5G Wi-Fi frequencies");
    notiLb.textColor =       self.customizer.textColor;
    notiLb.numberOfLines =   0;
    notiLb.lineBreakMode =   NSLineBreakByCharWrapping;
    CGSize labelSize =       [notiLb.text boundingRectWithSize:CGSizeMake(kScreenWidth - 20, 0)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName: notiLb.font}
                                                       context:nil].size;
    notiLb.frame =           CGRectMake(10, nextStepBtn.frame.origin.y - labelSize.height - (25 * kScreenScale), kScreenWidth - 20, labelSize.height);
    [self.view addSubview:notiLb];
    
    /* * * */
    
    self.mgr.resultBlock = ^(BaseConnectorManager *mgr, BOOL isSuccess, NSInteger taskPointer) {
        
    };
}


static NSString * const kSSIDsKey = @"SSIDsKey";
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.customizer.StepViewDidAppear) {
        self.customizer.StepViewDidAppear(self, 3);
    }
}


#pragma mark -
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self nextStepAction];
    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

- (void)didClickRadioBtn:(UIButton *)btn {
    btn.selected = !btn.isSelected;
    self.wlanPswTF.secureTextEntry = !btn.isSelected;
}

- (void)nextStepAction {
    [self showLoadingView];
    self.mgr.setSSID(self.ssid).setPsw(self.wlanPswTF.text, self.auth, self.encry).begin();

    __weak typeof(self) weakSelf = self;
    self.mgr.resultBlock = ^(BaseConnectorManager *helper, BOOL isSuccess, NSInteger taskPointer) {
        NSLog(@"*=*= ResultBlock =*=* :%d %ld", isSuccess, taskPointer);
        if (isSuccess) {
            NSString *msg = [weakSelf messageWithTask:taskPointer isSuccess:YES];
            weakSelf.statusLb.text = msg;
            if (taskPointer == 4) {
                [weakSelf dismissLoadingView];
                [weakSelf showConfirmAlertViewWithMsg:msg shouldJump:YES confirmBlock:^{
                    if (weakSelf.customizer.successBlock) {
                        weakSelf.customizer.successBlock(weakSelf, weakSelf.mac);
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
    switch (taskPointer) { // (0:连接  1:测试  2:扫描)  3:设置密码  4:设置ssid
        case 3: {
            msg = EMAXConnectorLocalizedString(@"Setting Wi-Fi PIN");
            break;
        }
        case 4: { // 最后一个任务
            if (isSuccess) {
                msg = EMAXConnectorLocalizedString(@"Connection sucessful, please press and hold WiFi button for 3 seconds again to complete the setting.");
            } else {
                msg = EMAXConnectorLocalizedString(@"Setting Wi-Fi SSID");
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
