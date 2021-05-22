//
//  TextFieldExtension.swift
//  FansKick
//
//  Created by FansKick-Raj on 11/10/2017.
//  Copyright © 2017 FansKick Dev. All rights reserved.
//

import UIKit

extension UITextField {
    
    func nameType(_ returnKeyType: UIReturnKeyType = .next) {
        self.autocapitalizationType = .words
        setupWith(.asciiCapable, returnKeyType: returnKeyType)
    }
    
    func emailType(_ returnKeyType: UIReturnKeyType = .next) {
        setupWith(.emailAddress, returnKeyType: returnKeyType)
    }
    
    func passwordType(_ returnKeyType: UIReturnKeyType = .next) {
        self.autocapitalizationType = .words
        self.isSecureTextEntry = true
        setupWith(.asciiCapable, returnKeyType: returnKeyType)
    }
    
    func mobileNumberType(_ returnKeyType: UIReturnKeyType = .next) {
        setupWith(.phonePad, returnKeyType: returnKeyType)
    }
    
    func numberType(_ returnKeyType: UIReturnKeyType = .next) {
        setupWith(.numberPad, returnKeyType: returnKeyType)
    }
    
    // MARK:- Private function >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    private func setupWith(_ keyBoardType: UIKeyboardType, returnKeyType: UIReturnKeyType) {
        
        self.returnKeyType = returnKeyType
        self.keyboardType = keyBoardType
        
        self.autocorrectionType = .no
        self.spellCheckingType = .no
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func setBottomBorder() throws {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    func addDoneButton()  {
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ddismissKeyboard))
        keyboardToolbar.items = [flexBarButton, flexBarButton,doneBarButton]
        self.inputAccessoryView = keyboardToolbar
        
    }
    
    @objc func ddismissKeyboard()  {
        self.endEditing(true)
    }

}


class TxtBorderWhiteLight:UITextField {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.AppTextfield()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.AppTextfield()
    }
    
    func  AppTextfield() {
        
        
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 0.8
        
        self.textColor = .white
        self.autocorrectionType = .no
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!,
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText])
    }
}


