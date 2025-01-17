//
//  ITARGBInputView.swift
//  ImageTintAssistant-Mac
//
//  Created by wangzhi on 2019/11/21.
//  Copyright © 2019 BTStudio. All rights reserved.
//

import Cocoa

let RColor = RGBColor(211, 57, 53)
let GColor = RGBColor(28, 147, 76)
let BColor = RGBColor(60, 116, 242)


class ITARGBInputView: NSView {
    
    // RGB :
    private lazy var rgbLabel: NSText = {
        let text = NSText()
        text.font = NSFont.systemFont(ofSize: 16)
        text.string = "RGB :"
        text.isEditable = false
        text.isSelectable = false
        text.backgroundColor = NSColor.clear
        text.alignment = NSTextAlignment.center
        text.isVerticallyResizable = false
        return text
    }()
    
//    // RGB(Hex) :
//    private lazy var rgbHexLabel: NSText = {
//        let text = NSText()
//        text.font = NSFont.systemFont(ofSize: 16)
//        text.string = "RGB(Hex) :"
//        text.isEditable = false
//        text.backgroundColor = NSColor.clear
//        text.alignment = NSTextAlignment.center
//        text.isVerticallyResizable = false
//        text.isRichText = true
//        return text
//    }()
    
    // RGB_Hex :
    private lazy var rgbHexLabel: NSTextField = {
        let str = "RGB_Hex :"
        let attrStr = NSMutableAttributedString(string: str)
        attrStr.addAttribute(.foregroundColor, value: NSColor.white, range: NSMakeRange(0, str.count))
        attrStr.addAttribute(.font, value: NSFont.systemFont(ofSize: 10), range: NSMakeRange(3, 4))
        attrStr.addAttribute(.foregroundColor, value: NSColor.white, range: NSMakeRange(3, 4))
        
        let text = NSTextField()
        text.font = NSFont.systemFont(ofSize: 16)
        text.isBordered = false
        text.isBezeled = false
        text.isEditable = false
        text.isSelectable = false
        text.backgroundColor = NSColor.clear
        text.attributedStringValue = attrStr
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
        textField.placeholderAttributedString = NSAttributedString(string: "#DF7E1F", attributes: [NSAttributedString.Key.foregroundColor : RGBAColor(186, 186, 186, 0.5), NSAttributedString.Key.font : textFieldFont])
        textField.toolTip = NSLocalizedString("Enter the hexadecimal RGB value, for example: DF7E1F", comment: "")
        return textField
    }()
    
    
    private var textFieldFont: NSFont {
        return NSFont.systemFont(ofSize: 15)
    }
    
    /// 输入框是否在删除字符
    private var deleting = false
    
    /// RGB变量
    private var red = 0
    private var green = 0
    private var blue = 0
    
    /// RGB颜色值回调
    var rgbColorHandler: ((_ color: NSColor, _ red: Int, _ green: Int, _ blue: Int) -> ())?
    
    /// RGB颜色值确认的回调
    ///
    /// 在输入状态时,按下 回车键 会执行此回调
    var rgbColorConfirmHandler: ((_ color: NSColor, _ red: Int, _ green: Int, _ blue: Int) -> ())?
    

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
        let str = string.isEmpty ? "0" : string // 当删除所有字符时,把值看做为0
        
        // 1. 限制输入字符个数
        // - 十进制RGB值只能输入3个字符
        // - 十六进制RGB值只能输入6个字符
        let maxCount = textField == rgbHexTextField ? 6 : 3
        if str.count > maxCount {
            let index1 = str.index(str.startIndex, offsetBy: 0)
            let index2 = str.index(str.startIndex, offsetBy: maxCount)
            let newStr = str[index1..<index2]
            textField.stringValue = String(newStr)
            return
        }
        
        // 2. 解析RGB值
        if textField == rgbHexTextField {
            resolveRGBFrom(hexString: str)
        } else {
            let valid = verifyIntNumberString(string: str)
            if !valid { // 输入的内容为不合法的数字
                if !deleting {
                    BWHUDView.show(message: NSLocalizedString("Please enter the number, the range 0 to 255", comment: ""), type: .failure)
                    window?.makeFirstResponder(nil) // 取消响应者
                }
                return
            }
            // 范围: 0~255
            let rgbValue = Int(str) ?? 0
            if rgbValue < 0 || rgbValue > 255 { // 输入值范围需为: 0~255
                if !deleting {
                    BWHUDView.show(message: NSLocalizedString("The input value range needs to be: 0 to 255", comment: ""), type: .failure)
                    window?.makeFirstResponder(nil) // 取消响应者
                }
                return
            }
            if textField == redTextField {
                red = rgbValue
            } else if textField == greenTextField {
                green = rgbValue
            } else if textField == blueTextField {
                blue = rgbValue
            }
            // R/G/B值输入时,自动跳转至下一输入框
            if !deleting && isRGBValueInputDone(string: string) {
                if redTextField.stringValue.isEmpty {
                    redTextField.becomeFirstResponder()
                } else if greenTextField.stringValue.isEmpty {
                    greenTextField.becomeFirstResponder()
                } else if blueTextField.stringValue.isEmpty {
                    blueTextField.becomeFirstResponder()
                } else {
                    window?.makeFirstResponder(nil) // 取消响应者
                }
            }
        }
        
