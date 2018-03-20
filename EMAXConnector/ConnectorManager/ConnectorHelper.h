//
//  ConnectorHelper.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/16.
//  Copyright © 2018年 emax. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 // ***************************************
 APP对模块操作流程
 // ***************************************
 UDP发送                         模块应答
 HF-A11ASSISTHREAD              返回设备名称+ip+mac
 +ok         +ok
 //可以开始发送下面指令（每个AT指令后面要+/r）
 AT+WMODE=APSTA                 +ok           设备工作模式
 
 AT+NETP=UDP,CLIENT,10000,47.52.149.125
 AT+WSMAC                       +ok=fd152436  获取设备MAC(建议去掉)
 AT+WSCAN                       +ok           查找AP
 AT+WSSSID=T                    +ok           写SSID
 AT+WSKEY=WPA2PSK,AES,88888888  +ok  写密码
 AT+WSLK                        +ok=T(MAC)    查寻STA连接状态
 AT+ENTM                        +ok           模块进入透传模式
 AT+Z                           +ok           重启模块
 */
typedef enum : NSUInteger {
    WiFiModule_W001,
    WiFiModule_W002,
} WiFiModule;

@interface ConnectorHelper : NSObject

@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, assign) WiFiModule module; // 设备模块
- (instancetype)initWithHost:(NSString *)host port:(uint16_t)port module:(WiFiModule)module;

/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/
#pragma mark - Chain Task
/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/

/**
 连接设备并开始任务链 */
- (ConnectorHelper *(^)(void))connectToDeviceAndBegin;
/**
 连接测试 */
- (ConnectorHelper *(^)(void))connectionTest;
/** W002
 设置设备工作模式为 APSTA */
- (ConnectorHelper *(^)(void))setAPWorkMode;
/** W002
 设置设备连接的服务器地址与端口 */
- (ConnectorHelper *(^)(NSString *host, NSString *port))setNETP;
/**
 扫描Wi-Fi */
- (ConnectorHelper *(^)(void))scanWiFi;
/**
 设置密码 */
- (ConnectorHelper *(^)(NSString *psw, NSString *auth, NSString *encry))setPsw;
/**
 设置SSID */
- (ConnectorHelper *(^)(NSString *ssid))setSSID;
/** W001
 扫描Wi-Fi得到一致SSID => 设置密码 => 设置SSID （_taskPointer += 3） */
- (ConnectorHelper *(^)(NSString *ssid, NSString *psw))scanForSSIDAndSetPsw;
/** W002
 查寻STA连接状态 */
- (ConnectorHelper *(^)(void))setWSLK;
/** W002
 模块进入透传模式 */
- (ConnectorHelper *(^)(void))setENTM;
/** W002
 重启设备 */
- (ConnectorHelper *(^)(void))setRebootDevice;

/**
 获取Mac */
- (ConnectorHelper *(^)(void))getMac;

/**
 开始任务链 */
- (ConnectorHelper *(^)(void))begin;

/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/
#pragma mark - Block-delegate
/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/

/**
 连接测试回调（返回Mac） */
@property (nonatomic, copy) void(^connectionTestResult)(ConnectorHelper *helper, NSString *mac);
/**
 扫描Wi-Fi回调（多次） */
@property (nonatomic, copy) void(^scanWiFiResult)(ConnectorHelper *helper, NSString *ssid, NSString *auth, NSString *encry);
/**
 获取Mac回调 */
@property (nonatomic, copy) void(^getMacResult)(ConnectorHelper *helper, NSString *mac);

/**
 任务链最终结果 */
@property (nonatomic, copy) void(^resultBlock)(ConnectorHelper *helper, BOOL isSuccess, NSInteger taskPointer);

/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/
#pragma mark - Class method
/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/

/**
 手机当前连接的Wi-Fi名称
 current Wi-Fi SSID of iPhone connected
 */
+ (NSString *)currentSSID;

@end
