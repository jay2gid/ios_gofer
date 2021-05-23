//
//  Constant.swift
//  XODiscounts
//
//  Created by Vishal on 23/11/19.
//  Copyright © 2019 Vishal. All rights reserved.
//

import Foundation
import UIKit

// OLD URL
//let baseUrl = "http://13.232.221.48/mstoo/public/api/"

// NEW URL
let baseUrl = "https://mstoo.online/mstoo/public/api/"


let loginUrl = "auth/login"
let fbLoginUrl = "auth/social/login"
let registerUrl = "auth/signup"
let updateProfileUrl = "auth/user/profile/edit"
let getAllPostsUrl = "post"
let getMyPostsUrl = "post/user"
let getFavoritePost = "post/favourite/list"
let getProfileUrl = "user/profile"
let changePasswordUrl = "auth/password/change"
let getInfoPagesUrl = "cms/pages"
let getCategoriesUrl = "category/list"
let addPostUrl = "auth/post/add"
let hideSocialLoginUrl = "hideUrl"
let packageListUrl = "packages"
let generateOrderUrl = "auth/package/generate/order"
let similarPostsUrl = "post/category/similar"
let blockedUsersUrl = "block/user/list"

let kResponseMsg = "message"
let kResponseCode = "status"
var kusername = "kusername"
var kuseremail = "kuseremail"
var kfirebaseid = "firebaseid"
let koriginal = "koriginal"

let addFavorite = "post/favourite/add"



// MARK: Permission

let _appName    = "Mstoo"
let kCameraAccessTitle   = "No camera access"
let kCameraAccessMsg     = "Please go to settings and switch on your Camera. settings -> \(_appName) -> switch on camera"
let kPhotosAccessTitle   = "No photos access"
let kPhotosAccessMsg     = "Please go to settings and switch on your photos. settings -> \(_appName) -> switch on photos"

let kColor_greencolor: UIColor = UIColor(red: 20.0/255.0, green: 189.0/255.0, blue: 93.0/255.0, alpha: 1.0)
let kColor_darkgrey: UIColor = UIColor(red: 172.0/255.0, green: 172.0/255.0, blue: 172.0/255.0, alpha: 1.0)

let defaults = UserDefaults.standard
let kWindowWidth = UIScreen.main.bounds.size.width
let kWindowHeight = UIScreen.main.bounds.size.height
let _maxImageSize              : CGSize  = CGSize(width: 1000, height: 1000)
let _minImageSize: CGSize  = CGSize(width: 800, height: 800)

let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate

var appDelegate : AppDelegate?
{
    return UIApplication.shared.delegate as? AppDelegate
}

func hexStringToUIColor (hex:String) -> UIColor
{
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func convertToTimestamp(date: NSDate) -> String
{
    return String(Int64(date.timeIntervalSince1970 * 1000))
}

extension String
{
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}

extension NSDictionary
{
    func getStringValue(key: String) -> String{
        if let any = object(forKey: key){
            if let number = any as? NSNumber{
                return number.stringValue
            }else if let str = any as? String{
                return str
            }
        }
        return ""
    }
}

extension Float
{
    func toInt() -> Int? {
        if self > Float(Int.min) && self < Float(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}

extension UIButton
{
    open override var isEnabled: Bool{
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
}
