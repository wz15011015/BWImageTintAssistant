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
            self.tintButton.layer?.backgroundColor = self.tintColor?.cgColor
            self.tintButton.wantsLayer = true
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
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
