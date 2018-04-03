//
//  W002ConnectorManager.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/4/2.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "BaseConnectorManager.h"

@interface W002ConnectorManager : BaseConnectorManager

/**
 连接设备并准备开始任务链 */
- (void)connectToDevice:(void(^)(W002ConnectorManager *mgr))didConnectedblock;

/**
 连接测试 */
- (W002ConnectorManager *(^)(void))connectionTest;
/**
 确认测试结果 */
- (W002ConnectorManager *(^)(void))confirmTestResult;
/** W002
 设置设备工作模式为 APSTA */
- (W002ConnectorManager *(^)(void))setAPWorkMode;
/** W002
 设置设备连接的服务器地址与端口 */
- (W002ConnectorManager *(^)(NSString *host, NSString *port))setNETP;
/**
 扫描Wi-Fi */
- (W002ConnectorManager *(^)(void))scanWiFi;
/**
 设置密码 */
- (W002ConnectorManager *(^)(NSString *psw, NSString *auth, NSString *encry))setPsw;
/**
 设置SSID */
- (W002ConnectorManager *(^)(NSString *ssid))setSSID;
/** W002
 查寻STA连接状态 */
- (W002ConnectorManager *(^)(void))setWSLK;
/** W002
 模块进入透传模式 */
- (W002ConnectorManager *(^)(void))setENTM;
/** W002
 重启设备 */
- (W002ConnectorManager *(^)(void))setRebootDevice;

@end
