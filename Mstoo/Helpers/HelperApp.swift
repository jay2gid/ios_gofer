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

}
