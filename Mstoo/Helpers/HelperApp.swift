//
//  HelperApp.swift
//  Mstoo
//
//  Created by Python on 5/22/21.
//  Copyright © 2021 Vishal. All rights reserved.
//

import UIKit

class HelperApp: NSObject {

    static let shared = HelperApp()
    var isNewPost = false
    
    
    
    class func makeCall(number:String){
        guard let number = URL(string: "tel://" + number) else { return }
        UIApplication.shared.open(number)
    }
    
    
    
    func addToFavroite(postId:String, completion:@escaping (_ _success:Bool)->()) {
                
        self.showLoading()
        var param = ["post_id":postId]
        
        if let userId = UserDefaults.standard.value(forKey: "userId") {
            param["user_id"] = userId as? String
        }else{
            completion(false)
        }
        
        
        ServiceHelper.request(params: param, method: .post, baseWebUrl:baseUrl , useToken: "no" , apiName: addFavorite , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            
            self.hideLoading()
            if (error == nil){
                if responseCode == 200{
                    completion(true)
                }else{
                    if let data = response![kResponseMsg]{
                        self.showToastBottom(message: data as! String)
                    }
                    completion(false)
                }
            }
        }
    }

}
