//
//  BaseConnectorManager.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/3/29.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "BaseConnectorManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h>
#import <arpa/inet.h>


@interface BaseConnectorManager() <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) NSTimer *timeoutTimer;

@property (nonatomic, assign) NSInteger taskPointer;

@end

@implementation BaseConnectorManager

- (NSMutableArray *)commands {
    if (_commands == nil) {
        _commands = [NSMutableArray array];
    }
    
    return _commands;
}
- (NSMutableArray *)taskRetHandlers {
    if (_taskRetHandlers == nil) {
        _taskRetHandlers = [NSMutableArray array];
    }
    
    return _taskRetHandlers;
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

- (void)initTaskChains {
    
    NSLog(@"***** 初始化任务链 *****");
    _taskPointer = 0;
    [self.commands removeAllObjects];
    [self.taskRetHandlers removeAllObjects];
    
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
    
    [self.commands addObject:@"connectToDevice"]; // 无实际用途 表示一项任务
    HandleDataBlock block = ^(NSString *msg){
        NSLog(@"*=*=Connected block=*=* :%@", msg);
    };
    [self.taskRetHandlers addObject:block];
}

- (void)next {
    self.resultBlock(self, true, _taskPointer);
    if (_taskPointer < (NSInteger)self.commands.count - 1) {
        NSString *instruction = self.commands[(_taskPointer + 1)];
        NSData *data = [instruction dataUsingEncoding:NSUTF8StringEncoding];
        if (self.udpSocket.isConnected) {
            [self.udpSocket sendData:data withTimeout:20 tag:(_taskPointer + 1)];
        } else {
            [self.udpSocket sendData:data toHost:self.host port:self.port withTimeout:20 tag:(_taskPointer + 1)];
        }
    } else {
        NSLog(@"*=*=%s=*=* :\nSucceed finnish all commond", __func__);
    }
}

- (void)dealloc {
    [self.udpSocket close];
    
    [_timeoutTimer invalidate];
    _timeoutTimer = nil;
}

#pragma mark -
- (void(^)(void))begin {
    return ^void(void) {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:20.f target:self selector:@selector(timeout) userInfo:nil repeats:NO];
        
        NSLog(@"*=*= All tasks =*=* :\n%@", self.commands);

        [self next];
    };
}
- (void)timeout {
    if (_taskPointer < self.commands.count - 1) {
        [self taskFailed];
        [self.udpSocket close];
    }
}

- (BaseConnectorManager *(^)(void))initTasks {
    BaseConnectorManager *(^block)(void) = ^(void) {
        [self initTaskChains];

        [self.commands addObject:@"initTask"]; // 无实际用途 表示成任务
        HandleDataBlock block = ^(NSString *msg){
            NSLog(@"*=*=Init Task=*=* :%@", msg);
        };
        [self.taskRetHandlers addObject:block];

        return self;
    };
    
    return block;
}

#pragma mark - GCDAsyncUdpSocket Delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"+=+= Did connect +=+=");
    
    if (self.didConnectToAddress) {
        self.didConnectToAddress(sock, address);
    }
    
    NSError *error = nil;
    if ([sock beginReceiving:&error]) {
        if (self.didBeginReceiving) {
            self.didBeginReceiving();
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_taskPointer == 0) {
                // 失败
                [self taskFailed];
                [sock close];
            }
        });
    } else {
        NSLog(@"Error at begin receiving: %@", error);
        [self taskFailed];
        [sock close];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"+=+= Did send data: +=+=\ntag:%ld Cmd:%@", tag, self.commands[tag]);
    _taskPointer++;
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"+=+= Did not send data with tag: +=+=\n%ld dueToError:%@", tag, error);
    [self taskFailed];
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

    if (_taskPointer < self.taskRetHandlers.count) {
        self.taskRetHandlers[_taskPointer](msg);
    }
}


#pragma mark -
// 当前 wLan ssid
+ (NSString *)currentSSID {
    NSString *ssid = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (wifiInterfaces == nil) {
        return @"Jump to Settings"; // 没有连接Wi-Fi，建议跳转到设置页
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

- (void)taskFailed {
    self.resultBlock(self, false, _taskPointer);
}

@end
