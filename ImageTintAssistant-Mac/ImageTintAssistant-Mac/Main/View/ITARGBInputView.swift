//
//  ITARGBInputView.swift
//  ImageTintAssistant-Mac
//
//  Created by hadlinks on 2019/11/21.
//  Copyright © 2019 BTStudio. All rights reserved.
//

import Cocoa

let RColor = RGBColor(211, 57, 53)
let GColor = RGBColor(28, 147, 76)
let BColor = RGBColor(60, 116, 242)


class ITARGBInputView: NSView {
    
    // RGB:
    private lazy var rgbLabel: NSText = {
        let text = NSText()
        text.font = NSFont.systemFont(ofSize: 16)
        text.string = "RGB:"
        text.isEditable = false
        text.backgroundColor = NSColor.clear
        return text
    }()
    
    // R 输入框
    private lazy var redTextField: NSTextField = {
        let textField = NSTextField()
        textField.delegate = self
        textField.font = textFieldFont
        textField.textColor = RColor
        if let placeholderColor = NSColor(named: "RAColor") {
            textField.placeholderAttributedString = NSAttributedString(string: "0~255", attributes: [NSAttributedString.Key.foregroundColor : placeholderColor, NSAttributedString.Key.font : textFieldFont])
        }
        return textField
    }()
    
    // G 输入框
    private lazy var greenTextField: NSTextField = {
        let textField = NSTextField()
        textField.delegate = self
        textField.font = textFieldFont
        textField.textColor = GColor
        if let placeholderColor = NSColor(named: "GAColor") {
            textField.placeholderAttributedString = NSAttributedString(string: "0~255", attributes: [NSAttributedString.Key.foregroundColor : placeholderColor, NSAttributedString.Key.font : textFieldFont])
        }
        return textField
    }()
    
    // B 输入框
    private lazy var blueTextField: NSTextField = {
        let textField = NSTextField()
        textField.delegate = self
        textField.font = textFieldFont
        textField.textColor = BColor
        if let placeholderColor = NSColor(named: "BAColor") {
            textField.placeholderAttributedString = NSAttributedString(string: "0~255", attributes: [NSAttributedString.Key.foregroundColor : placeholderColor, NSAttributedString.Key.font : textFieldFont])
        }
        return textField
    }()
    
    // RGB十六进制输入框
    private lazy var rgbHexTextField: NSTextField = {
        let textField = NSTextField()
        textField.delegate = self
        textField.font = textFieldFont
        textField.textColor = NSColor.labelColor
        textField.placeholderAttributedString = NSAttributedString(string: "#DF7E1F", attributes: [NSAttributedString.Key.foregroundColor : RGBColor(186, 186, 186), NSAttributedString.Key.font : textFieldFont])
        return textField
    }()
    
    
    private var textFieldFont: NSFont {
        return NSFont.systemFont(ofSize: 15)
    }
    
    // RGB变量
    private var red = 0
    private var green = 0
    private var blue = 0
    
    /// RGB颜色值回调
    var rgbColorHandler: ((_ color: NSColor, _ red: Int, _ green: Int, _ blue: Int) -> ())?
    

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
        
