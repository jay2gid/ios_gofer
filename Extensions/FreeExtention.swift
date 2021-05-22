//
//  FreeExtention.swift
//  Mstoo
//
//  Created by Python on 5/20/21.
//  Copyright © 2021 Vishal. All rights reserved.
//

import UIKit

class FreeExtention: NSObject {

}

extension NSObject {
    
    func showToastBottom(message : String) {
        
        let topVC = UIApplication.topViewController()!
        let toastLabel = UILabel(frame: CGRect(x: topVC.view.frame.size.width/2 - 75, y: topVC.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        topVC.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
    func callNotifier(title : String){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: title), object: nil, userInfo: nil)
    }
    
    
    
    func showLoading() {

        DispatchQueue.main.async {
            
            ViewLoader.shared.frame = CGRect(x: 0, y: 0, width:UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            ViewLoader.shared.alpha = 1.0
            
            ViewLoader.shared.btnCross.isHidden = false
            ViewLoader.shared.rotateWithRepeat()
            let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
            keyWindow?.addSubview(ViewLoader.shared)
        }
        
     }
    
     func hideLoading() {
        DispatchQueue.main.async {
            if (ViewLoader.shared.activityIndicator != nil) {
                ViewLoader.shared.activityIndicator.stopAnimating()
            }
            ViewLoader.shared.stopLoader = true
            ViewLoader.shared.removeFromSuperview()
        }
    }
    
}

extension UIApplication {

    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {


        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


extension UIImageView {
    
    func setCatchImage(url:String) {
        
        let new = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let pictureURL = URL(string:new)!
        self.sd_setImage(with:pictureURL , placeholderImage: nil, options: .refreshCached, completed: nil)
        
    }
    
}