        // 3. 设置输入框文字
        if textField == rgbHexTextField {
            if string.isEmpty { // 删除 RGB Hex输入框中的全部字符后,让RGB输入框显示占位符
                updateRGBTextField(nil, nil, nil)
            } else {
                updateRGBTextField("\(red)", "\(green)", "\(blue)")
            }
        } else { // 十进制 转 十六进制字符串
            updateRGBHexTextField(red, green, blue)
        }
        
        // 用过后即可置为false
        deleting = false
        
        // 4. 执行回调
        let color = RGBColor(CGFloat(red), CGFloat(green), CGFloat(blue))
        rgbColorHandler?(color, red, green, blue)
    }
    
    
    /// 从十六进制字符串中解析RGB值
    /// - Parameter text: 十六进制字符串
    func resolveRGBFrom(hexString text: String) {
        let valid = verifyHexString(string: text)
        if !valid { // 输入的内容为不合法的十六进制数字
            if !deleting {
                BWHUDView.show(message: NSLocalizedString("Please enter the hex color value", comment: ""), type: .failure)
                window?.makeFirstResponder(nil) // 取消响应者
            }
            return
        }
        
        if text == "0" { // 输入框内容全部删除时,RGB值置为(0, 0, 0)
            red = 0
            green = 0
            blue = 0
            
        } else if text.count == 2 {
            let redHex = UInt(text, radix: 16) ?? 0 // 16进制字符串转整型
            red = Int(redHex)
            green = 0
            blue = 0
            
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
            blue = 0
            
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
    
    /// R/G/B值是否输入完成
    /// - Parameter string: 输入框内容
    func isRGBValueInputDone(string: String) -> Bool {
        // 1.输入完2个数字后:
        // - 若第一个数字大于2,则认为输入完成;
        // - 若第一个数字等于2,第二个数字大于5,则认为输入完成;
        // 2.输入完3个数字后,则输入完成
        if string.count == 2 {
            let index1 = string.index(string.startIndex, offsetBy: 1)
            let index2 = string.index(string.startIndex, offsetBy: 2)
            let firstChar = string[..<index1]
            let secondChar = string[index1..<index2]
            
            let firstNum = Int(firstChar) ?? 0
            let secondNum = Int(secondChar) ?? 0
            if firstNum > 2 {
                return true
            } else if firstNum == 2 && secondNum > 5 {
                return true
            }
        } else if string.count == 3 {
            return true
        }
        return false
    }
}


// MARK: - NSTextFieldDelegate

extension ITARGBInputView: NSTextFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        let deleteSel = #selector(NSStandardKeyBindingResponding.deleteBackward(_:)) // 删除键
        let tabSel = #selector(NSStandardKeyBindingResponding.insertTab(_:)) // Tab键
        let newlineSel = #selector(NSStandardKeyBindingResponding.insertNewline(_:)) // 换行键
        if commandSelector == deleteSel {
            deleting = true
        } else if commandSelector == tabSel {
            
        } else if commandSelector == newlineSel {
            // 按下回车键,执行颜色值确认的回调
            let color = RGBColor(CGFloat(red), CGFloat(green), CGFloat(blue))
            rgbColorConfirmHandler?(color, red, green, blue)
        }
        
        return false
    }
}


// MARK: - 设置界面
extension ITARGBInputView {
    
    func setupUI() {
        addSubview(rgbHexTextField)
        addSubview(greenTextField)
        addSubview(redTextField)
        addSubview(blueTextField)
        addSubview(rgbLabel)
        addSubview(rgbHexLabel)
        
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
        
        // RGB :
        let labelW: CGFloat = 54
        rgbLabel.frame = NSRect(x: redTextField.frame.minX - labelW, y: redTextField.frame.minY - 3, width: labelW, height: textFieldH)
        
        // RGB(Hex) :
        let hexLabelW: CGFloat = 74
        rgbHexLabel.frame = NSRect(x: rgbHexTextField.frame.minX - hexLabelW, y: rgbHexTextField.frame.minY - 3, width: hexLabelW, height: textFieldH)
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
    
    /// 根据RGB值更新UI
    /// - Parameters:
    ///   - red: R
    ///   - green: G
    ///   - blue: B
    func updateUIWithRGB(_ red: Int, _ green: Int, _ blue: Int) {
        // 回到主线程更新UI
        DispatchQueue.main.async {
            self.updateRGBTextField("\(red)", "\(green)", "\(blue)")
            self.updateRGBHexTextField(red, green, blue)
        }
    }
}


// MARK: - Tool Methods
extension ITARGBInputView {
    
    /// 验证是否为合法的Int格式字符串
    /// - Parameter string: 要验证的字符串
    func verifyIntNumberString(string: String?) -> Bool {
        guard let string = string else { return false }
        
        let regex = "^[0-9]+$"
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: string)
    }
    
    /// 验证是否为合法的十六进制格式字符串
    /// - Parameter string: 要验证的字符串
    func verifyHexString(string: String?) -> Bool {
        guard let string = string else { return false }
        
        let regex = "^[0-9a-fA-F]+$"
        let predicate = NSPredicate.init(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: string)
    }
}
