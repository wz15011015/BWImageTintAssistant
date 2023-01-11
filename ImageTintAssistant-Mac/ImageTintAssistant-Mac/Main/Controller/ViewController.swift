//
//  ViewController.swift
//  ImageTintAssistant-Mac
//
//  Created by wangzhi on 2019/11/20.
//  Copyright © 2019 BTStudio. All rights reserved.
//

import Cocoa
import CoreImage

/// 编辑图片的状态
enum EditedImageState {
    case tint      // 着色状态
    case corner    // 圆角状态
    case qrcode    // 二维码状态
}

private let mainColorDefaultTitle = NSLocalizedString("tap to get main color", comment: "")

class ViewController: NSViewController {
    
    @IBOutlet var originalImageButton: NSButton! // 原始图片
    
    @IBOutlet var mainColorButton: NSButton! // 获取图片主色调按钮
    @IBOutlet var loadingIndicator: NSProgressIndicator! // 加载指示器
    
    @IBOutlet var rgbView: ITARGBInputView!; // 颜色值输入视图
    @IBOutlet var tintButton: NSButton! // 着色按钮
    @IBOutlet var cornerRadiusTextField: NSTextField! // 圆角半径输入框
    @IBOutlet var qrCodeContentTextField: NSTextField! // 二维码内容输入框
    @IBOutlet var editedImageButton: NSButton! // 编辑后的图片
    
    private var originalImage: NSImage? // 原图片
    private var tintImage: NSImage? // 着色图片
    private var cornerRadiusImage: NSImage? // 圆角图片
    private var qrCodeImage: NSImage? // 二维码图片
    
    // 着色颜色RGB值
    private var red: Int = 0
    private var green: Int = 0
    private var blue: Int = 0
    
    // 圆角半径
    private var cornerRadius: Float = 0.0
    
    /// 当前编辑图片的状态
    private var editedImageState = EditedImageState.tint
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // 初始化
        originalImage = NSImage(named: "add_icon.png")
        
        // RGB值改变时的回调
        rgbView.rgbColorHandler = { (color: NSColor, red: Int, green: Int, blue: Int) in
            self.red = red
            self.green = green
            self.blue = blue

            // 着色颜色
            let tintColor = RGBColor(CGFloat(red), CGFloat(green), CGFloat(blue))
            
            // 更新按钮背景颜色
            self.tintButton.wantsLayer = true
            self.tintButton.layer?.backgroundColor = tintColor.cgColor
        }
        
        // RGB值确认的回调
        rgbView.rgbColorConfirmHandler = { (color: NSColor, red: Int, green: Int, blue: Int) in
            self.tintImageEvent(self.tintButton)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        cornerRadiusTextField.resignFirstResponder()
        qrCodeContentTextField.resignFirstResponder()
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
            iconImageBackgroundColor = RGBColor(82, 83, 83)
        }
        
        view.wantsLayer = true
        view.layer?.backgroundColor = vcBackgroundColor.cgColor
        
        originalImageButton.wantsLayer = true
        editedImageButton.wantsLayer = true
        originalImageButton.layer?.backgroundColor = iconImageBackgroundColor.cgColor
        editedImageButton.layer?.backgroundColor = iconImageBackgroundColor.cgColor
    }
}


// MARK: - UI

private extension ViewController {
    
    func setupUI() {
        // 设置按钮的鼠标悬停提示文字
        originalImageButton.toolTip = NSLocalizedString("Click to add icon", comment: "")
        
        // 设置主色调按钮标题
        mainColorButton.title = mainColorDefaultTitle
        
        // 着色按钮背景色初始化为黑色
        tintButton.wantsLayer = true
        tintButton.layer?.backgroundColor = NSColor.black.cgColor
        
        // 设置输入框代理
        cornerRadiusTextField.delegate = self
        cornerRadiusTextField.placeholderString = NSLocalizedString("Enter the corner radius and press enter", comment: "")
        cornerRadiusTextField.toolTip = NSLocalizedString("Enter the corner radius and press enter", comment: "")
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        cornerRadiusTextField.formatter = formatter
        
        qrCodeContentTextField.delegate = self
        qrCodeContentTextField.placeholderString = NSLocalizedString("Enter the text and press enter to generate the QR code", comment: "")
        qrCodeContentTextField.toolTip = NSLocalizedString("Enter the text and press enter to generate the QR code", comment: "")
    }
}


// MARK: - Events

extension ViewController {
    
