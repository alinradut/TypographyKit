//
//  UITextFieldAdditions.swift
//  Pods-TypographyKit_Example
//
//  Created by Ross Butler on 9/7/17.
//

import Foundation
import UIKit

extension UITextField {
    
    public var letterCase: LetterCase {
        get {
            // swiftlint:disable:next force_cast
            return objc_getAssociatedObject(self, &TypographyKitPropertyAdditionsKey.letterCase) as! LetterCase
        }
        set {
            objc_setAssociatedObject(self, &TypographyKitPropertyAdditionsKey.letterCase,
                                     newValue, .OBJC_ASSOCIATION_RETAIN)
            if !isAttributed() {
                self.text = self.text?.letterCase(newValue)
            }
        }
    }
    
    @objc public var fontTextStyle: UIFont.TextStyle {
        get {
            // swiftlint:disable:next force_cast
            return objc_getAssociatedObject(self, &TypographyKitPropertyAdditionsKey.fontTextStyle) as! UIFont.TextStyle
        }
        set {
            objc_setAssociatedObject(self,
                                     &TypographyKitPropertyAdditionsKey.fontTextStyle,
                                     newValue, .OBJC_ASSOCIATION_RETAIN)
            if let typography = Typography(for: newValue) {
                self.typography = typography
            }
        }
    }
    
    @objc public var fontTextStyleName: String {
        get {
            return fontTextStyle.rawValue
        }
        set {
            fontTextStyle = UIFont.TextStyle(rawValue: newValue)
        }
    }
    
    public var typography: Typography {
        get {
            // swiftlint:disable:next force_cast
            return objc_getAssociatedObject(self, &TypographyKitPropertyAdditionsKey.typography) as! Typography
        }
        set {
            objc_setAssociatedObject(self, &TypographyKitPropertyAdditionsKey.typography,
                                     newValue, .OBJC_ASSOCIATION_RETAIN)
            addObserver()
            
            if newValue.requiresAttributedString {
                if attributedText == nil {
                    attributedText = NSAttributedString(string: text ?? "")
                }
                
                var newValue = newValue
                
                if newValue.textAlignment == nil {
                    newValue.textAlignment = textAlignment
                }
                
                let mutableString = NSMutableAttributedString(attributedString: attributedText!)
                let textRange = NSRange(location: 0, length: attributedText!.string.count)
                mutableString.enumerateAttributes(in: textRange, options: [], using: { value, range, _ in
                    update(attributedString: mutableString, with: value, in: range, and: newValue)
                })
                
                let defaultColor = defaultTextColor(in: mutableString)
                self.attributedText = replaceTextColor(defaultColor, with: typography.textColor, in: mutableString)

                if let backgroundColor = newValue.backgroundColor {
                    self.backgroundColor = backgroundColor
                }
                return
            }
                        
            guard !isAttributed() else {
                return
            }
            if let newFont = newValue.font(UIApplication.shared.preferredContentSizeCategory) {
                self.font = newFont
            }
            if let textColor = newValue.textColor {
                self.textColor = textColor
            }
            if let backgroundColor = newValue.backgroundColor {
                self.backgroundColor = backgroundColor
            }
            if let letterCase = newValue.letterCase {
                self.letterCase = letterCase
            }
            if let textAlignment = newValue.textAlignment {
                self.textAlignment = textAlignment
            }
        }
    }
    
    // MARK: Functions
    
    public func attributedText(_ text: NSAttributedString?, style: UIFont.TextStyle,
                               letterCase: LetterCase? = nil, textColor: UIColor? = nil,
                               replacingDefaultTextColor: Bool = false) {
        // Update text.
        if let text = text {
            self.attributedText = text
        }
        // Update text color.
        if let textColor = textColor {
            self.textColor = textColor
        }
        guard var typography = Typography(for: style), let attrString = text else {
            return
        }
        // Apply overriding parameters.
        typography.textColor = textColor ?? typography.textColor
        typography.letterCase = letterCase ?? typography.letterCase
        self.fontTextStyle = style
        self.typography = typography
        let mutableString = NSMutableAttributedString(attributedString: attrString)
        let textRange = NSRange(location: 0, length: attrString.string.count)
        mutableString.enumerateAttributes(in: textRange, options: [], using: { value, range, _ in
            update(attributedString: mutableString, with: value, in: range, and: typography)
        })
        self.attributedText = mutableString
        if replacingDefaultTextColor {
            let defaultColor = defaultTextColor(in: mutableString)
            let replacementString = replaceTextColor(defaultColor, with: typography.textColor, in: mutableString)
            self.attributedText = replacementString
        }
    }
    
    public func text(_ text: String?, style: UIFont.TextStyle, letterCase: LetterCase? = nil,
                     textColor: UIColor? = nil) {
        if let text = text {
            self.text = text
        }
        if var typography = Typography(for: style) {
            // Only override letterCase and textColor if explicitly specified
            if let textColor = textColor {
                typography.textColor = textColor
            }
            if let letterCase = letterCase {
                typography.letterCase = letterCase
            }
            self.typography = typography
        }
    }
    
}

extension UITextField: TypographyKitElement {
    
    func isAttributed() -> Bool {
        guard let attributedText = attributedText else {
            return false
        }
        return isAttributed(attributedText)
    }
    
    func contentSizeCategoryDidChange(_ notification: NSNotification) {
        if let newValue = notification.userInfo?[UIContentSizeCategory.newValueUserInfoKey] as? UIContentSizeCategory {
            if isAttributed(attributedText) {
                self.attributedText(attributedText, style: fontTextStyle)
            } else {
                self.font = self.typography.font(newValue)
            }
            self.setNeedsLayout()
        }
    }
    
}
