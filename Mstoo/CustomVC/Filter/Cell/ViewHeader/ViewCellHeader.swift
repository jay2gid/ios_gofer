//
//  ViewCellHeader.swift
//  Mstoo
//
//  Created by Python on 5/20/21.
//  Copyright © 2021 Vishal. All rights reserved.
//

import UIKit

class ViewCellHeader: UIView {

    @IBOutlet var lblTitle: UILabel!
    
    class func commonInit() -> ViewCellHeader {
        let nibView = Bundle.main.loadNibNamed("ViewCellHeader", owner: self, options: nil)?[0] as! ViewCellHeader
        nibView.layoutIfNeeded()
        return nibView
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
