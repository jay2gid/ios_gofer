//
//  InfoPagesVC.swift
//  Mstoo
//
//  Created by Vishal on 01/09/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit

class InfoPagesVC: UIViewController
{
    @IBOutlet weak var showData: UITextView!
    @IBOutlet weak var titleBtn: UIButton!

    var getInfo: String = ""
    var htmlStr: String = ""

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.showData.layer.cornerRadius = 5.0
        self.showData.layer.borderWidth = 1.0
        self.showData.layer.borderColor = kColor_greencolor.cgColor
        self.showData.layer.masksToBounds = true
        
        if getInfo == "aboutUs"
        {
            self.titleBtn.setTitle("  About Mstoo", for: .normal)
            htmlStr = ViewController.GlobalVariable.infoPagesData["about_us"] as! String
        }
        else if getInfo == "howItWorks"
        {
            self.titleBtn.setTitle("  How Mstoo Works", for: .normal)
            htmlStr = ViewController.GlobalVariable.infoPagesData["howItWorks"] as! String
        }
        else if getInfo == "contactUs"
        {
            self.titleBtn.setTitle("  Contact US", for: .normal)
            htmlStr = ViewController.GlobalVariable.infoPagesData["contact_us"] as! String
        }
        
        let htmlData = NSString(string: htmlStr).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
        self.showData.attributedText = attributedString
    }
}

extension InfoPagesVC
{
    @IBAction func backAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