    /// 添加要着色图片事件
    @IBAction func addImageEvent(_ sender: NSButton) {
        // 文件打开面板
        let panel = NSOpenPanel()
        panel.message = NSLocalizedString("Please select the icon to be tint", comment: "")
        panel.prompt = NSLocalizedString("Select", comment: "") // 自定义确定按钮文字
        panel.allowedFileTypes = ["png"]
        panel.allowsOtherFileTypes = false
        panel.allowsMultipleSelection = false
        // 默认打开路径 (不设置时,为上次记录的路径)
//        panel.directoryURL = URL(string: "~/Desktop")
//        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory().appending("/Desktop"))
        panel.beginSheetModal(for: NSApp.mainWindow!) { (response: NSApplication.ModalResponse) in
            if response == .OK { // 选取了文件
                guard let url = panel.urls.first,
                    let image = NSImage(contentsOfFile: url.path) else {
                    return
                }
                self.originalImage = image
                self.originalImageButton.image = image
                
                self.mainColorButton.title = mainColorDefaultTitle
                self.mainColorButton.isEnabled = true
                
            } else if response == .cancel { // 取消
                
            }
        }
    }
    
    /// 获取图标主色调事件
    @IBAction func getImageMainColorEvent(_ sender: NSButton) {
        guard let originalImage = originalImage else { return }
        
        loadingIndicator.startAnimation(nil)
        mainColorButton.title = ""
        
        // 切换到新线程中执行
        DispatchQueue.global(qos: .default).async {
            // 获取图片主色调
            let mainColor = originalImage.mainColor
            
            // 回到主线程更新UI
            DispatchQueue.main.async {
                let (r, g, b, a) = RGBAComponentsFromColor(mainColor)
                
                self.mainColorButton.title = "(\(r), \(g), \(b), \(a))"
                self.mainColorButton.isEnabled = false
                
                self.loadingIndicator.stopAnimation(nil)
            }
        }
    }
    
    /// 着色事件
    @IBAction func tintImageEvent(_ sender: NSButton) {
        guard let originalImage = originalImage else { return }
        
        // 设置为着色状态
        editedImageState = .tint
        
        // 着色颜色
        let tintColor = RGBColor(CGFloat(red), CGFloat(green), CGFloat(blue))
        
        // 图片着色
        tintImage = NSImage(sourceImage: originalImage, tintColor: tintColor)
        
        // 显示着色图片
        editedImageButton.image = tintImage
        
        // 设置点击时的图片
        /// 当按钮类型为Momentary Change时,设置image和alternateImage为同一个图片,
        /// 即可实现点击时不显示高亮效果.
        editedImageButton.alternateImage = tintImage
        // 设置按钮的鼠标悬停提示文字
        editedImageButton.toolTip = NSLocalizedString("Click to save tinted icon", comment: "")
    }
    
    /// 导出着色图片事件
    @IBAction func saveImageEvent(_ sender: NSButton) {
        switch editedImageState {
            case .corner:
                saveCornerRadiusImageEvent()
            case .qrcode:
                saveQRCodeImageEvent()
            default:
                saveTintedImageEvent()
        }
    }
    
    /// 图片添加圆角
    func cornerRadiusImage(radius: Float) {
        if radius <= 0 {
            return
        }
        
        guard let image = originalImage else { return }
        print("准备添加圆角的图片的大小: (\(image.size.width), \(image.size.height))")
        
        let length = Float(max(image.size.width, image.size.height))
        if radius > (length * 0.5) {
            BWHUDView.show(message: NSLocalizedString("The corner radius is too large", comment: ""), type: .failure)
            return
        }
        
        // 设置为圆角状态
        editedImageState = .corner
        
        // 图片添加圆角
        cornerRadiusImage = NSImage(sourceImage: image, radius: CGFloat(radius))
        
        // 显示圆角图片
        editedImageButton.image = cornerRadiusImage
        
        // 设置点击时的图片
        /// 当按钮类型为Momentary Change时,设置image和alternateImage为同一个图片,
        /// 即可实现点击时不显示高亮效果.
        editedImageButton.alternateImage = cornerRadiusImage
        // 设置按钮的鼠标悬停提示文字
        editedImageButton.toolTip = NSLocalizedString("Click to save round corner icon", comment: "")
    }
    
    /// 根据文本内容生成二维码
    func generateQRCode(text: String) {
        // 设置为二维码状态
        editedImageState = .qrcode
        
        // 生成二维码图片
        qrCodeImage = generateQRCodeImage(text: text)
        
        // 显示二维码图片
        editedImageButton.image = qrCodeImage
        
        // 设置点击时的图片
        /// 当按钮类型为Momentary Change时,设置image和alternateImage为同一个图片,
        /// 即可实现点击时不显示高亮效果.
        editedImageButton.alternateImage = qrCodeImage
        // 设置按钮的鼠标悬停提示文字
        editedImageButton.toolTip = NSLocalizedString("Click to save QR Code image", comment: "")
    }
    
