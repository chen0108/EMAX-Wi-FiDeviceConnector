//
//  ConnectorCustomizer.m
//  Wi-FiDeviceConnector
//
//  Created by Waynn on 2018/1/26.
//  Copyright © 2018年 emax. All rights reserved.
//

#import "ConnectorCustomizer.h"

@implementation ConnectorCustomizer
- (UIColor *)tintColor {
    if (_tintColor == nil) {
        _tintColor = [UIColor blackColor];
    }
    
    return _tintColor;
}
- (UIColor *)textColor {
    if (_textColor == nil) {
        _textColor = [UIColor blackColor];
    }
    
    return _textColor;
}
- (UIColor *)btnTextColor {
    if (_btnTextColor == nil) {
        _btnTextColor = [UIColor whiteColor];
    }
    
    return _btnTextColor;
}
@end
