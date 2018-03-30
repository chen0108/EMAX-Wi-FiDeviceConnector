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

@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) uint16_t port;
- (instancetype)initWithHost:(NSString *)host port:(uint16_t)port;

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@property (nonatomic, assign, readonly) NSInteger taskPointer;
@property (nonatomic, strong) NSMutableArray<NSString *> *commands;
@property (nonatomic, strong) NSMutableArray<HandleDataBlock> *tasks;


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
 开始接收数据
 */
@property (nonatomic, copy) void(^didBeginReceiving)(void);

/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/
#pragma mark - Class method
/** =+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+==+=+=+=+=+=+=+= **/

/**
 手机当前连接的Wi-Fi名称
 current Wi-Fi SSID of iPhone connected
 */
+ (NSString *)currentSSID;

- (BOOL)isConnected;

@end