    /// 导出着色图片事件
    func saveTintedImageEvent() {
        guard tintImage != nil else { return }
        
        // 文件保存面板
        let panel = NSSavePanel()
        panel.message = NSLocalizedString("Save the tinted icon", comment: "")
        panel.prompt = NSLocalizedString("Save", comment: "")
        panel.allowedFileTypes = ["png"]
        panel.nameFieldStringValue = "tinted_image_\(red)_\(green)_\(blue)" // 默认保存文件名
        panel.beginSheetModal(for: NSApp.mainWindow!) { (response: NSApplication.ModalResponse) in
            if response != .OK {
                return
            }
            guard let url = panel.url else {
                return
            }
            
            // https://blog.csdn.net/lovechris00/article/details/81103692#1_427
            
            if let image = self.tintImage,
               let cgImageRef = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                let bitmapImageRep = NSBitmapImageRep(cgImage: cgImageRef)
                //                bitmapImageRep.size = image.size
                // 强制指定像素宽高
                // pixelsWide == size.width && pixelsHigh == size.height 时,dpi为72
                // pixelsWide == 2 * size.width && pixelsHigh == 2 * size.height 时,dpi为144
                //                bitmapImageRep.pixelsWide = Int(image.size.width)
                //                bitmapImageRep.pixelsHigh = Int(image.size.height)
                let pngData = bitmapImageRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
                
                // 保存图片到本地
                try? pngData?.write(to: url)
            }
        }
    }
    
    /// 导出圆角图片事件
    func saveCornerRadiusImageEvent() {
        guard cornerRadiusImage != nil else { return }
        
        // 文件保存面板
        let panel = NSSavePanel()
        panel.message = NSLocalizedString("Save the round corner icon", comment: "")
        panel.prompt = NSLocalizedString("Save", comment: "")
        panel.allowedFileTypes = ["png"]
        panel.nameFieldStringValue = "round_corner_image_\(cornerRadius)" // 默认保存文件名
        panel.beginSheetModal(for: NSApp.mainWindow!) { (response: NSApplication.ModalResponse) in
            if response != .OK {
                return
            }
            guard let url = panel.url else {
                return
            }
            
            if let image = self.cornerRadiusImage,
                let cgImageRef = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                let bitmapImageRep = NSBitmapImageRep(cgImage: cgImageRef)
                let pngData = bitmapImageRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
                // 保存图片到本地
                try? pngData?.write(to: url)
            }
        }
    }
    
    /// 导出二维码图片事件
    func saveQRCodeImageEvent() {
        guard qrCodeImage != nil else { return }
        
        var dateStr = "xxx"
        if #available(macOS 10.15, *) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            dateStr = formatter.string(from: NSDate.now)
        }
        
        // 文件保存面板
        let panel = NSSavePanel()
        panel.message = NSLocalizedString("Save the QR Code image", comment: "")
        panel.prompt = NSLocalizedString("Save", comment: "")
        panel.allowedFileTypes = ["png"]
        panel.nameFieldStringValue = "QR_Code_image_\(dateStr)" // 默认保存文件名
        panel.beginSheetModal(for: NSApp.mainWindow!) { (response: NSApplication.ModalResponse) in
            if response != .OK {
                return
            }
            guard let url = panel.url else {
                return
            }
            
            if let image = self.qrCodeImage,
               let cgImageRef = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                let bitmapImageRep = NSBitmapImageRep(cgImage: cgImageRef)
                let pngData = bitmapImageRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
                // 保存图片到本地
                try? pngData?.write(to: url)
            }
        }
    }
}


// MARK: - NSTextFieldDelegate

extension ViewController: NSTextFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSStandardKeyBindingResponding.insertNewline(_:)) { // ENTER键
            if control == cornerRadiusTextField {
                cornerRadius = cornerRadiusTextField.floatValue
                cornerRadiusImage(radius: cornerRadius)
                
            } else if control == qrCodeContentTextField {
                let string = qrCodeContentTextField.stringValue
                if !string.isEmpty {
                    generateQRCode(text: string)
                }
            }
            
            return true // 自己处理了对应的按键操作时，返回true
            
        } else if commandSelector == #selector(NSStandardKeyBindingResponding.insertTab(_:)) { // TAB键
            
        } else if commandSelector == #selector(NSStandardKeyBindingResponding.cancelOperation(_:)) { // ESC键
            
        } else if commandSelector == #selector(NSStandardKeyBindingResponding.deleteBackward(_:)) { // DELETE键
            
        }
        
        return false // 默认返回false，表示其它按键操作不会自己处理，交给系统处理
    }
}


// MARK: - Tool Methods

extension ViewController {
    
