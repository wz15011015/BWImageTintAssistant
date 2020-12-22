//
//  NSImage+Helper.swift
//  ImageTintAssistant-Mac
//
//  Created by wangzhi on 2019/11/21.
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
        /// NSImage的size属性:
        /// 文件名                        size
        /// xxx.png             等于实际像素大小
        /// xxx@2x.png     等于实际像素大小的一半
        /// xxx@3x.png     等于实际像素大小的1/3
        /// 以此类推...
        let size = sourceImage.size
        
        // 获取实际像素大小 (通过CGImage获取)
        var pixelSize = size
        if let cgImageRef = sourceImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            pixelSize = NSSize(width: cgImageRef.width, height: cgImageRef.height)
        }
        
        // 1. 目标图像尺寸
        // 屏幕倍数(几倍屏)
        var screenScale = NSScreen.main?.backingScaleFactor ?? 1.0
        // 在外接显示器屏幕上时,获取的screenScale为1.0,会导致处理后的图像尺寸错误,所以设置screenScale=2.0
        screenScale = 2.0
        let targetSize = NSSize(width: pixelSize.width / screenScale, height: pixelSize.height / screenScale)
        
        // 目标图像尺寸
        let targetRect = NSRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        // 源图像尺寸
        let fromRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        
        print("size: (\(size.width), \(size.height)), size (pixel): (\(pixelSize.width), \(pixelSize.height))")
        
        // 2. 初始化图像
        self.init(size: targetSize)
        
        // 3. 创建目标图像并绘制
        // lockFocus()使用屏幕属性,普通屏幕为 72dpi,视网膜屏幕为 144dpi
        lockFocus()
        tintColor.drawSwatch(in: targetRect)
        // targetRect: 图像目标尺寸
        // fromRect: 图像源尺寸,如果传入NSZeroRect,则为整个源图像大小
        // operation: destinationOver能保留灰度信息,destinationIn能保留透明度信息
        // fraction: 图片的不透明度,范围0.0 ~ 1.0
        sourceImage.draw(in: targetRect, from: fromRect, operation: .destinationIn, fraction: 1.0)
        unlockFocus()
    }
    
    /// 给图片添加圆角
    /// - Parameter sourceImage: 源图片
    /// - Parameter radius: 圆角半径
    convenience init?(sourceImage: NSImage, radius: CGFloat) {
        let size = sourceImage.size
        
        if let cgImageRef = sourceImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            // 获取实际像素大小 (通过CGImage获取)
            let pixelSize = NSSize(width: cgImageRef.width, height: cgImageRef.height)
            
            // 1. 目标图像尺寸
            let screenScale: CGFloat = 2.0 // 屏幕倍数(几倍屏)
            let targetSize = NSSize(width: pixelSize.width / screenScale, height: pixelSize.height / screenScale)
            let targetRect = NSRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
            
            // 2. 初始化图像
            self.init(size: targetSize)
            
            // 3. 创建目标图像并绘制
            // lockFocus()使用屏幕属性,普通屏幕为 72dpi,视网膜屏幕为 144dpi
            lockFocus()
            
            // 创建裁切路径
            let path = NSBezierPath(roundedRect: targetRect, xRadius: radius, yRadius: radius)
            // 添加裁切路径
            path.addClip()
            // 绘制图像
            let cgContext = NSGraphicsContext.current?.cgContext
            cgContext?.draw(cgImageRef, in: targetRect)
            
            unlockFocus()
        } else {
            // 初始化图像
            self.init(size: size)
        }
    }
    
    
    /// 图片的主色调
    var mainColor: NSColor {
        // 获取图片信息
        let imageWidth = Int(self.size.width / 2.0)
        let imageHeight = Int(self.size.height / 2.0)
        
        // 位图的大小 = 图片宽 * 图片高 * 图片中每个点包含的信息量(4个信息量: R G B A)
        let bitmapByteCount = imageWidth * imageHeight * 4
        
        // 根据位图大小,申请内存空间
        let bitmapData = malloc(bitmapByteCount)
        defer {
            free(bitmapData)
        }
        
        // 使用系统的颜色空间
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 创建一个位图
        let context = CGContext(data: bitmapData, width: imageWidth, height: imageHeight, bitsPerComponent: 8, bytesPerRow: imageWidth * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        // 图片的rect
        let rect = NSRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        guard let cgImageRef = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return NSColor.clear
        }
        
        // 将图片画到位图中
        context?.draw(cgImageRef, in: rect)
        
        // 获取位图数据
        let bitData = context?.data
        let data = unsafeBitCast(bitData, to: UnsafePointer<CUnsignedChar>.self)
        
        // 颜色集合
        let colorSet = NSCountedSet.init(capacity: imageWidth * imageHeight)
        for x in 0..<imageWidth {
            for y in 0..<imageHeight {
                let offset = (y * imageWidth + x) * 4
                
                let red   = (data + offset).pointee
                let green = (data + offset + 1).pointee
                let blue  = (data + offset + 2).pointee
                let alpha = (data + offset + 3).pointee
                
                if alpha > 0 { // 去除透明色
                    if !(red == 255 && green == 255 && blue == 255) { // 去除白色
                        colorSet.add([CGFloat(red), CGFloat(green), CGFloat(blue), CGFloat(alpha)])
                    }
                }
            }
        }
        
        // 找到次数出现最多的颜色
        let enumerator = colorSet.objectEnumerator()
        var maxCount = 0
        var maxColor: Array<CGFloat>? = nil
        while let tmpColor = enumerator.nextObject() {
            let tmpCount = colorSet.count(for: tmpColor)
            if tmpCount >= maxCount {
                maxCount = tmpCount
                maxColor = tmpColor as? Array<CGFloat>
            }
        }
        
        guard let color = maxColor else {
            return NSColor.clear
        }
        return NSColor.init(red: (color[0] / 255.0), green: (color[1] / 255.0), blue: (color[2] / 255.0), alpha: (color[3] / 255.0))
    }
}
