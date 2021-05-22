//
//  RegisterVC.swift
//  Mstoo
//
//  Created by Vishal on 29/07/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit
import AVKit
import Photos
import FacebookCore
import FacebookLogin
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class RegisterVC: UIViewController,UITextFieldDelegate,GIDSignInDelegate
{
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var contact: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var repassword: UITextField!
    @IBOutlet weak var referralCode: UITextField!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var fbBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    
    var imagePicker:UIImagePickerController!

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.googleBtn.isHidden = false
        self.fbBtn.isHidden = false
        
        name.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        contact.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        email.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        password.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        repassword.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        referralCode.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        
        self.name.layer.borderWidth = 1.0
        self.name.layer.borderColor = UIColor.black.cgColor
        self.contact.layer.borderWidth = 1.0
        self.contact.layer.borderColor = UIColor.black.cgColor
        self.email.layer.borderWidth = 1.0
        self.email.layer.borderColor = UIColor.black.cgColor
        self.password.layer.borderWidth = 1.0
        self.password.layer.borderColor = UIColor.black.cgColor
        self.repassword.layer.borderWidth = 1.0
        self.repassword.layer.borderColor = UIColor.black.cgColor
        self.referralCode.layer.borderWidth = 1.0
        self.referralCode.layer.borderColor = UIColor.black.cgColor
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterVC.showPickerOption))
        userImg.isUserInteractionEnabled = true
        userImg.addGestureRecognizer(tapGestureRecognizer)
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        self.hideSocialLogin()
    }
    
    override func viewDidLayoutSubviews()
    {
        userImg.layer.masksToBounds = false
        userImg.layer.cornerRadius = userImg.frame.size.width/2
        userImg.clipsToBounds = true
    }
    
    private func validateRegister(email : String? , password : String?, confirmpassword : String?, fName : String? , phone : String?) -> (String,Bool)
    {
        if (fName == "")
        {
            return (NSLocalizedString("Enter name", comment: "Enter name"),false)
        }
        else if (phone == "")
        {
            return (NSLocalizedString("Enter phone number", comment: "Enter last number"),false)
        }
        else if (email == "")
        {
            return (NSLocalizedString("Enter email", comment: "Enter email"),false)
        }
        else if (password == "")
        {
            return (NSLocalizedString("Enter password", comment: "Enter password"),false)
        }
        else if (confirmpassword == "")
        {
            return (NSLocalizedString("Enter confirm password", comment: "Enter confirm password"),false)
        }
        else if !(email?.isValidEmail())!
        {
            return (NSLocalizedString("Email is not valid", comment: "Email is not valid"),false)
        }
        else if !(password == confirmpassword)
        {
            return (NSLocalizedString("Password do not match", comment: "Password do not match"),false)
        }
        else
        {
            return ("",true)
        }
    }
}

extension RegisterVC
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
    
    func callRegister(firebaseId: String)
    {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
        } else {
            // Fallback on earlier versions
        }
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        guard let image = userImg.image else { return  }

        let currentDate = NSDate()
        let timestampFromDate = convertToTimestamp(date: currentDate)
        let imageName = timestampFromDate + ".png"

        let boundary = UUID().uuidString

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let finalUrl = baseUrl + registerUrl
        var urlRequest = URLRequest(url: URL(string: finalUrl)!)
        urlRequest.timeoutInterval = 70
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        data.append(name.text!.data(using: .utf8)!)

        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n".data(using: .utf8)!)
        data.append(email.text!.data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"mobile\"\r\n\r\n".data(using: .utf8)!)
        data.append(contact.text!.data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"password\"\r\n\r\n".data(using: .utf8)!)
        data.append(password.text!.data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"refer_code\"\r\n\r\n".data(using: .utf8)!)
        data.append(referralCode.text!.data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"firebase_id\"\r\n\r\n".data(using: .utf8)!)
        data.append(firebaseId.data(using: .utf8)!)

        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(imageName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            
            if(error != nil)
            {
                print("\(error!.localizedDescription)")
            }
            
            guard let responseData = responseData
            else
            {
                DispatchQueue.main.async
                {
                    alert.dismiss(animated: true, completion: nil)
                }
                print("no response data")
                return
            }
            
            if let responseString = String(data: responseData, encoding: .utf8)
            {
                print("uploaded to: \(responseString)")
                let result = try! JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.mutableContainers)
                let statusCode = (result as AnyObject).object(forKey: "status") as! NSInteger
                if statusCode == 200
                {
                    DispatchQueue.main.async
                    {
                        alert.dismiss(animated: true, completion: nil)

                        let alert = UIAlertController(title: "Alert!", message: "Otp sent to registered email successfully!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: {action in
                            self.dismiss(animated: true, completion: nil)
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        alert.dismiss(animated: true, completion: nil)
                        self.showToast(message: "Something went wrong")
                    }
                }
            }
        }).resume()
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
                    self.presentingViewController!.presentingViewController!.dismiss(animated: true, completion: {});
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

