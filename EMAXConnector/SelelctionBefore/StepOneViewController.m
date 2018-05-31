//
//  StepOneViewController.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/22.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "StepOneViewController.h"
#import "StepTwoViewController.h"
#import "BaseConnectorManager.h"

@interface StepOneViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *wlanPswTF;
@property (nonatomic, strong) UIButton *ssidValueBtn;
@property (nonatomic, strong) UIButton *nextStepBtn;
@property (nonatomic, strong) NSMutableArray *ssids;


@end

@implementation StepOneViewController

- (ConnectorCustomizer *)customizer {
    if (_customizer == nil) {
        _customizer = [ConnectorCustomizer new];
    }
    
    return _customizer;
}

- (NSMutableArray *)ssids {
    if (_ssids == nil) {
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:kSSIDsKey];
        if (arr == nil || arr.count == 0) {
            _ssids = [NSMutableArray arrayWithObject:EMAXConnectorLocalizedString(@"Jump to Settings")];
        } else {
            _ssids = [NSMutableArray arrayWithArray:arr];
        }
    }
    
    return _ssids;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = EMAXConnectorLocalizedString(@"Choose your router");
    
    UIImageView *stepImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Connector.bundle/wifi_1"] tintedImageWithColor:self.customizer.tintColor style:UIImageTintedStyleKeepingAlpha]];
    [stepImgView setFrame:CGRectMake(kPadding, kNavStatusBarHeigth + 25, kEMAXScreenWidth - (kPadding * 2), 22)];
    [stepImgView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:stepImgView];
    
    UILabel *ssidKeyLb =            [[UILabel alloc] initWithFrame:CGRectMake(kPadding, kEMAXScreenHeight * 0.25f + kNavStatusBarHeigth, 0, 0)];
    ssidKeyLb.font =                [UIFont systemFontOfSize:16];
    ssidKeyLb.textColor =           [self.customizer.textColor colorWithAlphaComponent:0.5];
    ssidKeyLb.text =                @"Wi-Fi SSID";
    [ssidKeyLb sizeToFit];
    [self.view addSubview:ssidKeyLb];
    
    UIButton *ssidValueBtn =        [UIButton buttonWithType:UIButtonTypeSystem];
    ssidValueBtn.frame =            CGRectMake(CGRectGetMaxX(ssidKeyLb.frame) + 20, ssidKeyLb.frame.origin.y, kEMAXScreenWidth * 0.5, 20);
    ssidValueBtn.titleLabel.font =  [UIFont systemFontOfSize:16];
    [ssidValueBtn setTitleColor:self.customizer.textColor forState:UIControlStateNormal];
    [ssidValueBtn addTarget:self action:@selector(showSSIDsAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ssidValueBtn];
    _ssidValueBtn = ssidValueBtn;
    
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Connector.bundle/rightArrow"] tintedImageWithColor:self.customizer.tintColor style:UIImageTintedStyleKeepingAlpha]];
    arrow.contentMode = UIViewContentModeCenter;
    arrow.frame = CGRectMake(CGRectGetMaxX(ssidValueBtn.frame), ssidValueBtn.frame.origin.y, 8, 20);
    [self.view addSubview:arrow];
    
    UITextField *wlanPswTF =        [[UITextField alloc] initWithFrame:CGRectMake(kPadding, CGRectGetMaxY(ssidKeyLb.frame) + 40, kEMAXScreenWidth - (kPadding * 2), 35)];
    wlanPswTF.returnKeyType =       UIReturnKeyNext;
    wlanPswTF.secureTextEntry =     true;
    wlanPswTF.font =                [UIFont systemFontOfSize:15 weight:UIFontWeightLight];
    wlanPswTF.textColor =           [self.customizer.textColor colorWithAlphaComponent:0.7];
    wlanPswTF.tintColor =           self.customizer.tintColor;
    wlanPswTF.delegate =            self;
    [self.view addSubview:wlanPswTF];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, wlanPswTF.frame.size.height - 0.5, wlanPswTF.frame.size.width, 0.5);
    bottomBorder.backgroundColor = [UIColor blackColor].CGColor;
    [wlanPswTF.layer addSublayer:bottomBorder];
    _wlanPswTF = wlanPswTF;
    
    UIButton *radioBtn =        [[UIButton alloc] initWithFrame:CGRectMake(kPadding + 6, CGRectGetMaxY(wlanPswTF.frame) + 20, 130, 40)];
    radioBtn.imageEdgeInsets =  UIEdgeInsetsMake(0, -10, 0, 0);
    radioBtn.titleLabel.font =  [UIFont systemFontOfSize:13];
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
    UIButton *nextStepBtn =             [[UIButton alloc] initWithFrame:CGRectMake(kPadding * 2, kEMAXScreenHeight - 40 - (40 * kEMAXScreenScale), kEMAXScreenWidth - (kPadding * 4), 40)];
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
    CGSize labelSize =       [notiLb.text boundingRectWithSize:CGSizeMake(kEMAXScreenWidth - 20, 0)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: notiLb.font}
                                               context:nil].size;
    notiLb.frame =           CGRectMake(10, nextStepBtn.frame.origin.y - labelSize.height - (25 * kEMAXScreenScale), kEMAXScreenWidth - 20, labelSize.height);
    [self.view addSubview:notiLb];

    /* * * */
    [self setSSIDValueBtnTitle:[BaseConnectorManager currentSSID]];
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL,onNetworkChange, CFSTR("com.apple.system.config.network_change"), NULL,CFNotificationSuspensionBehaviorDeliverImmediately);
}
static StepOneViewController *selfClass = nil;
static void onNetworkChange(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){ // 函数
    NSString* notifyName = (__bridge NSString *) name;
    if ([notifyName isEqualToString:@"com.apple.system.config.network_change"]) {
        [selfClass onNetworkChange];
    }
}
- (void)onNetworkChange {
    [self setSSIDValueBtnTitle:[BaseConnectorManager currentSSID]];
}
- (void)dealloc {
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.apple.system.config.network_change"), NULL);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    selfClass = self;
}

