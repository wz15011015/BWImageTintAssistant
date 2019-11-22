//
//  NSImage+Helper.swift
//  ImageTintAssistant-Mac
//
//  Created by hadlinks on 2019/11/21.
//  Copyright © 2019 BTStudio. All rights reserved.
//

import Cocoa

extension NSImage {
    
    /**
        1. 便利构造函数 (允许返回nil)
        - 正常的构造函数一定会创建对象;
        - 判断给定的参数是否符合条件,如果不符合条件,就直接返回nil,不会创建对象,减少内存开销.

        2. 便利构造函数中使用 self.init 构造当前对象
        - 只有在便利构造函数中才调用self.init ;
        - 没有 convenience 关键字修饰的构造函数是负责创建对象的;
        - 有 convenience 关键字修饰的构造函数是用来检查条件的,本身不负责对象的创建.

        3. 如果要在便利构造函数中使用 当前对象 的属性,一定要在 self.init 之后.
    */
    
    /// 给图片添加颜色滤镜
    /// - Parameter sourceImage: 源图片
    /// - Parameter tintColor: 滤镜颜色
    convenience init?(sourceImage: NSImage, tintColor: NSColor) {
        let size = sourceImage.size
        
        // 针对Retina屏幕,宽高都除以2,以保证处理后的图像保持原始大小
        let halfSize = NSSize(width: size.width / 2.0, height: size.height / 2.0)
        
        // 初始化图像
        self.init(size: halfSize)
        
        // 图像目标尺寸
        let rect = NSRect(x: 0, y: 0, width: halfSize.width, height: halfSize.height)
        // 图像源尺寸
        let fromRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        
        
        // lockFocus()使用屏幕属性,普通屏幕为 72dpi,视网膜屏幕为 144dpi
        lockFocus()
        
        tintColor.drawSwatch(in: rect)
        
        // rect: 图像目标尺寸
        // fromRect: 图像源尺寸,如果传入NSZeroRect,则为整个源图像大小
        // operation: destinationOver能保留灰度信息,destinationIn能保留透明度信息
        // fraction: 图片的不透明度,范围0.0 ~ 1.0
        sourceImage.draw(in: rect, from: fromRect, operation: .destinationIn, fraction: 1.0)
        
        unlockFocus()
    }
}
