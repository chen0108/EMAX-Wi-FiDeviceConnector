//
//  W001ConnectorManager.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/29.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "BaseConnectorManager.h"

@interface W001ConnectorManager : BaseConnectorManager

/**
 连接设备并准备开始任务链 */
- (void)connectToDevice:(void(^)(W001ConnectorManager *mgr))didConnectedblock;

/**
 连接测试 */
- (W001ConnectorManager *(^)(void))connectionTest;
/**
 扫描Wi-Fi */
- (W001ConnectorManager *(^)(void))scanWiFi;
/**
 设置密码 */
- (W001ConnectorManager *(^)(NSString *psw, NSString *auth, NSString *encry))setPsw;
/**
 设置SSID */
- (W001ConnectorManager *(^)(NSString *ssid))setSSID;
/** W001
 扫描Wi-Fi得到一致SSID => 设置密码 => 设置SSID （_taskPointer += 3） */
- (W001ConnectorManager *(^)(NSString *ssid, NSString *psw))scanForSSIDAndSetPsw;

/**
 获取Mac */
- (W001ConnectorManager *(^)(void))getMac;

@end