extension RegisterVC
{
    func firebasesignup()
    {
        Auth.auth().createUser(withEmail: self.email.text!, password: self.password.text!) {(user, error) in
                                                      if user != nil {
                                                          print("User Has SignUp")

                                                        let user = Auth.auth().currentUser
                                                        let uid = user?.uid
                                                        print("uid",uid as Any)
                                                        self.callRegister(firebaseId: uid ?? "")
                                                      }
                                                      if error != nil {
                                                          print(":(",error as Any)
                                                      }
                                                  }
    }
    
    @IBAction func registerAction(_ sender: Any)
    {
        self.view.endEditing(true)

        let register = validateRegister(email: email.text, password: password.text, confirmpassword: repassword.text, fName: name.text, phone: contact.text)
        if register.1 == true
        {
            self.firebasesignup()
        }
        else
        {
            self.showToast(message: register.0)
        }
    }
    @IBAction func goBackToLoginAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
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

// MARK: - Image Picker

extension RegisterVC
{
    typealias PermissionStatus = (_ status: Int, _ isGranted: Bool) -> ()
    
    func cameraAccess(permissionWithStatus block: @escaping PermissionStatus)
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status
            {
            case .authorized:
                block(AVAuthorizationStatus.authorized.rawValue, true)
            case .denied:
                block(AVAuthorizationStatus.denied.rawValue, false)
            case .restricted:
                block(AVAuthorizationStatus.restricted.rawValue, false)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (grant) in
                    if grant {
                        block(AVAuthorizationStatus.authorized.rawValue, grant)
                    }else{
                        self.showAccessPopup(title: kCameraAccessTitle, msg: kCameraAccessMsg)
                        block(AVAuthorizationStatus.denied.rawValue, grant)
                    }
                })
            @unknown default:
                fatalError()
            }
        }
        else
        {
            showAccessPopup(title: kCameraAccessTitle, msg: kCameraAccessMsg)
            block(AVAuthorizationStatus.restricted.rawValue, false)
        }
    }
    
    func showAccessPopup(title: String?, msg: String?)
    {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func photoLibraryAccess(block: @escaping PermissionStatus)
    {
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if status == .authorized
        {
            block(status.rawValue, true)
        }
        else if status == .notDetermined
        {
            PHPhotoLibrary.requestAuthorization { (perStatus) in
                if perStatus == PHAuthorizationStatus.authorized
                {
                    block(perStatus.rawValue, true)
                }
                else
                {
                    self.showAccessPopup(title: kPhotosAccessTitle, msg: kPhotosAccessMsg)
                    block(perStatus.rawValue, false)
                }
            }
        }
        else
        {
            self.showAccessPopup(title: kPhotosAccessTitle, msg: kPhotosAccessMsg)
            block(status.rawValue, false)
        }
    }
}

extension RegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @objc func showPickerOption()
    {
        let actionSheet = UIAlertController(title:nil, message:nil, preferredStyle:.actionSheet)
        let cameraAction = UIAlertAction(title:"Camera", style:.default) { (action) in
            self.openCamera()
        }
        
        let photoLibAction = UIAlertAction(title:"Photo Library", style:.default) { (action) in
            self.openLibrary()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel, handler:nil)
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(photoLibAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated:true, completion:nil)
    }
    
    func openCamera()
    {
        cameraAccess { (status, isGrant) in
            if isGrant
            {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
                {
                    DispatchQueue.main.async
                    {
                        self.imagePicker = UIImagePickerController()
                        self.imagePicker.delegate = self
                        self.imagePicker.sourceType = UIImagePickerController.SourceType.camera;
                        self.imagePicker.allowsEditing = false
                        self.imagePicker.cameraCaptureMode = .photo
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func openLibrary()
    {
        photoLibraryAccess { (status, isGrant) in
            if isGrant
            {
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)
                {
                    DispatchQueue.main.async
                    {
                        self.imagePicker = UIImagePickerController()
                        self.imagePicker.delegate = self
                        self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary;
                        self.imagePicker.allowsEditing = false
                        self.present(self.imagePicker, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            let compressImg = image.fixedOrientation().scaleAndManageAspectRatio(_minImageSize.width)
            userImg.image = compressImg
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }    
}

extension RegisterVC
{
    func showToast(message : String)
    {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 250, height: 35))
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
        if textField == name
        {
            contact.becomeFirstResponder()
        }
        else if textField == contact
        {
            email.becomeFirstResponder()
        }
        else if textField == email
        {
            password.becomeFirstResponder()
        }
        else if textField == password
        {
            repassword.becomeFirstResponder()
        }
        else if textField == repassword
        {
            referralCode.becomeFirstResponder()
        }
        else
        {
            referralCode.resignFirstResponder()
        }
        return true
    }
}