    /// 根据文本内容生成二维码图片
    /// - Parameters:
    ///   - text: 文本内容
    func generateQRCodeImage(text: String) -> NSImage? {
        if text.isEmpty { return nil }
        guard let inputData = text.data(using: .utf8) else { return nil }
        
        // 创建过滤器
        let filter = CIFilter(name: "CIQRCodeGenerator")
        // 恢复默认设置
        filter?.setDefaults()
        // 设置输入信息
        filter?.setValue(inputData, forKeyPath: "inputMessage")
        // 输出图片
        let ciImage = filter?.outputImage
        
//        let image = createNSImageFromCIImage(ciImage: ciImage)
        let image = createNonInterpolatedNSImageFromCIImage(ciImage: ciImage, imageWidth: 1024.0)
        return image
    }
    
    /// 根据CIImage生成指定大小的NSImage
    /// - Parameters:
    ///   - image: CIImage
    ///   - imageWidth: 图片宽度(宽高相等)
    /// - Returns: NSImage
    func createNonInterpolatedNSImageFromCIImage(ciImage: CIImage?, imageWidth: Double) -> NSImage? {
        guard let ciImage = ciImage else { return nil }
        
        let extent = CGRectIntegral(ciImage.extent)
        let scale = min(imageWidth / extent.width, imageWidth / extent.height)
        
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciImage, from: extent)
        guard let cgImage = cgImage else { return nil }
        
        // 1. 创建bitmap
        let width = Int(extent.width * scale)
        let height = Int(extent.height * scale)
        // 使用系统的颜色空间
        let colorSpace = CGColorSpaceCreateDeviceGray()
        // 创建一个位图
        let bitmapContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        bitmapContext?.interpolationQuality = .none
        bitmapContext?.scaleBy(x: scale, y: scale)
        bitmapContext?.draw(cgImage, in: extent)
        
        // 2. 保存bitmap到图片
        let scaledCGImage = bitmapContext?.makeImage()
        let image = createNSImageFromCGImage(cgImage: scaledCGImage)
        
        return image
    }
    
    /// CGImage转NSImage
    /// - Parameter cgImage: CGImage
    /// - Returns: NSImage
    func createNSImageFromCGImage(cgImage: CGImage?) -> NSImage? {
        guard let cgImage = cgImage else { return nil }
        
        // 由于lockFocus()使用屏幕属性,普通屏幕为72dpi,视网膜屏幕为144dpi
        // 为了保证绘制出来的图像大小为实际像素大小,需要根据屏幕倍数进行处理:
        // 一倍屏幕: 绘制图像的宽高为指定目标图像宽高的一倍
        // 二倍屏幕: 绘制图像的宽高为指定目标图像宽高的两倍
        // 因此需要除以屏幕倍数,才能保证绘制图像的宽高为指定目标图像的宽高
        
        // CGImage实际像素大小
        let pixelSize = NSSize(width: cgImage.width, height: cgImage.height)
        // 屏幕倍数(几倍屏)
        let screenScale = NSScreen.main?.backingScaleFactor ?? 1.0
        // 目标图像尺寸
        let targetSize = NSSize(width: pixelSize.width / screenScale, height: pixelSize.height / screenScale)
        
        // 创建目标图像并绘制
        let imageRect = CGRect(x: 0.0, y: 0.0, width: targetSize.width, height: targetSize.height)
        let newImage = NSImage.init(size: imageRect.size)
        // 绘制图像
        newImage.lockFocus()
        let cgContext = NSGraphicsContext.current?.cgContext
        cgContext?.draw(cgImage, in: imageRect)
        newImage.unlockFocus()
        
        return newImage
    }
    
    /// CIImage转NSImage
    /// - Parameter ciImage: CIImage
    /// - Returns: NSImage
    func createNSImageFromCIImage(ciImage: CIImage?) -> NSImage? {
        guard let ciImage = ciImage else { return nil }
        
        // CIImage转CGImage
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        // CGImage转NSImage
        // 创建目标图像并绘制
        let imageRect = CGRect(x: 0.0, y: 0.0, width: Double(cgImage.width), height: Double(cgImage.height))
        let newImage = NSImage.init(size: imageRect.size)
        // 绘制图像
        newImage.lockFocus()
        let cgContext = NSGraphicsContext.current?.cgContext
        cgContext?.draw(cgImage, in: imageRect)
        newImage.unlockFocus()
        
        return newImage
    }
    
    /// NSImage转CGImage
    /// - Parameter nsImage: NSImage
    /// - Returns: CGImage
    func createCGImageFromNSImage(nsImage: NSImage?) -> CGImage? {
        guard let data = nsImage?.tiffRepresentation else { return nil }
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        
        return cgImage
    }
    
}
