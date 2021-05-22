//
//  SubCategoryVC.swift
//  Mstoo
//
//  Created by Vishal on 02/09/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit

class SubCategoryVC: UIViewController
{
    @IBOutlet weak var subCategoryTable: UITableView!
    @IBOutlet weak var titleLabel: UILabel!

    var subCategoryData = [subCategoryModel]()
    var topTitle: String = ""
    var cateId: String = ""

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.titleLabel.text = self.topTitle
        
        self.subCategoryTable.dataSource = self
        self.subCategoryTable.delegate = self
        self.subCategoryTable.tableFooterView = UIView()
        self.subCategoryTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func myPostsAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SubCategoryVC: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return subCategoryData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 10))
        view.backgroundColor = .clear

        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 10.0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = CellFilter.commonInit()
        let item = subCategoryData[indexPath.section]
        
        cell.setSubCatData(cat: item)
        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.performSegue(withIdentifier: "showAddPost", sender: indexPath)
    }
}

extension SubCategoryVC
{
    func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage
    {
        let scale = CGFloat(max(size.width/image.size.width,
            size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        let rr:CGRect = CGRect(x: 0, y: 0, width: width, height: height);

        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return image }
        UIGraphicsEndImageContext();
        return newImage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showAddPost"
        {
            if let nextViewController = segue.destination as? AddPostVC
            {
                let indexPath = sender as! IndexPath
                nextViewController.cateName = self.topTitle
                nextViewController.getCateId = self.cateId
                nextViewController.subCateName = subCategoryData[indexPath.section].name
                nextViewController.getSubCateId = subCategoryData[indexPath.section].id
            }
        }
    }
}
