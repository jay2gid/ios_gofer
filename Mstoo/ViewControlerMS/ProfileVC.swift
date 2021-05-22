//
//  ProfileVC.swift
//  Mstoo
//
//  Created by Vishal on 01/09/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit
import SDWebImage
import AVKit
import Photos

class ProfileVC: UIViewController
{
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var changeBtn: UIButton!

    @IBOutlet weak var emailLbl: UITextField!
    @IBOutlet weak var phoneLbl: UITextField!
    @IBOutlet weak var userContentView: UIView!
    @IBOutlet weak var emailContentView: UIView!
    @IBOutlet weak var contactContentView: UIView!

    var imagePicker:UIImagePickerController!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.getUserProfile()
        
        self.userContentView.layer.cornerRadius = 5.0
        self.userContentView.layer.borderWidth = 1.0
        self.userContentView.layer.borderColor = UIColor.clear.cgColor
        self.userContentView.layer.masksToBounds = true

//        userContentView.dropShadow(color: .lightGray, opacity: 1.0, offSet: CGSize(width: 8, height: 1), radius: 10, scale: true)
//        emailContentView.dropShadow(color: .lightGray, opacity: 1.0, offSet: CGSize(width: 8, height: 1), radius: 10, scale: true)
//        contactContentView.dropShadow(color: .lightGray, opacity: 1.0, offSet: CGSize(width: 8, height: 1), radius: 10, scale: true)
        updateBtn.layer.cornerRadius = 18.0
        changeBtn.layer.cornerRadius = 18.0
        self.bordershadow(smallview: userContentView)
        self.bordershadow(smallview: emailContentView)
        self.bordershadow(smallview: contactContentView)
    }
    
    func bordershadow(smallview: UIView)
    {
        smallview.layer.backgroundColor = UIColor.white.cgColor
        smallview.layer.shadowColor = UIColor.gray.cgColor
        smallview.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        smallview.layer.shadowRadius = 2.0
        smallview.layer.shadowOpacity = 1.0
        smallview.layer.masksToBounds = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}

extension ProfileVC
{
    func getUserProfile()
    {
        var userDict = [String : Any]()
        
        if UserDefaults.standard.value(forKey: "userId") != nil
        {
            userDict["user_id"] = (defaults.value(forKey: "userId")!)
        }
        
        ServiceHelper.request(params: userDict, method: .post, baseWebUrl:baseUrl , useToken: "no" , apiName: getProfileUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = response!["data"] as? Dictionary<String, AnyObject>
                    print(jsonResult!)
                    
                    if let userData = jsonResult!["user"] as? NSDictionary
                    {
                        if let username = userData["name"]
                        {
                            self.nameLbl.text = (username as! String)
                        }
                        if let useremail = userData["email"]
                        {
                            self.emailLbl.text = (useremail as! String)
                        }
                        if let userphone = userData["mobile"]
                        {
                            self.phoneLbl.text = (userphone as! String)
                        }
                        if let userimage = userData["image"]
                        {
                            let replacedString = (userimage as AnyObject).replacingOccurrences(of: " ", with: "%20")
                            let url = URL(string: replacedString)
                            self.userImg.sd_setImage(with: url, placeholderImage: nil)
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
    
    @IBAction func UpdateAction(_ sender: Any)
    {
        self.view.endEditing(true)

        let register = validateRegister(email: emailLbl.text, phone: phoneLbl.text)
        if register.1 == true
        {
            self.updateProfile()
        }
        else
        {
            self.showToast(message: register.0)
        }
    }
    
    private func validateRegister(email : String? , phone : String?) -> (String,Bool)
    {
        if (phone == "")
        {
            return (NSLocalizedString("Enter phone number", comment: "Enter last number"),false)
        }
        else if (email == "")
        {
            return (NSLocalizedString("Enter email", comment: "Enter email"),false)
        }
        
        else
        {
            return ("",true)
        }
    }
    
    func updateProfile()
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

        let finalUrl = baseUrl + updateProfileUrl
        var urlRequest = URLRequest(url: URL(string: finalUrl)!)
        urlRequest.timeoutInterval = 70
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(defaults.value(forKey: "accessToken")!)" , forHTTPHeaderField: "Authorization")


        var data = Data()

        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        data.append(nameLbl.text!.data(using: .utf8)!)

        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"mobile\"\r\n\r\n".data(using: .utf8)!)
        data.append(phoneLbl.text!.data(using: .utf8)!)
        
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
                        self.dismiss(animated: true, completion: nil)
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
}

extension ProfileVC
{
    @IBAction func backAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openMedia(_ sender: Any)
    {
        self.showPickerOption()
        
    }

}

extension ProfileVC
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
}


extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
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

// MARK: - Image Picker

extension ProfileVC
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