        setupUI()
    }
    
    
    // MARK: - Notification
    
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }

        let string = textField.stringValue
        
        // 1. 解析RGB值
        if textField == rgbHexTextField {
            resolveRGBFrom(hexString: string)
        } else {
            // 范围: 0~255
            var rgbValue = Int(string) ?? 0
            rgbValue = rgbValue < 0 ? 0 : rgbValue
            rgbValue = rgbValue > 255 ? 255 : rgbValue
            if textField == redTextField {
                red = rgbValue
            } else if textField == greenTextField {
                green = rgbValue
            } else if textField == blueTextField {
                blue = rgbValue
            }
        }
        
        // 2. 设置输入框文字
        if textField == rgbHexTextField {
            updateRGBTextField("\(red)", "\(green)", "\(blue)")
        } else { // 十进制 转 十六进制字符串
            updateRGBHexTextField(red, green, blue)
        }
        
        // 3. 执行回调
        let color = RGBColor(CGFloat(red), CGFloat(green), CGFloat(blue))
        rgbColorHandler?(color, red, green, blue)
    }
    
    /// 从十六进制字符串中解析RGB值
    /// - Parameter text: 十六进制字符串
    func resolveRGBFrom(hexString text: String) {
        if text.count == 2 {
            let redHex = UInt(text, radix: 16) ?? 0 // 16进制字符串转整型
            red = Int(redHex)
            
        } else if text.count == 4 {
            // 截取字符串 (https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift)
            let redIndex = text.index(text.startIndex, offsetBy: 2)
            let greenIndex = text.index(text.startIndex, offsetBy: 4)
            let redHexStr = text[..<redIndex]
            let greenHexStr = text[redIndex..<greenIndex]
            // 16进制字符串转整型
            let redHex = UInt(redHexStr, radix: 16) ?? 0
            let greenHex = UInt(greenHexStr, radix: 16) ?? 0
            
            red = Int(redHex)
            green = Int(greenHex)
            
        } else if text.count == 6 {
            // 截取字符串
            let redIndex = text.index(text.startIndex, offsetBy: 2)
            let greenIndex = text.index(text.startIndex, offsetBy: 4)
            let blueIndex = text.endIndex
            let redHexStr = text[..<redIndex]
            let greenHexStr = text[redIndex..<greenIndex]
            let blueHexStr = text[greenIndex..<blueIndex]
            // 16进制字符串转整型
            let redHex = UInt(redHexStr, radix: 16) ?? 0
            let greenHex = UInt(greenHexStr, radix: 16) ?? 0
            let blueHex = UInt(blueHexStr, radix: 16) ?? 0
            
            red = Int(redHex)
            green = Int(greenHex)
            blue = Int(blueHex)
        }
    }
}


// MARK: - NSTextFieldDelegate

extension ITARGBInputView: NSTextFieldDelegate {
    
}


// MARK: - 设置界面
extension ITARGBInputView {
    
    func setupUI() {
        addSubview(rgbHexTextField)
        addSubview(greenTextField)
        addSubview(redTextField)
        addSubview(blueTextField)
        addSubview(rgbLabel)
        
        let width: CGFloat = frame.width
//        let height: CGFloat = 100
        
        let textFieldW: CGFloat = 60
        let textFieldH: CGFloat = 26
        let textFieldSpace: CGFloat = 5
        
        // RGB 十六进制输入框
        let rgbHexW: CGFloat = 3 * textFieldW + 2 * textFieldSpace
        let rgbHexX: CGFloat = (width - rgbHexW) / 2.0;
        rgbHexTextField.frame = NSRect(x: rgbHexX, y: 0, width: rgbHexW, height: textFieldH)
        
        // R,G,B 输入框
        // greenTextField 居中显示
        greenTextField.frame = NSRect(x: (width - textFieldW) / 2.0, y: rgbHexTextField.frame.maxY + textFieldSpace, width: textFieldW, height: textFieldH)
        redTextField.frame = greenTextField.frame.offsetBy(dx: -(textFieldW + textFieldSpace), dy: 0)
        blueTextField.frame = greenTextField.frame.offsetBy(dx: (textFieldW + textFieldSpace), dy: 0)
        
        // RGB:
        let labelW: CGFloat = 50
        rgbLabel.frame = NSRect(x: redTextField.frame.minX - labelW, y: redTextField.frame.minY - 3, width: labelW, height: textFieldH)
    }
    
    /// 更新RGB Hex输入框显示
    func updateRGBHexTextField(_ red: Int, _ green: Int, _ blue: Int) {
        let hexStr = String(format: "%02X%02X%02X", red, green, blue)
        rgbHexTextField.stringValue = hexStr
    }
    
    /// 更新RGB输入框显示
    func updateRGBTextField(_ red: String?, _ green: String?, _ blue: String?) {
        redTextField.stringValue = red ?? ""
        greenTextField.stringValue = green ?? ""
        blueTextField.stringValue = blue ?? ""
    }
}
