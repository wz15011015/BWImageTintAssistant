//
//  ITACommon.swift
//  ImageTintAssistant-Mac
//
//  Created by hadlinks on 2019/11/21.
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
