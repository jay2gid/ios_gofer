//
//  CellFilter.swift
//  Mstoo
//
//  Created by Python on 5/20/21.
//  Copyright © 2021 Vishal. All rights reserved.
//

import UIKit

class CellFilter: UITableViewCell {

    @IBOutlet var lbltitle: UILabel!
    @IBOutlet var imgIcon: UIImageView!
    
    
    class func commonInit() -> CellFilter {
        let nibView = Bundle.main.loadNibNamed("CellFilter", owner: self, options: nil)?[0] as! CellFilter
        nibView.layoutIfNeeded()
        return nibView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCatData(cat:categoryModel) {
        self.imgIcon.setCatchImage(url: cat.image)
        self.lbltitle.text =  cat.name
//        self.imgIcon.layer.cornerRadius = self.imgIcon.frame.width / 2
    }
    
    func setSubCatData(cat:subCategoryModel) {
        self.imgIcon.setCatchImage(url: cat.image)
        self.lbltitle.text =  cat.name
//        self.imgIcon.layer.cornerRadius = self.imgIcon.frame.width / 2
    }
}
