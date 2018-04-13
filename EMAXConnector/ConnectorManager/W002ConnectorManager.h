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
- (void)connectToDevice:(void(^)(W002ConnectorManager *mgr))didConnectedBlock;

/**
 连接测试 */
- (W002ConnectorManager *(^)(void))connectionTest;
/**
 设置设备连接的服务器地址与端口 (default: 47.52.149.125: 10000) */
- (W002ConnectorManager *(^)(NSString *host, NSString *port))setNETP;
/**
 扫描Wi-Fi */
- (W002ConnectorManager *(^)(void))scanWiFi;
/**
 设置SSID */
- (W002ConnectorManager *(^)(NSString *ssid))setSSID;
/**
 设置密码 */
- (W002ConnectorManager *(^)(NSString *psw, NSString *auth, NSString *encry))setPsw;
/** W002
 设置设备工作模式为 STA */
- (W002ConnectorManager *(^)(void))setSTAWorkMode;
/** W002
 重启设备 */
- (W002ConnectorManager *(^)(void))setRebootDevice;

/**
 获取Mac */
- (W002ConnectorManager *(^)(void))getMac;

@end
