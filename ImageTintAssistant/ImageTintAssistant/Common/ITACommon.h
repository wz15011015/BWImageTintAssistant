//
//  ITACommon.h
//  ImageTintAssistant
//
//  Created by hadlinks on 2019/10/26.
//  Copyright © 2019 BTStudio. All rights reserved.
//

#ifndef ITACommon_h
#define ITACommon_h


#pragma mark - NSLog: 重新定义系统的NSLog,__OPTIMIZE__是release默认会加的宏

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...)
#endif


#pragma mark - 设备屏幕宽高/类型/屏幕类型/适配比例

// MARK: 屏幕宽高
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

// MARK: 设备类型
#define IS_IPAD   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_TV     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomTV)
#define IS_CAR_PLAY (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomCarPlay)

// MARK: 屏幕类型
#define IS_RETINA       ([[UIScreen mainScreen] scale] == 2.0)
#define IS_SUPER_RETINA ([[UIScreen mainScreen] scale] == 3.0)

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5  (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6  (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X  (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)
#define IS_IPHONE_XR (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0 && IS_RETINA)
#define IS_IPHONE_XS_MAX   (IS_IPHONE && SCREEN_MAX_LENGTH == 896.0 && IS_SUPER_RETINA)
#define IS_IPHONE_X_SERIES (IS_IPHONE_X || IS_IPHONE_XR || IS_IPHONE_XS_MAX)

/**
 NavigationBar增加的高度
 
 * iPhoneX中,NavigationBar高度增加了24
 */
#define NavBarHeightAdded \
({ \
    CGFloat addedH = 0; \
    if (IS_IPHONE_X_SERIES) { \
        addedH = 24; \
    } \
    (addedH); \
}) \

/**
 TabBar增加的高度
 
 * iPhoneX中,TabBar高度增加了34
 */
#define TabBarHeightAdded \
({ \
    CGFloat addedH = 0; \
    if (IS_IPHONE_X_SERIES) { \
        addedH = 34; \
    } \
    (addedH); \
}) \

/**
 frame中y值的适配
 
 * 有返回值的宏定义
 * 适配iPhoneX时,需增加24
 
 @param y frame中y值
 @return newY 适配后的y值
 */
#define MultiScreenY(y) \
({ \
    CGFloat newY = y + NavBarHeightAdded; \
    (newY); \
}) \

#define NAVIGATION_BAR_HEIGHT MultiScreenY(64.0)
#define TAB_BAR_HEIGHT        (49.0 + TabBarHeightAdded)


#pragma mark - 颜色

#define RGBAColor(r, g, b, a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a)]
#define RGBColor(r, g, b)     RGBAColor(r, g, b, 1.0)
#define RGBColorHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]


#pragma mark - 判空

#define IS_NULL_STRING(string) ([string isKindOfClass:[NSNull class]] || string == nil || [string isEqualToString:@""])
#define CONFIRM_STRING(string) (([string isKindOfClass:[NSNull class]] || string == nil) ? @"" : string)
#define IS_NULL_OBJECT(object) ([object isKindOfClass:[NSNull class]] || object == nil)
#define CONFIRM_NUMBER(number) (IS_NULL_OBJECT(number) ? @0 : number)


#pragma mark - NSUserDefaults

#define BWUserDefaults [NSUserDefaults standardUserDefaults]


#pragma mark - 通知

#define BWNotificationCenter [NSNotificationCenter defaultCenter]


#pragma mark - 弱引用

#define TYPE_WEAK_SELF __weak typeof(self) weakSelf = self



#endif /* ITACommon_h */

