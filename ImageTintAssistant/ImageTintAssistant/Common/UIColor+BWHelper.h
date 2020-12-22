//
//  UIColor+BWHelper.h
//  ImageTintAssistant
//
//  Created by hadlinks on 2020/12/22.
//  Copyright © 2020 BTStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (BWHelper)

/// 从UIColor中获取RGB值及Alpha值
/// @Returns RGB值及Alpha值, 字典格式: @{ @"R" : @"255", @"G" : @"255", @"B" : @"255", @"A" : @"1.0" }
- (NSDictionary *)getRGBDictionary;

@end

NS_ASSUME_NONNULL_END
