//
//  VCFilter.swift
//  Mstoo
//
//  Created by Python on 5/20/21.
//  Copyright © 2021 Vishal. All rights reserved.
//

import UIKit

class VCFilter: UIViewController, UITableViewDelegate,UITableViewDataSource {
    

    @IBOutlet var viewForHeader: UIView!
    @IBOutlet var table: UITableView!
    @IBOutlet var txtName: UITextField!
    @IBOutlet var txtDesc: UITextField!
    @IBOutlet var btnApply: UIButton!
    
    let helper = HelperFitler.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Fitler"
        
        helper.getCategories { (success) in
            self.setTable()
        }
        
        self.hideKeyboardWhenTappedAround()
        txtDesc.addDoneButton()
        txtName.addDoneButton()
    }

    func setTable(){
        self.table.delegate = self
        self.table.dataSource = self
        self.table.reloadData()
        self.table.showsVerticalScrollIndicator = false
    }
    
    @IBAction func tapApply(_ sender: Any) {
        helper.txtSearch = txtName.text!
        helper.des = txtDesc.text!
        
        searchData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
  
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHdr = ViewCellHeader.commonInit()
        if section == 0 {
            viewHdr.lblTitle.text  = "Select Category"
        }else{
            viewHdr.lblTitle.text  = "Select Sub Category"
        }
        viewHdr.backgroundColor = ConstantGlobal.Color.Primary
        return viewHdr
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return helper.arrCategory.count
        }
        
        if section == 1 {
            return helper.arrSubCategory.count
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = CellFilter.commonInit()
            
            let item = helper.arrCategory[indexPath.row]

            cell.lbltitle.text = item.name
            cell.imgIcon.setCatchImage(url: item.image)
            cell.imgIcon.backgroundColor = ConstantGlobal.Color.Border
            cell.imgIcon.layer.cornerRadius = cell.imgIcon.frame.width / 2
            return cell
        }else{
            let cell = CellFilter.commonInit()
            
            let item = helper.arrSubCategory[indexPath.row]

            cell.lbltitle.text = item.name
            cell.imgIcon.setCatchImage(url: item.image)
            cell.imgIcon.backgroundColor = ConstantGlobal.Color.Border
            cell.imgIcon.layer.cornerRadius = cell.imgIcon.frame.width / 2
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            helper.catId = "\(helper.arrCategory[indexPath.row].id)"
        }
        
        if indexPath.section == 1 {
            helper.subCatId = "\(helper.arrSubCategory[indexPath.row].id)"
        }
        searchData()
    }
    
    func searchData() {
        helper.getAllPosts { (success) in
            self.callNotifier(title: ConstantGlobal.Notifier.refreshPost)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
