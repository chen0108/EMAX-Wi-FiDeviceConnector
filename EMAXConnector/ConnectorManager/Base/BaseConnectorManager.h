//
//  BaseConnectorManager.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/29.
//  Copyright © 2018年 emax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"

typedef void(^HandleDataBlock)(NSString *msg);

@interface BaseConnectorManager : NSObject

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) uint16_t port;
- (instancetype)initWithHost:(NSString *)host port:(uint16_t)port;


@property (nonatomic, assign, readonly) NSInteger taskPointer;
@property (nonatomic, strong) NSMutableArray<NSString *> *commands;
@property (nonatomic, strong) NSMutableArray<HandleDataBlock> *taskRetHandlers; 


/**
 初始化任务链（清理数据）
 */
- (void)initTaskChains;

/**
 下一个任务
 */
- (void)next;

/**
 开始任务链
 */
- (void(^)(void))begin;

/**
 初始化任务链
 */
- (BaseConnectorManager *(^)(void))initTasks;

/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/
#pragma mark - Block delegate
/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/

/**
 任务链最终结果（必须） */
@property (nonatomic, copy) void(^resultBlock)(BaseConnectorManager *mgr, BOOL isSuccess, NSInteger taskPointer);

/**
 连接上
 */
@property (nonatomic, copy) void(^didConnectToAddress)(GCDAsyncUdpSocket *sock, NSData *address);

/**
 连接测试回调（返回Mac） */
@property (nonatomic, copy) void(^connectionTestResult)(BaseConnectorManager *mgr, NSString *mac);

/**
 开始接收数据
 */
@property (nonatomic, copy) void(^didBeginReceiving)(void);

/**
 扫描Wi-Fi回调（多次） */
@property (nonatomic, copy) void(^scanWiFiResult)(BaseConnectorManager *mgr, NSString *ssid, NSString *auth, NSString *encry);

/**
 获取Mac回调 */
@property (nonatomic, copy) void(^getMacResult)(BaseConnectorManager *mgr, NSString *mac);



/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/
#pragma mark - Convenient method
/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/

/**
 手机当前连接的Wi-Fi名称
 current Wi-Fi SSID of iPhone connected
 */
+ (NSString *)currentSSID;

/**
 是否连接 */
- (BOOL)isConnected;

/**
 任务失败，通知 ‘resultBlock’
 */
- (void)taskFailed;
@end
