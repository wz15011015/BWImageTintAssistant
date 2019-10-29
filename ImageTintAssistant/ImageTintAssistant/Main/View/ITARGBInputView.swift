//
//  ITARGBInputView.swift
//  ImageTintAssistant
//
//  Created by hadlinks on 2019/10/26.
//  Copyright © 2019 BTStudio. All rights reserved.
//

import UIKit

let RColor = RGBColor(211, 57, 53)
let GColor = RGBColor(28, 147, 76)
let BColor = RGBColor(60, 116, 242)

//let RAColor = RGBAColor(211, 57, 53, 0.3)
//let GAColor = RGBAColor(28, 147, 76, 0.3)
//let BAColor = RGBAColor(60, 116, 242, 0.3)

class ITARGBInputView: UIView {
    
    private lazy var rgbLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "RGB:"
        if #available(iOS 13.0, *) {
            label.textColor = .label
        }
        return label
    }()
    
    // R
    private lazy var redTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.returnKeyType = .done
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.tintColor = RColor
        textField.textColor = RColor
        textField.clearButtonMode = .whileEditing

        var RAColor = RGBAColor(211, 57, 53, 0.3)
        if #available(iOS 13.0, *) {
            RAColor = UIColor.init { (_ traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return RGBAColor(211, 57, 53, 0.4)
                } else {
                    return RGBAColor(211, 57, 53, 0.3)
                }
            }
        }
        textField.attributedPlaceholder = NSAttributedString.init(string: "0~255", attributes: [NSAttributedString.Key.foregroundColor : RAColor])
        return textField
    }()
    
    // G
    private lazy var greenTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.returnKeyType = .done
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.tintColor = GColor
        textField.textColor = GColor
        textField.clearButtonMode = .whileEditing
        
        var GAColor = RGBAColor(28, 147, 76, 0.3)
        if #available(iOS 13.0, *) {
            GAColor = UIColor.init { (_ traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return RGBAColor(28, 147, 76, 0.4)
                } else {
                    return RGBAColor(28, 147, 76, 0.3)
                }
            }
        }
        textField.attributedPlaceholder = NSAttributedString.init(string: "0~255", attributes: [NSAttributedString.Key.foregroundColor : GAColor])
        return textField
    }()
    
    // B
    private lazy var blueTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.returnKeyType = .done
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.tintColor = BColor
        textField.textColor = BColor
        textField.clearButtonMode = .whileEditing
        
        var BAColor = RGBAColor(60, 116, 242, 0.3)
        if #available(iOS 13.0, *) {
            BAColor = UIColor.init { (_ traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return RGBAColor(60, 116, 242, 0.4)
                } else {
                    return RGBAColor(60, 116, 242, 0.3)
                }
            }
        }
        textField.attributedPlaceholder = NSAttributedString.init(string: "0~255", attributes: [NSAttributedString.Key.foregroundColor : BAColor])
        return textField
    }()
    
    // RGB Hex
    private lazy var rgbHexTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.returnKeyType = .done
        textField.keyboardType = .asciiCapable
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "#DF7E1F"
        return textField
    }()
    
    // RGB变量
    private var red = 0
    private var green = 0
    private var blue = 0
    
    /// RGB颜色值回调
    @objc var rgbColorHandler: ((_ color: UIColor, _ red: Int, _ green: Int, _ blue: Int) -> ())?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationAdd(observer: self, selector: #selector(textDidChangeNotification(notification:)), name: UITextField.textDidChangeNotification.rawValue)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Notification
    @objc func textDidChangeNotification(notification: NSNotification) {
        guard let textField = notification.object as? UITextField,
            let text = textField.text else {
            return
        }
        
        // 1. 解析RGB值
        if textField == rgbHexTextField {
            resolveRGBFrom(hexString: text)
        } else {
            if textField == redTextField {
                red = Int(text) ?? 0
            } else if textField == greenTextField {
                green = Int(text) ?? 0
            } else if textField == blueTextField {
                blue = Int(text) ?? 0
            }
        }
        
        // 2. 设置输入框文字
        if textField == rgbHexTextField {
            if text == "" { // 删除 RGB Hex输入框中的全部字符后,让RGB输入框显示占位符
                updateRGBTextField(nil, nil, nil)
            } else {
                updateRGBTextField("\(red)", "\(green)", "\(blue)")
            }
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
            // 截取字符串
            let redIndex = "xx".endIndex
            let greenIndex = "xxxx".endIndex
            let redHexStr = text[..<redIndex]
            let greenHexStr = text[redIndex..<greenIndex]
            // 16进制字符串转整型
            let redHex = UInt(redHexStr, radix: 16) ?? 0
            let greenHex = UInt(greenHexStr, radix: 16) ?? 0
            
            red = Int(redHex)
            green = Int(greenHex)
            
        } else if text.count == 6 {
            // 截取字符串
            let redIndex = "xx".endIndex
            let greenIndex = "xxxx".endIndex
            let blueIndex = "xxxxxx".endIndex
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
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

// MARK: - 设置界面
extension ITARGBInputView {
    
    func setupUI() {
        addSubview(rgbLabel)
        addSubview(redTextField)
        addSubview(greenTextField)
        addSubview(blueTextField)
        addSubview(rgbHexTextField)
        
        // R,G,B 输入框
        // greenTextField 居中显示
        let textFieldW: CGFloat = 76
        let textFieldH: CGFloat = 36
        let textFieldSpace: CGFloat = 2
        greenTextField.frame = CGRect(x: (ScreenWidth / 2.0) - (textFieldW / 2.0), y: 0, width: textFieldW, height: textFieldH)
        redTextField.frame = greenTextField.frame.offsetBy(dx: -(textFieldW + textFieldSpace), dy: 0)
        blueTextField.frame = greenTextField.frame.offsetBy(dx: (textFieldW + textFieldSpace), dy: 0)
        
        // 16进制RGB输入框
        let rgbHexW: CGFloat = blueTextField.frame.maxX - redTextField.frame.minX
        rgbHexTextField.frame = CGRect(x: redTextField.frame.minX, y: redTextField.frame.maxY + 5, width: rgbHexW, height: textFieldH)
        
        // RGB:
        let labelW: CGFloat = 88
        rgbLabel.frame = CGRect(x: redTextField.frame.midX - labelW, y: 0, width: labelW, height: textFieldH)
    }
    
    /// 更新RGB输入框显示
    func updateRGBTextField(_ red: String?, _ green: String?, _ blue: String?) {
        redTextField.text = red
        greenTextField.text = green
        blueTextField.text = blue
    }
    
    /// 更新RGB Hex输入框显示
    func updateRGBHexTextField(_ red: Int, _ green: Int, _ blue: Int) {
        let hexStr = String(format: "%02X%02X%02X", red, green, blue)
        rgbHexTextField.text = hexStr
    }
}


// MARK: - UITextFieldDelegate
extension ITARGBInputView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 1. 确定字符的限制个数
        var maxCharCount = Int.max
        if textField == rgbHexTextField { // RGB Hex输入框,最多输入6个字符
            maxCharCount = 6
        } else { // RGB输入框,最多输入3个字符
            maxCharCount = 3
        }
        
        // 2. 进行检测
        if string == "" { // 删除中...
            // 在十六进制输入框中删除时,更新RGB输入框颜色值
            if textField == rgbHexTextField {
                // 去掉最后一个字符
                if let text = textField.text, let subRange = Range(NSMakeRange(0, text.count - 1), in:text) {
                    let subText = text[subRange]
                    if subText.count == 2 {
                        resolveRGBFrom(hexString: String(subText))
                        green = 0; blue = 0
                    } else if subText.count == 4 {
                        resolveRGBFrom(hexString: String(subText))
                        blue = 0
                    } else if subText.count == 6 {
                       resolveRGBFrom(hexString: String(subText))
                    }

                    // 设置输入框文字
                    updateRGBTextField("\(red)", "\(green)", "\(blue)")
                    
                    // 执行回调
                    let color = RGBColor(CGFloat(red), CGFloat(green), CGFloat(blue))
                    rgbColorHandler?(color, red, green, blue)
                }
            }
            return true
            
        } else { // 输入或粘贴中...
            // 2.1 判断字符是否合法
            if string.count > maxCharCount { // 粘贴时超过限制的字符个数,返回false
                return false
            } else { // 输入或粘贴字符中...
                var valid = true
                if textField == rgbHexTextField {
                    valid = verifyHexString(string: string)
                } else {
                    valid = verifyIntNumberString(string: string)
                }
                if !valid { // 不合法,返回false
                    return false
                }
            }
            
            // 2.2 判断字符个数是否超过限制个数
            let text = "\(textField.text ?? "")\(string)"
            if text.count > maxCharCount {
                return false
            } else {
                // 2.3 判断值的范围
                if textField == rgbHexTextField { // 十六进制
                    return true
                } else {
                    let number = Int(text) ?? 0
                    if number > 255 { // R/G/B值的范围是: 0 ~ 255
                        return false
                    } else {
                        return true
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == rgbHexTextField {
            guard let text = textField.text else {
                return true
            }
            // 十六进制输入为空时,显示占位文字对应的颜色,即: #DF7E1F
            if text == "" {
                red = 223; green = 126; blue = 31
    
                updateRGBTextField("223", "126", "31")
                updateRGBHexTextField(red, green, blue)

                // 执行回调
                let color = RGBColor(CGFloat(red), CGFloat(green), CGFloat(blue))
                rgbColorHandler?(color, red, green, blue)
            }
            
            textField.resignFirstResponder()
        }
        return true
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
