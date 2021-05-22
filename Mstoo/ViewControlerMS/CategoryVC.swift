//
//  CategoryVC.swift
//  Mstoo
//
//  Created by Vishal on 02/09/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit
import SwiftyJSON

class categoryModel: NSObject
{
    var name: String = ""
    var id: String = ""
    var image: String = ""
    
    override init()
    {
    }
    
    init(dict: NSDictionary)
    {
        name = dict.getStringValue(key: "name")
        id = dict.getStringValue(key: "id")
        image = dict.getStringValue(key: "image")
    }
    
    init(json: JSON)
    {
        name = json["name"].stringValue
        id = json["id"].stringValue
        image = json["image"].stringValue
    }
}

class subCategoryModel: NSObject
{
    var name: String = ""
    var id: String = ""
    var image: String = ""
    
    override init()
    {
    }
    
    init(dict: NSDictionary)
    {
        name = dict.getStringValue(key: "name")
        id = dict.getStringValue(key: "id")
        image = dict.getStringValue(key: "image")
    }
}

class CategoryVC: UIViewController
{
    @IBOutlet weak var categoryTable: UITableView!
    
    var categoryData = [categoryModel]()
    var subCategoryData = [subCategoryModel]()
    var jsonResult:NSArray = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.getCategories()
        
        self.categoryTable.dataSource = self
        self.categoryTable.delegate = self
        self.categoryTable.tableFooterView = UIView()
        self.categoryTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    @IBAction func myPostsAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CategoryVC
{
    func getCategories() {
        let userDict = [String : Any]()
        
        ServiceHelper.request(params: userDict, method: .get, baseWebUrl:baseUrl , useToken: "no" , apiName: getCategoriesUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    self.jsonResult = (response!["data"] as? NSArray)!
                    print(self.jsonResult)
                    
                    self.categoryData = []
                    
                    for value in self.jsonResult
                    {
                        if let cuisineStr = value as? NSDictionary
                        {
                            let menu = categoryModel(dict: cuisineStr)
                            self.categoryData.append(menu)
                        }
                    }
                    self.categoryTable.reloadData()
                }
                else
                {
                    if let data = response![kResponseMsg]
                    {
                        self.showToast(message: data as! String)
                    }
                }
            }
        }
    }
}

extension CategoryVC: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return categoryData.count
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
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
//        let cellReuseIdentifier = "cell"
//        let cell:UITableViewCell = (tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        let cell = CellFilter.commonInit()
        cell.setCatData(cat: categoryData[indexPath.row])
        //        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let subCategory = (jsonResult.object(at: indexPath.section) as AnyObject).object(forKey: "sub_categories") as! NSArray
        
        self.subCategoryData = []
        
        for value in subCategory
        {
            if let cuisineStr = value as? NSDictionary
            {
                let menu = subCategoryModel(dict: cuisineStr)
                self.subCategoryData.append(menu)
            }
        }
        
        self.performSegue(withIdentifier: "showSubCategory", sender: indexPath)
    }
}

extension CategoryVC
{
    func showToast(message : String)
    {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
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
        if segue.identifier == "showSubCategory"
        {
            if let nextViewController = segue.destination as? SubCategoryVC
            {
                let indexPath = sender as! IndexPath
                nextViewController.topTitle = categoryData[indexPath.section].name
                nextViewController.cateId = categoryData[indexPath.section].id
                nextViewController.subCategoryData = subCategoryData
            }
        }
    }
}
