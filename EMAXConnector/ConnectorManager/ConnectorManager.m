//
//  ConnectorManager.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/24.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "ConnectorManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "GCDAsyncUdpSocket.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface ConnectorManager() <GCDAsyncUdpSocketDelegate>

@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@property (nonatomic, copy) void(^block)(BOOL, TagMean) ;

@property (nonatomic, copy) NSString *ssid;
@property (nonatomic, copy) NSString *pin;

@property (nonatomic, copy) NSString *deviceMAC;

@property (nonatomic, assign) TagMean tag;
@end

@implementation ConnectorManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (instancetype)initWithHost:(NSString *)host port:(uint16_t)port
{
    self = [super init];
    if (self) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _host = host;
        _port = port;
    }
    return self;
}

- (void)beginConnectTaskWithSSID:(NSString *)ssid
                             pin:(NSString *)pin
                     finishBlock:(void (^)(BOOL, TagMean))block {
    _ssid =       ssid;
    _pin =        pin;
    _tag =        TagMean_Init;
    self.block =  block;
    
    NSError *error = nil;
    if ([_udpSocket connectToHost:self.host onPort:self.port error:&error] == false) {
        NSLog(@"Error connecting: %@", error);
        self.block(NO, _tag);
    };
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 总超时判断
        if (weakSelf.tag != TagMean_Succeed) {
            weakSelf.block(NO, weakSelf.tag);
            [weakSelf.udpSocket close];
        }
    });
}

- (void)sendInstruction:(NSString *)instruction {
    self.block(YES, _tag);
    NSData *data = [instruction dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:data withTimeout:30 tag:_tag];
}

#pragma mark -
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"+=+= Did connect +=+=");
    
    NSError *error = nil;
    if ([sock receiveOnce:&error]) {
        [self sendInstruction:@"LSD_WIFI"]; // 前导指令
        
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.tag == TagMean_ShouldScan) {
                weakSelf.block(NO, weakSelf.tag);
                [sock close];
            }
        });
    } else {
        NSLog(@"Error receiving: %@", error);
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"+=+= Did send data with tag: +=+=\n%ld", tag);
    _tag++;
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg == nil) {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        NSLog(@"+=+= Receive Unknown message from: +=+=\n%@:%hu", host, port);
        return;
    }
    
    NSLog(@"+=+= Received massage: +=+=\n%@", msg);
    
    NSError *error = nil;
    if ([sock receiveOnce:&error]) {
        [self actionWithTag:_tag msg:msg];
    } else {
        NSLog(@"Error receiving: %@", error);
    }
    
}

#pragma mark -
- (void)actionWithTag:(TagMean)tag msg:(NSString *)msg {
    switch (_tag) {
        case TagMean_ShouldScan: {
            if ([msg hasSuffix:@"LSD_F205"]) {
                NSArray *arr = [msg componentsSeparatedByString:@","];
                self.deviceMAC = [arr.firstObject uppercaseString];
                [self sendInstruction:@"LSD_WIFI:AT+WSCAN\r\n"];
            }
            break;
        }
        case TagMean_ShouldSetPIN: {
            if ([msg containsString:@"Infra     "]) {
                NSArray *infos = [msg componentsSeparatedByString:@"  \""];
                if ([infos.lastObject hasPrefix:self.ssid]) {
                    NSArray *temArr = [infos[1] componentsSeparatedByString:@" "];
                    NSString *auth = temArr.firstObject;
                    if (temArr.count >= 2) { // 判断是否是加密Wi-Fi
                        if ([auth isEqualToString:@"WPA/WPA2"]) {
                            auth = @"WPAPSK";
                        } else {
                            auth = [auth stringByAppendingString:@"PSK"];
                        }
                        NSString *encry = [temArr.lastObject stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                        [self sendInstruction:[NSString stringWithFormat:@"LSD_WIFI:AT+WSKEY=%@,%@,%@\r\n",auth,encry,self.pin]];
                    } else if([auth hasPrefix:@"OPEN"]) {
                        [self sendInstruction:[NSString stringWithFormat:@"LSD_WIFI:AT+WSKEY=OPEN,NONE\r\n"]];
                    }
                }
            }
            break;
        }
        case TagMean_ShouldSetSSID: {
            if ([msg containsString:@"+ok"]) {
                [self sendInstruction:[NSString stringWithFormat:@"LSD_WIFI:AT+WSSSID=%@\r\n",self.ssid]];
            } else if ([msg containsString:@"+ERR=-4"]) {
                self.block(NO, _tag);
            }
            break;
        }
            //        case TagMean_ShouldGetMac: {
            //            break;
            //        }
        case TagMean_Succeed: {
            if ([msg containsString:@"+ok"]) {
                self.block(YES, _tag);
                [self.udpSocket close];
            }
            break;
        }
        default:
            break;
    }
}

// 当前 wLan ssid
+ (NSString *)currentSSID {
    NSString *ssid = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (wifiInterfaces == nil) {
        return @"Jump to Settings";
    } else {
        NSArray *ifs = (__bridge NSArray *)wifiInterfaces;
        for (NSString *ifnam in ifs) {
            CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            if (dictRef) {
                NSDictionary *info = (__bridge id)dictRef;
                
                if (info[@"SSID"]) {
                    ssid = info[@"SSID"];
                    break;
                }
                
                CFRelease(dictRef);
            }
        }
        CFRelease(wifiInterfaces);
        
        return ssid;
    }
}

- (BOOL)isConnected {
    return self.udpSocket.isConnected;
}
@end

