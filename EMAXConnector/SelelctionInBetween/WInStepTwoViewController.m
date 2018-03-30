//
//  WInStepTwoViewController.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/26.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "WInStepTwoViewController.h"
#import "WInStepThreeViewController.h"

@interface WInStepTwoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) ConnectorHelper *mgr;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<NSString *> *ssids;
@property (nonatomic, strong) NSMutableArray<NSString *> *auths;
@property (nonatomic, strong) NSMutableArray<NSString *> *encrys;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation WInStepTwoViewController

- (ConnectorHelper *)mgr {
    if (_mgr == nil) {
        _mgr = [[ConnectorHelper alloc] initWithHost:@"11.11.11.254" port:8800 module:WiFiModule_W001];
//        _mgr = [[ConnectorHelper alloc] initWithHost:@"10.10.100.255" port:48899 module:WiFiModule_W002];
    }
    
    return _mgr;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        CGRect rect = CGRectMake(0, kNavStatusBarHeigth + 25 + 22 + 10, kScreenWidth, kScreenHeight * 0.5);
        _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        
        [self.view addSubview:_tableView];
        
        [self.indicator stopAnimating];
    }
    
    return _tableView;
}

- (NSMutableArray<NSString *> *)ssids {
    if (_ssids == nil) {
        _ssids = [NSMutableArray array];
    }
    
    return _ssids;
}
- (NSMutableArray<NSString *> *)auths {
    if (_auths == nil) {
        _auths = [NSMutableArray array];
    }
    
    return _auths;
}
- (NSMutableArray<NSString *> *)encrys {
    if (_encrys == nil) {
        _encrys = [NSMutableArray array];
    }
    
    return _encrys;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = EMAXConnectorLocalizedString(@"Choose your router");
    
    UIImageView *stepImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Connector.bundle/wifi_2"] tintedImageWithColor:self.customizer.tintColor style:UIImageTintedStyleKeepingAlpha]];
    [stepImgView setFrame:CGRectMake(kPadding, kNavStatusBarHeigth + 25, kScreenWidth - (kPadding * 2), 22)];
    [stepImgView setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:stepImgView];

    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = self.view.center;
    indicator.hidesWhenStopped = YES;
    [indicator startAnimating];
    [self.view addSubview:indicator];
    _indicator = indicator;
    
    self.mgr.connectToDeviceAndBegin().connectionTest().scanWiFi();

    __weak typeof(self) weakSelf = self;
    self.mgr.connectionTestResult = ^(ConnectorHelper *helper, NSString *mac) {
        NSLog(@"*=*=%s=*=* MAC:\n%@", __func__, mac);

    };
    
    self.mgr.scanWiFiResult = ^(ConnectorHelper *helper, NSString *ssid, NSString *auth, NSString *encry) {
        ssid = [ssid substringToIndex:ssid.length - 3]; // " \r \n
        [weakSelf.ssids addObject:ssid];
        [weakSelf.auths addObject:auth];
        [weakSelf.encrys addObject:encry];

//        [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(weakSelf.ssids.count - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [weakSelf.tableView reloadData];
    };
    
    self.mgr.resultBlock = ^(ConnectorHelper *helper, BOOL isSuccess, NSInteger taskPointer) {
        NSLog(@"*=*=%s=*=* :%d %ld", __func__, isSuccess, (long)taskPointer);
    };
}

#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WInStepThreeViewController *vc = [WInStepThreeViewController new];
    vc.customizer = self.customizer;
    vc.mgr = self.mgr;
    vc.ssid = self.ssids[indexPath.row];
    vc.auth = self.auths[indexPath.row];
    vc.encry = self.encrys[indexPath.row];
    vc.view.backgroundColor = self.view.backgroundColor;
    [self.navigationController pushViewController:vc animated:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text =   self.ssids[indexPath.row];
    cell.accessoryType =    UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ssids.count;
}

@end
