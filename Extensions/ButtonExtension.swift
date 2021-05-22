//
//  ButtonExtension.swift
//  FansKick
//
//  Created by FansKick-Raj on 11/10/2017.
//  Copyright © 2017 FansKick Dev. All rights reserved.
//

import UIKit

extension UIButton {
    
    func underLine(state: UIControl.State = .normal) {
        
        if let title = self.title(for: state) {
            
            let color = self.titleColor(for: state)
            
            let attrs = [
                NSAttributedString.Key.foregroundColor.rawValue : color ?? UIColor.blue,
                NSAttributedString.Key.underlineStyle : 1] as [AnyHashable : Any]
            
            let buttonTitleStr = NSMutableAttributedString(string: title, attributes: (attrs as! [NSAttributedString.Key : Any]))
            self.setAttributedTitle(buttonTitleStr, for: state)
            
        }
    }
    
    func normalLoad(_ string:String) {
        
        if let url = URL(string: string) {
            //self.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")!, options: .refreshCached)
            //            self.sd_setImage(with: url, for: .normal, completed: nil)
        } else {
            self.setImage(UIImage(named: "placeholder")!, for: .normal)
        }
    }
    
    @IBInspectable
    open var exclusiveTouchEnabled : Bool {
        get {
            return self.isExclusiveTouch
        }
        set(value) {
            self.isExclusiveTouch = value
        }
    }
    @IBInspectable  var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable  var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    @IBInspectable  var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}




class BtnWhite: UIButton { // Used in restorent
    
    
    
    func commonInit()  {
        //        self.clipsToBounds = true
        self.layer.cornerRadius = 4
        
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = ConstantGlobal.Border.cgColor
        self.backgroundColor = .white
        
        self.setTitleColor(ConstantGlobal.DarkBlack, for: .normal)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
}


class BtnWhiteShadowHalfRound: UIButton { // Used in restorent
    
    func commonInit()  {
        //        self.clipsToBounds = true
        
        self.backgroundColor = .white
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = ConstantGlobal.Border.cgColor
        self.layer.cornerRadius = self.frame.width/2
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
}



class ImgHRoundBorder: UIImageView { // Used in restorent
    
    func commonInit()  {
        //        self.clipsToBounds = true
        
        self.backgroundColor = .white
        self.layer.borderColor = ConstantGlobal.Border.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = self.frame.width/2
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
}
