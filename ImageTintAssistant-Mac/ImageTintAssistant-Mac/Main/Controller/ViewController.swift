//
//  ViewController.swift
//  ImageTintAssistant-Mac
//
//  Created by hadlinks on 2019/11/20.
//  Copyright © 2019 BTStudio. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var originalImageButton: NSButton! // 原始图片
    @IBOutlet var rgbView: ITARGBInputView!; // 颜色值输入视图
    @IBOutlet var tintButton: NSButton! // 着色按钮
    @IBOutlet var tintedImageButton: NSButton! // 着色后图片
    
    private var originalImage: NSImage? // 原图片
    private var tintImage: NSImage? // 着色图片
    private var tintColor: NSColor? // 着色颜色
    
    private var red: Int = 0
    private var green: Int = 0
    private var blue: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化
        originalImage = NSImage(named: "example_icon.png")
        tintImage = originalImage
        tintColor = RGBColor(0, 0, 0)
        
        rgbView.rgbColorHandler = { (color: NSColor, red: Int, green: Int, blue: Int) in
            self.tintColor = color
            self.red = red
            self.green = green
            self.blue = blue
            
            // 更新按钮背景颜色
            self.tintButton.wantsLayer = true
            self.tintButton.layer?.backgroundColor = self.tintColor?.cgColor
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func viewWillLayout() {
        super.viewWillLayout()
        
        /**
         * Mac开发之Dark Mode适配 (https://blog.csdn.net/pbfl98/article/details/101101264)
         *
         * 1. 苹果在10.14版本中添加了主题设置功能，用户可以将主题切换为Dark Mode，切换后系统应用都会自动变成深色。
         *
         * 2. 颜色适配
         *  - 对于颜色的适配，官方文档介绍了两种方法，一种是使用系统的语义颜色（semantic colors）代替固定的颜色值。
         *  例如[NSColor labelColor],[NSColor windowBackgroundColor]使用这类语义颜色系统会自动根据当前的主题使用合适的颜色值进行渲染。
         *  也就是说它们表现出的实际颜色会随着当前主题变化而变化。
         *  所以该方法很简单，工作量也少，但是缺点也很明显：系统提供的颜色有限，不能满足所有应用场景。
         *
         *  - 第二种方法是使用Color Asset，在Assets.xcassets中创建Color Set，设置不同主题下不同的颜色值。
         *    - Any Appearance：macOS Mojave 10.14.2系统以下版本的颜色值；
         *    - Light Appearance:  浅色模式下的颜色值；
         *    - Dark Appearance：深色模式下的颜色值；
         *
         *  在应用中通过color name获取颜色：
         *  // 该方法只能用于macOS 10.13及以上的系统
         *  NSColor *color = [NSColor colorNamed:@"text_color"];
         *
         *  该方法和系统的语义颜色一样，会根据当前的主题自动适配。但是有个前提：直接使用NSColor设置颜色值。例如：
         *  NSColor *color = [NSColor colorNamed:@"text_color"];
         *  [textField setTextColor:color];
         *
         *  如果是使用CGColor设置颜色值，则不会有效果。例如设置NSViewController的背景颜色：
         *  self.view.wantsLayer = YES;
         *  self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
         */
        
        /// 适配 Dark Mode
        /// 当切换主题时，系统会让window和view重新绘制，对于NSViewController, 会自动调用viewWillLayout和viewDidLayout方法，
        /// 对于NSView，会自动调用drawRect:方法。
        
        // 1. ViewController背景颜色
        var vcBackgroundColor = RGBColor(236, 236, 236)
        // 2. 图片背景颜色
        var iconImageBackgroundColor = RGBColor(228, 228, 228)
        
        if isDarkMode() {
            vcBackgroundColor = RGBColor(42, 43, 43)
            iconImageBackgroundColor = RGBColor(52, 53, 53)
        }
        
        view.wantsLayer = true
        view.layer?.backgroundColor = vcBackgroundColor.cgColor
        
        originalImageButton.wantsLayer = true
        tintedImageButton.wantsLayer = true
        originalImageButton.layer?.backgroundColor = iconImageBackgroundColor.cgColor
        tintedImageButton.layer?.backgroundColor = iconImageBackgroundColor.cgColor
    }
}

// MARK: - Events

extension ViewController {
    
    /// 添加要着色图片事件
    @IBAction func originalImageTap(_ sender: NSButton) {
        // 文件打开面板
        let panel = NSOpenPanel()
        panel.message = "选择要着色的图标"
        panel.prompt = "Select" // 自定义确定按钮文字
        panel.allowedFileTypes = ["png"]
        panel.allowsOtherFileTypes = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(string: "~/Desktop") // 默认打开路径
        panel.beginSheetModal(for: NSApp.mainWindow!) { (response: NSApplication.ModalResponse) in
            if response == .OK { // 选取了文件
                guard let url = panel.urls.first,
                    let image = NSImage(contentsOfFile: url.path) else {
                    return
                }
                self.originalImage = image
                self.originalImageButton.image = image
            } else if response == .cancel { // 取消
                
            }
        }
    }
    
    /// 着色事件
    @IBAction func tintImageEvent(_ sender: NSButton) {
        guard let originalImage = originalImage,
            let tintColor = tintColor else {
            return
        }
        
        // 图片着色
        tintImage = NSImage(sourceImage: originalImage, tintColor: tintColor)
        
        // 显示着色图片
        tintedImageButton.image = tintImage
    }
    
    /// 导出着色图片事件
    @IBAction func tintImageTap(_ sender: NSButton) {
        // 生成默认保存文件名
        let imageFileName = "tint_image_RGB(\(red),\(green),\(blue))"
        
        // 文件保存面板
        let panel = NSSavePanel()
        panel.message = "保存着色后的图标"
        panel.allowedFileTypes = ["png"]
        panel.directoryURL = URL(string: "~/Desktop") // 默认保存路径
//        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory().appending("/Desktop"))
        panel.nameFieldStringValue = imageFileName // 默认保存文件名
        panel.beginSheetModal(for: NSApp.mainWindow!) { (response: NSApplication.ModalResponse) in
            if response == .OK {
                guard let url = panel.url else {
                    return
                }
                let imageData = self.tintImage?.tiffRepresentation
                try? imageData?.write(to: url)
            }
        }
    }
}
