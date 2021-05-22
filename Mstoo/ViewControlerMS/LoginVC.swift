//
//  LoginVC.swift
//  Mstoo
//
//  Created by Vishal on 20/07/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import GoogleSignIn
import FirebaseAuth

class LoginVC: UIViewController,UITextFieldDelegate,GIDSignInDelegate
{
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var fbBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.googleBtn.isHidden = false
        self.fbBtn.isHidden = false
        
        email.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        password.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)

        self.email.layer.borderWidth = 1.0
        self.email.layer.borderColor = UIColor.black.cgColor
        
        self.password.layer.borderWidth = 1.0
        self.password.layer.borderColor = UIColor.black.cgColor
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        self.hideSocialLogin()
    }
    
    private func validateLogin(email : String? , password : String?) -> (String,Bool)
    {
        if (email == "")
        {
            return (NSLocalizedString("Enter email", comment: "Enter email"),false)
        }
        else if (password == "")
        {
            return (NSLocalizedString("Enter password", comment: "Enter password"),false)
        }
        else if !(email?.isValidEmail())!
        {
            return (NSLocalizedString("Email is not valid", comment: "Email is not valid"),false)
        }
        else
        {
            return ("",true)
        }
    }
}

extension LoginVC
{
    func hideSocialLogin()
    {
        let userDict = [String : Any]()
        
        ServiceHelper.request(params: userDict, method: .get, baseWebUrl:baseUrl , useToken: "no" , apiName: hideSocialLoginUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = response!["data"] as? Dictionary<String, AnyObject>
                    print(jsonResult!)
                    
                    if let getValue = jsonResult!["hide_url"]
                    {
                        if getValue.boolValue
                        {
                            self.googleBtn.isHidden = true
                            self.fbBtn.isHidden = true
                        }
                        else
                        {
                            self.googleBtn.isHidden = false
                            self.fbBtn.isHidden = false
                        }
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
    
//    func firebasesignup()
// {
//        Auth.auth().createUser(withEmail: self.email.text!, password: self.password.text!) {(user, error) in
//                                                      if user != nil {
//                                                          print("User Has SignUp")
//                                                      }
//                                                      if error != nil {
//                                                          print(":(",error as Any)
//                                                      }
//                                                  }
//    }
    
    
    func firebasesignup()
    {
        Auth.auth().createUser(withEmail: self.email.text!, password: self.password.text!) {(user, error) in
                                                      if user != nil {
                                                          print("User Has SignUp")
                                                        
                                                        let user = Auth.auth().currentUser
                                                        let uid = user?.uid
                                                        print("uid",uid as Any)
                                                        defaults.set((uid as AnyObject).stringValue, forKey: kfirebaseid)
                                                      }
                                                      if error != nil {
                                                          print(":(",error as Any)
                                                      }
                                                  }
    }
    
    func handelLogIn() {
//        guard let email = emailIdTF.text, let password = passwordTF.text else {
//            return
//        }
        
        Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
            if error != nil {
                return
            }
            // sucessfully logged in
       //     self.messagesController?.fetchUserAndSetNavBarTitle()
          //  self.dismiss(animated: true, completion: nil)
            self.callLogin()
        })
    }
    
    func callLogin()
    {
        var userDict = [String : Any]()
        userDict["email"] = email.text
        userDict["password"] = password.text
        
        ServiceHelper.request(params: userDict, method: .post, baseWebUrl:baseUrl , useToken: "no" , apiName: loginUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = response!["data"] as? Dictionary<String, AnyObject>
                    print(jsonResult!)
                    
                    defaults.set("yes", forKey: "checkUserLogin")
                    defaults.set(jsonResult!["access_token"], forKey: "accessToken")
                    
                    if let userData = jsonResult!["user"] as? NSDictionary
                    {
                        if let userid = userData["id"]
                        {
                            defaults.set((userid as AnyObject).stringValue, forKey: "userId")
                            defaults.set(userData["firebase_id"] as Any, forKey: kfirebaseid)
                            defaults.set(userData["email"] as Any, forKey: kuseremail)
                            defaults.set(userData["name"] as Any, forKey: kusername)
                            defaults.set(self.password.text as Any, forKey: "kpassword")

                            Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { [weak self] authResult, error in
                              guard let strongSelf = self else { return }
                              // ...
                            }
                            let alert = UIAlertController(title: "Welcome!", message: (userData["name"] as! String), preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: {action in
                                self.dismiss(animated: true, completion: nil)
                            })
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
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
    
    func verifyFacebookUserData(fbId: String?, name: String?, email: String?, userStatus: String?)
    {
        var userDict = [String : Any]()
        userDict["social_id"] = fbId
        userDict["name"] = name
        userDict["email"] = email
        if userStatus == "facebook"
        {
            userDict["provider"] = "facebook"
        }
        else
        {
            userDict["provider"] = "google"
        }

        print(userDict)

        ServiceHelper.request(params: userDict, method: .post, baseWebUrl:baseUrl , useToken: "no" , apiName: fbLoginUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = response!["data"] as? Dictionary<String, AnyObject>
                    print(jsonResult!)
                    
                    defaults.set("yes", forKey: "checkUserLogin")
                    defaults.set(jsonResult!["access_token"], forKey: "accessToken")
                    
                    if let userData = jsonResult!["user"] as? NSDictionary
                    {
                        if let userid = userData["id"]
                        {
                            defaults.set((userid as AnyObject).stringValue, forKey: "userId")
                        }
                    }
                    
                    self.dismiss(animated: true, completion: nil)
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

extension LoginVC
{
    @IBAction func loginAction(_ sender: Any)
    {
        self.view.endEditing(true)
        
        let login = validateLogin(email: email.text, password: password.text)
        if login.1 == true
        {
            self.callLogin()
            //self.handelLogIn()
        }
        else
        {
            self.showToast(message: login.0)
        }
    }
    
    @IBAction func registerAction(_ sender: Any)
    {
        self.performSegue(withIdentifier: "showRegister", sender: nil)
    }
    
    @IBAction func loginWithGoogle(_ sender: Any)
    {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction private func loginWithFacebook()
    {
        let loginManager = LoginManager()
        
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { result in
            self.loginManagerDidComplete(result)
        }
    }
}

extension LoginVC
{
    func showToast(message : String)
    {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height/2, width: 150, height: 35))
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
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
      if let error = error
      {
        if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue
        {
          print("The user has not signed in before or they have since signed out.")
        }
        else
        {
          print("\(error.localizedDescription)")
        }
        return
      }
      
      let userId = user.userID
      let fullName = user.profile.name
      let email = user.profile.email
      
      self.verifyFacebookUserData(fbId: userId, name: fullName, email: email, userStatus: "google")
    }
    
    func loginManagerDidComplete(_ result: LoginResult)
    {
        print(result)
        switch result
        {
        case .cancelled:
            let alert = UIAlertController(title: "Login Cancelled", message: "User cancelled login.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
            
        case .failed(let error):
            let alert = UIAlertController(title: "Login Fail", message: "Login failed with error \(error)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert, animated: true, completion: nil)
            
        case .success:
            let connection  = GraphRequestConnection()
            connection.add(GraphRequest(graphPath: "me", parameters: ["fields" : "id,first_name,last_name,email,name"], tokenString: AccessToken.current?.tokenString, version: Settings.defaultGraphAPIVersion, httpMethod: .get)) { (connection, values, error) in
                if let res = values
                {
                    if let response = res as? [String:Any]
                    {
                        self.verifyFacebookUserData(fbId: (response["id"]! as! String), name: (response["name"]! as! String), email: (response["email"]! as! String), userStatus: "facebook")
                    }
                }
            }
            connection.start()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == email
        {
            password.becomeFirstResponder()
        }
        else
        {
            password.resignFirstResponder()
        }
        return true
    }
}
