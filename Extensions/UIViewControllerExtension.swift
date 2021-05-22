//
//  UIViewControllerExtension.swift
//  FansKick
//
//  Created by FansKick-Raj on 11/10/2017.
//  Copyright © 2017 FansKick Dev. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self
            || (self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController)
            || self.tabBarController?.presentingViewController is UITabBarController
    }
    
    public func moveUIComponentWithValue(_ value: CGFloat, forLayoutConstraint: NSLayoutConstraint, forDuration: TimeInterval) {
        UIView.beginAnimations("MoveView", context: nil)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationDuration(forDuration)
        forLayoutConstraint.constant = value
        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
        UIView.commitAnimations()
    }
    
    public func animateUIComponentWithValue(_ value: CGFloat, forLayoutConstraint: NSLayoutConstraint, forDuration: TimeInterval) {
        
        forLayoutConstraint.constant = value
        
        UIView.animate(withDuration: forDuration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.view.layoutSubviews()
            self.view.layoutIfNeeded()
            
        }) { (Bool) -> Void in
            // do anything on completion
        }
    }
    
    func backViewController() -> UIViewController? {
        if let stack = self.navigationController?.viewControllers {
            for count in 0...stack.count - 1 {
                if(stack[count] == self) {
//Debug.log("viewController     \(stack[count-1])")
                    
                    return stack[count-1]
                }
            }
        }
        return nil
    }
    
    func getToolBarWithDoneButton() -> UIToolbar {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.blue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(doneBarButtonAction(_:)))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: nil,
                                          action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        return toolBar;

    }
    
    @objc private func doneBarButtonAction(_ button : UIButton) {
        view.endEditing(true)
    }
    
//    func getDayOfWeek(today:String)->Int {
//
//        let formatter  = DateFormatter()
//        formatter.dateFormat = DateFormat.yyyyMMddHHmmss.rV
//        let todayDate = formatter.date(from: today)!
//        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
//        myCalendar.firstWeekday = 1
//        let myComponents = myCalendar.components(.weekday, from: todayDate)
//        let weekDay = myComponents.weekday
//        return weekDay!
//    }
    
//    func isWeekend() -> Bool {
//        
//        let bool = defaults.value(forKey: "isWeekend") as! Bool
//        
//        return bool
//    }
//    
//    func isInsideProvince() -> Bool {
//        
//        let bool = defaults.value(forKey: "isInsideProvince") as! Bool
//        
//        return bool
//    }
    
    func showToast(message : String) throws {
        
        let toastLabel = UILabel(frame: CGRect(x: 0.0, y: 40.0, width: self.view.frame.size.width, height: 80))
        toastLabel.backgroundColor = UIColor.gray
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 2
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 0
        toastLabel.clipsToBounds  =  true
        appDelegate?.window!.addSubview(toastLabel)
        UIView.animate(withDuration: 10.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
        toastLabel.addTapToDismissLabel()
    }
    
    
    func addTapToHideKeyboard() throws {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnViewTap))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboardOnViewTap() throws {
        self.view.endEditing(true)
    }
    
    func moveBack() throws {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func moveBackToRoot() throws {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func moveBackCount(_count: Int) throws {
        guard let viewControllers = self.navigationController?.viewControllers else { return }
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - _count], animated: true)
    }
    
    func present(_ vc: UIViewController) throws {
        present(vc, animated: true, completion: nil)
    }
    
    func dismissController() throws {
        dismiss(animated: true, completion: nil)
    }
    
    /*func checkIfLocationServicesEnabled() {
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
                
            case .denied:
                
                let _ = AlertViewController.alert("App Permission Denied", message: "To re-enable, please go to Settings and turn on Location Service for this app. We will be using the \"Financial District\" as your default location.", buttons: ["YES", "NO"], tapBlock: { (alertAction, index) in
                    if index == 0 {
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    }
                })
                
                break
            case .notDetermined, .restricted:
                logInfo("No access")
                let _ = AlertViewController.alert("", message: "Unable to update location, Please enable Location Services from your smartphone's settings menu. We will be using the \"Financial District\" as your default location.", buttons: ["YES", "NO"], tapBlock: { (alertAction, index) in
                    if index == 0 {
                        UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                    }
                })
                break
            case .authorizedAlways, .authorizedWhenInUse:
                logInfo("Access")
            }
        } else {
            
            let _ = AlertViewController.alert("", message: "Unable to update location, Please enable Location Services from your smartphone's settings menu. We will be using the \"Financial District\" as your default location.", buttons: ["YES", "NO"], tapBlock: { (alertAction, index) in
                if index == 0 {
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
            })
        }
    }
    
    func addressString(location: CLLocation, completionBlock: @escaping (String?) -> Void?) ->Void  {
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                logInfo("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                
                //address = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                
                let addressString = placemark.name
                //logInfo("placemarks>>>>>>>>>>   \(placemarks)")
                // see more info via log for--- placemark, placemark.addressDictionary, placemark.region, placemark.country, placemark.locality (Extract the city name), placemark.name, placemark.ocean, placemark.postalCode, placemark.subLocality, placemark.location
                completionBlock(addressString)
            } else {
                logInfo("Problem with the data received from geocoder")
            }
        })

    }*/

}
