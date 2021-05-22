//
//  AddCustomerInfoView.swift
//  SignCatch
//
//  Created by Dinesh Kumar on 17/11/16.
//  Copyright © 2016 Sanjay Kumar. All rights reserved.
//

import Foundation
import UIKit



class ViewLoader: UIView {
    
    static var shared = ViewLoader.commonInit()
    
    var counter : Double = 1.0
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var stopLoader =  false
    
    @IBOutlet weak var cancelButton: UIButton!
    
    class func commonInit() -> ViewLoader {
        let nibView = Bundle.main.loadNibNamed("ViewLoader", owner: self, options: nil)?[0] as! ViewLoader
        nibView.layoutIfNeeded()
        return nibView
    }
    
    @IBOutlet var btnCross: UIButton!
    override func draw(_ rect: CGRect) {
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        if activityIndicator != nil{
            activityIndicator.stopAnimating()
        }
        self.removeFromSuperview()
        
    }
    
    override func awakeFromNib() {
        self.cancelButton.backgroundColor = UIColor.black
        self.cancelButton.tintColor = UIColor.white
    }
    
    func rotateWithRepeat() {
        activityIndicator.startAnimating()
    }
    
    func toRadians(angle:Double) -> CGFloat {
        let rad = CGFloat(angle * .pi / 180.0)
        return rad
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }
    
}

