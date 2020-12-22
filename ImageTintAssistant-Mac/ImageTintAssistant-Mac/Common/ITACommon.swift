//
//  ITACommon.swift
//  ImageTintAssistant-Mac
//
//  Created by wangzhi on 2019/11/21.
//  Copyright © 2019 BTStudio. All rights reserved.
//

import Cocoa


// MARK: - 颜色

func RGBAColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> NSColor {
    return NSColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
}

func RGBColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> NSColor {
    return RGBAColor(red, green, blue, 1.0)
}

/// 获取颜色的 R / G / B / A 值
/// - Parameter color: 颜色
/// - Returns: (R, G, B, A)元组, 元素类型: Int
func RGBAComponentsFromColor(_ color: NSColor) -> (Int, Int, Int, Int) {
//    print("color's colorSpace: \(color.colorSpace)")
    
    if color.colorSpace == .deviceRGB ||
        color.colorSpace == .genericRGB ||
        color.colorSpace == .sRGB {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let red   = Int(r * 255)
        let green = Int(g * 255)
        let blue  = Int(b * 255)
        let alpha = Int(a)
        return (red, green, blue, alpha)
    }
    return (0, 0, 0, 0)
}


// MARK: - Dark Mode 暗黑模式判断

func isDarkMode() -> Bool {
    let appearance = NSApp.effectiveAppearance
    if #available(macOS 10.14, *) {
        return appearance.bestMatch(from: [.darkAqua, .aqua]) == NSAppearance.Name.darkAqua
    } else {
        return false
    }
}
