//
//  ChangePasswordVC.swift
//  Mstoo
//
//  Created by Vishal on 01/09/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordVC: UIViewController,UITextFieldDelegate
{
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var reEntePassword: UITextField!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        password.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        reEntePassword.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)

        self.password.layer.borderWidth = 1.0
        self.password.layer.borderColor = UIColor.black.cgColor
        
        self.reEntePassword.layer.borderWidth = 1.0
        self.reEntePassword.layer.borderColor = UIColor.black.cgColor
    }
    
    private func validateChangePassword(new : String?, confirm : String?) -> (String,Bool)
    {
        if (new == "")
        {
            return (NSLocalizedString("Enter new password", comment: "Enter new password"),false)
        }
        else if (confirm == "")
        {
            return (NSLocalizedString("Enter confirm password", comment: "Enter confirm password"),false)
        }
        else if !(new == confirm)
        {
            return (NSLocalizedString("Password do not match", comment: "Password do not match"),false)
        }
        else
        {
            return ("",true)
        }
    }
}

extension ChangePasswordVC
{
    func changePassword()
    {
        var userDict = [String : Any]()
        
        if UserDefaults.standard.value(forKey: "userId") != nil
        {
            userDict["user_id"] = (defaults.value(forKey: "userId")!)
        }
        userDict["password"] = self.password.text
        
        print(userDict)
        
        ServiceHelper.request(params: userDict, method: .post, baseWebUrl: baseUrl , useToken: "yes" , apiName: changePasswordUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    if let data = response![kResponseMsg]
                    {
                        self.changePassword(email: "\(defaults.value(forKey: kuseremail) ?? "")", currentPassword: "\(defaults.value(forKey: "kpassword") ?? "")", newPassword: self.password.text!) { (error) in
                                if error != nil {
                                }
                            }
                        self.password.text = ""
                        self.reEntePassword.text = ""
                        let alert = UIAlertController(title: "Alert", message: (data as! String), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
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
    
    func changePassword(email: String, currentPassword: String, newPassword: String, completion: @escaping (Error?) -> Void) {
            let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error) in
                if let error = error {
                    completion(error)
                }
                else {
                    Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error) in
                        completion(error)
                    })
                }
            })
        }
}

extension ChangePasswordVC
{
    @IBAction func saveActions(_ sender: UIButton)
    {
        self.view.endEditing(true)
        
        let profile = validateChangePassword(new: self.password.text, confirm: self.reEntePassword.text)
        if profile.1 == true
        {
            self.changePassword()
        }
        else
        {
            self.showToast(message: profile.0)
        }
    }
    
    @IBAction func backAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChangePasswordVC
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == password
        {
            reEntePassword.becomeFirstResponder()
        }
        else
        {
            reEntePassword.resignFirstResponder()
        }
        return true
    }
}
