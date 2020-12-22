//
//  UIColor+BWHelper.m
//  ImageTintAssistant
//
//  Created by hadlinks on 2020/12/22.
//  Copyright © 2020 BTStudio. All rights reserved.
//

#import "UIColor+BWHelper.h"

@implementation UIColor (BWHelper)

/// 从UIColor中获取RGB值及Alpha值
/// @Returns RGB值及Alpha值, 字典格式: @{ @"R" : @"255", @"G" : @"255", @"B" : @"255", @"A" : @"1.0" }
- (NSDictionary *)getRGBDictionary {
    CGFloat r = 0, g = 0, b = 0, a = 0;
    if ([UIColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [self getRed:&r green:&g blue:&b alpha:&a];
    } else {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    
    UInt8 red = (UInt8)(r * 255);
    UInt8 green = (UInt8)(g * 255);
    UInt8 blue = (UInt8)(b * 255);
    return @{ @"R" : @(red), @"G" : @(green), @"B" : @(blue), @"A" : @(a) };
}

@end
