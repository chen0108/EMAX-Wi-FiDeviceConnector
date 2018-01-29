//
//  ConnectorManager.h
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/24.
//  Copyright © 2018年 emax. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TagMean_Init, // including bind host&port, test connection
    TagMean_ShouldScan, // tell device scan Wi-Fi
    TagMean_ShouldSetPIN, // including PIN, auth, encry
    TagMean_ShouldSetSSID,
    TagMean_Succeed,
} TagMean;

@interface ConnectorManager : NSObject

@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) uint16_t port;
- (instancetype)initWithHost:(NSString *)host port:(uint16_t)port;

/**
 开始为设备设置Wi-Fi连接 
 begin setting device's Wi-Fi connection
 
 @param ssid Wi-Fi名
 @param pin Wi-Fi密码
 @param block
    isSuccess
        上一个任务是否成功（TagMean_Succeed除外）
        indicate whether previous action is succuss
    tagMean
        接下来的任务
        next action
 NOTE:
    当(tag == TagMean_Succeed && isSuccess == YES)时，表示本次任务完成
    The task succeed when (tag == TagMean_Succeed && isSuccess == YES).
 */
- (void)beginConnectTaskWithSSID:(NSString *)ssid
                             pin:(NSString *)pin
                     finishBlock:(void (^)(BOOL isSuccess, TagMean tagMean))block;

/**
 设备mac地址(与设备初始化连接后才有值)
 device's mac(not nil after 'beginConnectTaskWithSSID')
 */
@property (nonatomic, copy, readonly) NSString *deviceMAC;

/**
 手机当前连接的Wi-Fi名称
 current Wi-Fi SSID of iPhone connected
 */
+ (NSString *)currentSSID;

@end
