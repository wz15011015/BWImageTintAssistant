//
//  ITACommon.swift
//  ImageTintAssistant
//
//  Created by hadlinks on 2019/10/26.
//  Copyright © 2019 BTStudio. All rights reserved.
//

import Foundation
import UIKit


// MARK: - Print
/// 开发的时候打印，但是发布的时候不打印,使用方法，输入print(message: "输入")
///
/// - Parameters:
///   - message: 消息
///   - fileName: 文件名称
///   - methodName: 方法名称
///   - lineNumber: 行号
func print<T>(message: T, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
    #if DEBUG
    // 获取当前时间
    let now = Date()
    // 创建一个日期格式器
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    // 要把路径最后的字符串截取出来
    let lastName = ((fileName as NSString).pathComponents.last!)
    print("\(formatter.string(from: now)) [\(lastName):\(lineNumber)] \(message)")
    #endif
}


// MARK: - 设备类型 & 设备屏幕的宽高/类型/适配比例
// MARK: 屏幕宽高
let ScreenWidth  = UIScreen.main.bounds.size.width
let ScreenHeight = UIScreen.main.bounds.size.height
let ScreenMaxLength = max(ScreenWidth, ScreenHeight)
let ScreenMinLength = min(ScreenWidth, ScreenHeight)

// MARK: 设备类型
let Is_iPhone  = (UI_USER_INTERFACE_IDIOM() == .phone)
let Is_iPad    = (UI_USER_INTERFACE_IDIOM() == .pad)
let Is_TV      = (UI_USER_INTERFACE_IDIOM() == .tv)
let Is_CarPlay = (UI_USER_INTERFACE_IDIOM() == .carPlay)

// MARK: 屏幕类型
let IsRetina      = (UIScreen.main.scale == 2.0)
let IsSuperRetina = (UIScreen.main.scale == 3.0)

let Is_iPhone_4   = (Is_iPhone && ScreenMaxLength < 568.0)
let Is_iPhone_5   = (Is_iPhone && ScreenMaxLength == 568.0)
let Is_iPhone_6   = (Is_iPhone && ScreenMaxLength == 667.0)
let Is_iPhone_6p  = (Is_iPhone && ScreenMaxLength == 736.0)
let Is_iPhone_X   = (Is_iPhone && ScreenMaxLength == 812.0)
let Is_iPhone_XR  = (Is_iPhone && IsRetina && ScreenMaxLength == 896.0)
let Is_iPhone_XS_MAX   = (Is_iPhone && IsSuperRetina && ScreenMaxLength == 896.0)
let Is_iPhone_X_Series = (Is_iPhone_X || Is_iPhone_XR || Is_iPhone_XS_MAX)

/// iPhoneX系列,NavigationBar增加的高度
///
/// iPhoneX系列中,NavigationBar高度增加了24
/// - Returns: 增加的高度
func NavBarHeightAdded() -> Double {
    if Is_iPhone_X_Series {
        return 24.0
    }
    return 0.0
}

/// iPhoneX系列,TabBar增加的高度
///
/// iPhoneX系列中,TabBar高度增加了34
/// - Returns: 增加的高度
func TabBarHeightAdded() -> Double {
    if Is_iPhone_X_Series {
        return 34.0
    }
    return 0.0
}

let NavBarHeight = 64.0 + NavBarHeightAdded()
let TabBarHeight = 49.0 + TabBarHeightAdded()


// MARK: - 颜色
func RGBAColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
    return UIColor.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
}

func RGBColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
    return RGBAColor(red, green, blue, 1.0)
}


// MARK: - UserDefaults操作
let BWUserDefaults = UserDefaults.standard
func UserDefaultsRead(_ key: String) -> String {
    return BWUserDefaults.string(forKey: key)!
}

func UserDefaultsWrite(_ obj: Any, _ key: String) {
    BWUserDefaults.set(obj, forKey: key)
}

func UserValue(_ key: String) -> Any? {
    return BWUserDefaults.value(forKey: key)
}


// MARK: - 通知
/// 注册通知
func NotificationAdd(observer: Any, selector: Selector, name: String) {
    return NotificationCenter.default.addObserver(observer, selector: selector, name: Notification.Name(rawValue: name), object: nil)
}

/// 发送通知
func NotificationPost(name: String, object: Any) {
    return NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: object)
}

/// 移除通知
func NotificationRemove(observer: Any, name: String) {
    return NotificationCenter.default.removeObserver(observer, name: Notification.Name(rawValue: name), object: nil)
}


// MARK: - 空值判断
/// 字符串判空
func StringIsEmpty(_ string: String!) -> Bool {
    if string.isEmpty { // ""
        return true
    }
    if string == nil {
        return true
    }
    if string == "(null)" || string == "<null>" {
        return true
    }
    return false
}

/// 字符串判空,如果为空则返回""
func StringConfirm(_ string: String) -> String {
    return StringIsEmpty(string) ? "" : string
}

/// 数组判空
func ArrayIsEmpty(_ array: [String]) -> Bool {
    let str: String! = array.joined(separator: "")
    if str == nil {
        return true
    }
    if str == "(null)" || str == "<null>" {
        return true
    }
    if array.isEmpty {
        return true
    }
    return false
}

/// 字典判空
func DictionaryIsEmpty(_ dictionary: NSDictionary) -> Bool {
    let str: String! = "\(dictionary)"
    if str == nil {
        return true
    }
    if str == "(null)" || str == "<null>" {
        return true
    }
    if dictionary.isKind(of: NSNull.self) {
        return true
    }
    if dictionary.allKeys.count == 0 {
        return true
    }
    return false
}

