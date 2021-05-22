//
//  ViewExtention.swift
//  Mstoo
//
//  Created by Python on 5/20/21.
//  Copyright © 2021 Vishal. All rights reserved.
//

import UIKit

class ViewExtention: NSObject {

}



class ViewRoundShadow: UIView { // Used in restorent
    
    override func draw(_ rect: CGRect){
        
    }
        
    
    func commonInit()  {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.height/2
        DispatchQueue.main.async {
            self.layer.shadowOffset = CGSize(width: 0, height: 1)
            self.layer.shadowRadius = self.frame.size.height/2
            self.layer.shadowOpacity = 1
            self.layer.shadowColor = ConstantGlobal.Border.cgColor
        }
        
    
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


class ViewCorner: UIView { // Used in restorent
    
    override func draw(_ rect: CGRect){
        
    }
        
    
    func commonInit()  {
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
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

class ViewCornerSmall: UIView { // Used in restorent
    
    override func draw(_ rect: CGRect){
        
    }
        
    
    func commonInit()  {
        self.clipsToBounds = true
        self.layer.cornerRadius = 4
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


class ViewBorderCorner8: UIView { // Used in restorent
    
    override func draw(_ rect: CGRect){
        
    }
        
    
    func commonInit()  {
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.layer.borderColor = ConstantGlobal.Color.Border.cgColor
        
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
