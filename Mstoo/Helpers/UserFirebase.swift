//
//  UserFirebase.swift
//  Sporddy
//
//  Created by MAC on 29/08/18.
//  Copyright © 2018 MAC. All rights reserved.
//

import UIKit
import Firebase


class UserFirebase: NSObject
{
    var name = ""
    var email = ""
    var profilePic : UIImage
    
    class func info(forUserID: String, completion: @escaping (UserFirebase) -> Swift.Void)
    {
        Database.database().reference().child("users").child(forUserID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String: String]
            {
                let name = "\(data.validatedValue("name", expected: "" as AnyObject))"
                let email = "\(data.validatedValue("email", expected: "" as AnyObject))"
                let link = URL.init(string: "\(data.validatedValue("avatar", expected: "" as AnyObject))")
                URLSession.shared.dataTask(with: link!, completionHandler: { (data, response, error) in
                    if error == nil {
                        let profilePic = UIImage.init(data: data!)
                        let user = UserFirebase.init(name: name, email: email, profilePic: profilePic!)
                        completion(user)
                    }
                }).resume()
            }
        })
    }

    init(name: String, email: String, profilePic: UIImage) {
        self.name = name
        self.email = email
        self.profilePic = profilePic
    }
}
