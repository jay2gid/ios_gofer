//
//  HelperFitler.swift
//  Mstoo
//
//  Created by Python on 5/20/21.
//  Copyright © 2021 Vishal. All rights reserved.
//

import UIKit
import SwiftyJSON

class HelperFitler: NSObject {

    static let shared = HelperFitler()
    
    var arrCategory = [categoryModel]()
    var arrSubCategory = [categoryModel]()
    var jsonResult:NSArray = []
    var arryPosts = [PostsModel]()
    
    
    var txtSearch = ""
    var des = ""
    var catId = ""
    var subCatId = ""
    
    
    func reset (){
        txtSearch = ""
        des = ""
        catId = ""
        subCatId = ""
    }
    
    
    
    func getCategories(completion:@escaping (_ _success:Bool)->()) {
        
        let userDict = [String : Any]()
        
        self.showLoading()
        
        ServiceHelper.request(params: userDict, method: .get, baseWebUrl:baseUrl , useToken: "no" , apiName: getCategoriesUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            
            self.hideLoading()
            if (error == nil)
            {
                if responseCode == 200
                {
                    self.jsonResult = (response!["data"] as? NSArray)!
                    //                    print(self.jsonResult)
                    
                    self.arrCategory = []
                    
                    for value in self.jsonResult {
                        if let cuisineStr = value as? NSDictionary {
                            let menu = categoryModel(dict: cuisineStr)
                            self.arrCategory.append(menu)
                        }
                        
                        let json = JSON(value)
                        
                        for item in json["sub_categories"].arrayValue {
                            let item = categoryModel(json: item)
                            self.arrSubCategory.append(item)
                        }
                                                
                    }
                    completion(true)
                }
                else
                {
                    if let data = response![kResponseMsg]
                    {
                        self.showToastBottom(message: data as! String)
                    }
                    completion(false)
                }
            }
        }
    }
    
    
    
    func getAllPosts(completion:@escaping (_ _success:Bool)->()){
        
        var params = [String : Any]()
//        userDict["latitude"] = latStr
//        userDict["longitude"] = lonStr

        if self.txtSearch.count > 0 {
            params["filters[title]"] = self.txtSearch
        }
        if self.des.count > 0 {
            params["filters[description]"] = self.des
        }
        
        if self.subCatId.count > 0 {
            params["filters[sub_category_id]"] = self.subCatId
        }
        
        if self.subCatId.count > 0 {
            params["filters[category_id]"] = self.catId
        }
        

        ServiceHelper.request(params: params, method: .post, baseWebUrl:baseUrl , useToken: "no" , apiName: getAllPostsUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = response!["data"] as? Dictionary<String, AnyObject>
                    print(jsonResult!)
                    
                    
                    let postData = jsonResult!["post"] as? Dictionary<String, AnyObject>
                    
                    let postsData = postData!["posts"] as? NSArray
                    print(postsData as Any)
                    
                    
                    
                    self.arryPosts = []
                    
                    for value in postsData!
                    {
                        if let cuisineStr = value as? NSDictionary
                        {
                            let menu = PostsModel(dict: cuisineStr)
                            self.arryPosts.append(menu)
                        }
                    }
                    completion(true)
                    
                }
                else
                {
                    if let data = response![kResponseMsg]
                    {
                        self.showToastBottom(message: data as! String)
                    }
                    completion(false)
                }
            }
        }
    }

    
    
    
    
    
}