static NSString * const kSSIDsKey = @"SSIDsKey";
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.customizer.StepViewDidAppear) {
        self.customizer.StepViewDidAppear(self, 1);
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    selfClass = nil; // retainCount - 1
}
#pragma mark -
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self nextStepAction];
    return YES;
}
- (void)showSSIDsAction {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:EMAXConnectorLocalizedString(@"Please select WiFi") preferredStyle:UIAlertControllerStyleActionSheet];

    [ac addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@  ❯", self.ssids.firstObject] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            if (@available(iOS 10, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }]];
    
    for (int i = 1; i < self.ssids.count; i++) { // 从第二个开始
        [ac addAction:[UIAlertAction actionWithTitle:self.ssids[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self setSSIDValueBtnTitle:action.title];
        }]];
    }
    
    [ac addAction:[UIAlertAction actionWithTitle:EMAXConnectorLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)didClickRadioBtn:(UIButton *)btn {
    btn.selected = !btn.isSelected;
    self.wlanPswTF.secureTextEntry = !btn.isSelected;
}

- (void)nextStepAction {
    if (self.wlanPswTF.text.length == 0 || self.wlanPswTF.text.length >= 8) {
        StepTwoViewController *vc = [StepTwoViewController new];
        vc.customizer = self.customizer;
        vc.ssid = self.ssidValueBtn.titleLabel.text;
        vc.psw = self.wlanPswTF.text;
        vc.view.backgroundColor = self.view.backgroundColor;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:EMAXConnectorLocalizedString(@"Wi-Fi PIN length error!") preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:EMAXConnectorLocalizedString(@"Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.wlanPswTF becomeFirstResponder];
        }]];

        [self presentViewController:ac animated:YES completion:nil];

    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

#pragma mark -
- (void)setSSIDValueBtnTitle:(NSString *)title {
    if (title) {
        [self.ssidValueBtn setTitle:title forState:UIControlStateNormal];
        
        if ([title isEqualToString:EMAXConnectorLocalizedString(@"Jump to Settings")]) {
            [self.nextStepBtn setEnabled:NO];
        } else {
            [self.nextStepBtn setEnabled:YES];
            BOOL isSSIDExist = false;
            for (NSString *ssid in self.ssids) {
                if([ssid isEqualToString:title]) {
                    isSSIDExist = true;
                    break;
                }
            }
            if(isSSIDExist == false){
                [self.ssids addObject:title];
                if (self.ssids.count > 7) {
                    [self.ssids removeObjectAtIndex:0];
                }
                [[NSUserDefaults standardUserDefaults] setObject:self.ssids forKey:kSSIDsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }

}


@end


