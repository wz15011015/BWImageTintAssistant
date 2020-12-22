//
//  UIImage+BWHelper.m
//  ImageTintAssistant
//
//  Created by hadlinks on 2020/12/22.
//  Copyright © 2020 BTStudio. All rights reserved.
//

#import "UIImage+BWHelper.h"

@implementation UIImage (BWHelper)

/// 获取图片的主色调
- (UIColor *)mainColor {
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    
    CGSize thumbSize = CGSizeMake(self.size.width, self.size.height);
    
    // 先把图片缩小以加快计算速度,但越小结果的误差可能越大
//    CGSize thumbSize = CGSizeMake(self.size.width / 2, self.size.height / 2);
    
    // 创建一个位图
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, thumbSize.width, thumbSize.height, 8, thumbSize.width * 4, colorSpace, bitmapInfo);
    
    // 将图片画到位图中
    CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
    CGContextDrawImage(context, drawRect, self.CGImage);
    CGColorSpaceRelease(colorSpace);
    
    // 取每个点的像素值
    unsigned char* data = CGBitmapContextGetData(context);
    if (data == NULL) {
        return [UIColor clearColor];
    }
    
    NSCountedSet *colorSet = [NSCountedSet setWithCapacity:thumbSize.width * thumbSize.height];
    for (int x = 0; x < thumbSize.width; x++) {
        for (int y = 0; y < thumbSize.height; y++) {
            int offset = 4 * (x + y * thumbSize.width);
            
            // 减少计算量
//            int offset = 4 * x * y;
            
            int red   = data[offset];
            int green = data[offset + 1];
            int blue  = data[offset + 2];
            int alpha = data[offset + 3];
            
            if (alpha > 0) { // 去除透明色
                if (!(red == 255 && green == 255 && blue == 255)) { // 去除白色
                    NSArray *rgba = @[@(red), @(green), @(blue), @(alpha)];
                    [colorSet addObject:rgba];
                }
            }
        }
    }
    CGContextRelease(context);
    
    // 找到次数出现最多的颜色
    NSEnumerator *enumerator = [colorSet objectEnumerator];
    NSUInteger maxCount = 0;
    NSArray *maxColor = nil;
    NSArray *tmpColor = nil;
    while ((tmpColor = [enumerator nextObject]) != nil) {
        NSUInteger tmpCount = [colorSet countForObject:tmpColor];
        if (tmpCount < maxCount) {
            continue;
        }
        maxCount = tmpCount;
        maxColor = tmpColor;
    }
    
    CGFloat r = [maxColor[0] intValue] / 255.0;
    CGFloat g = [maxColor[1] intValue] / 255.0;
    CGFloat b = [maxColor[2] intValue] / 255.0;
    CGFloat a = [maxColor[3] intValue];
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
