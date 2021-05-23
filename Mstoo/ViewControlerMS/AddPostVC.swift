//
//  AddPostVC.swift
//  Mstoo
//
//  Created by Vishal on 03/09/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation
import AVKit
import Photos

class addImagesCell: UICollectionViewCell
{
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var removeBtn: UIButton!
}

class AddPostVC: UIViewController,CLLocationManagerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,UITextViewDelegate
{
    @IBOutlet weak var addImagesCollection: UICollectionView!
    @IBOutlet weak var cateLbl: UILabel!
    @IBOutlet weak var locBtn: UIButton!
    @IBOutlet weak var fixed: UITextField!
    @IBOutlet weak var perMonth: UITextField!
    @IBOutlet weak var perWeek: UITextField!
    @IBOutlet weak var perDay: UITextField!
    @IBOutlet weak var titleFld: UITextField!
    @IBOutlet weak var amountFld: UITextField!
    @IBOutlet weak var youtubeFld: UITextField!
    @IBOutlet weak var locFld: UITextField!
    @IBOutlet weak var descriptionView: UITextView!

    var cateName: String = ""
    var subCateName: String = ""
    var getCateId: String = ""
    var getSubCateId: String = ""
    var fetured = 0
    
    private var placesClient: GMSPlacesClient!
    var locationManager:CLLocationManager!
    var imagePicker:UIImagePickerController!
    var arrImages: [UIImage] = []
    var latitude : Double?
    var longitude : Double?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.cateLbl.text = self.cateName + " " + ">" + " " + self.subCateName
        
        self.titleFld.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        self.amountFld.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        self.youtubeFld.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        
        self.locFld.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 30)
        self.locFld.layer.borderWidth = 1.0
        self.locFld.layer.borderColor = UIColor.black.cgColor
        
        self.locBtn.layer.borderWidth = 1.0
        self.locBtn.layer.borderColor = UIColor.black.cgColor
        
        self.titleFld.layer.borderWidth = 1.0
        self.titleFld.layer.borderColor = UIColor.black.cgColor
        
        self.amountFld.layer.borderWidth = 1.0
        self.amountFld.layer.borderColor = UIColor.black.cgColor
        
        self.youtubeFld.layer.borderWidth = 1.0
        self.youtubeFld.layer.borderColor = UIColor.black.cgColor
        
        self.descriptionView.layer.borderWidth = 1.0
        self.descriptionView.layer.borderColor = UIColor.black.cgColor
        
        self.addImagesCollection.layer.cornerRadius = 8.0
        self.addImagesCollection.layer.borderWidth = 1.0
        self.addImagesCollection.layer.borderColor = ConstantGlobal.Color.DarkBlack.cgColor
        self.addImagesCollection.layer.masksToBounds = true

//        self.addImagesCollection.layer.backgroundColor = UIColor.white.cgColor
//        self.addImagesCollection.layer.shadowColor = UIColor.gray.cgColor
//        self.addImagesCollection.layer.shadowOffset = CGSize(width: 0, height: 2.0)
//        self.addImagesCollection.layer.shadowRadius = 2.0
//        self.addImagesCollection.layer.shadowOpacity = 1.0
//        self.addImagesCollection.layer.masksToBounds = false
                
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.startUpdatingLocation()
        }
        placesClient = GMSPlacesClient.shared()
        
        //--- add UIToolBar on keyboard and Done button on UIToolBar ---//
        //self.addDoneButtonOnKeyboard()
        self.hideKeyboardWhenTappedAround()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationItem.backButtonTitle = "Add Post"
    }
    private func validateRegister(title : String? , amount : String?, youtube : String?, desc : String? , fixed : String?, permonth : String?, perweek : String?, perday : String?) -> (String,Bool)
    {
        if (title == "")
        {
            return (NSLocalizedString("Enter title", comment: "Enter title"),false)
        }
        else if (amount == "")
        {
            return (NSLocalizedString("Enter amount", comment: "Enter amount"),false)
        }
//        else if (youtube == "")
//        {
//            return (NSLocalizedString("Enter youtube URL", comment: "Enter youtube URL"),false)
//        }
        else if (desc == "")
        {
            return (NSLocalizedString("Enter description", comment: "Enter description"),false)
        }
//        else if (fixed == "")
//        {
//            return (NSLocalizedString("Enter fixed price", comment: "Enter fixed price"),false)
//        }
//        else if (permonth == "")
//        {
//            return (NSLocalizedString("Enter per month price", comment: "Enter per month price"),false)
//        }
//        else if (perweek == "")
//        {
//            return (NSLocalizedString("Enter per week price", comment: "Enter per week price"),false)
//        }
//        else if (perday == "")
//        {
//            return (NSLocalizedString("Enter per day price", comment: "Enter per day price"),false)
//        }
//        else if (self.locBtn.currentTitle == "Select your location")
//        {
//            return (NSLocalizedString("Please add location", comment: "Please add location"),false)
//        }
        else if (self.arrImages.count == 0)
        {
            return (NSLocalizedString("Please add images", comment: "Please add images"),false)
        }
        else
        {
            return ("",true)
        }
    }
}

extension AddPostVC {
    
    
    func sendPostAction(){
        let alert = UIAlertController(title: "Alert", message: "Do you want to add this post as fetured post?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.fetured = 1
            self.sendPost()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            self.fetured = 0
            self.sendPost()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendPost() {
        
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
                
        let boundary = UUID().uuidString

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let finalUrl = baseUrl + addPostUrl
        
        var urlRequest = URLRequest(url: URL(string: finalUrl)!)
        urlRequest.timeoutInterval = 60
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(defaults.value(forKey: "accessToken")!)" , forHTTPHeaderField: "Authorization")

        var data = Data()
        
        let latStr: String = String(format: "%.4f", latitude!)
        let lonStr: String = String(format: "%.4f", longitude!)

        let params: [String : String]? = [
            "category" : self.getCateId,
            "sub_category" : self.getSubCateId,
            "location_name" : self.locFld.text!,
            "fixed_price" : self.fixed.text!,
            "per_month_price" : self.perMonth.text!,
            "per_week_price" : self.perWeek.text!,
            "per_day_price" : self.perDay.text!,
            "title" : self.titleFld.text!,
            "description" : self.descriptionView.text!,
            "security_amount" : self.amountFld.text!,
            "youtube_url" : self.youtubeFld.text!,
            "latitude" : latStr,
            "longitude" : lonStr,
            "images_count": "\(arrImages.count)",
            "type": "normal",
            "is_featured":"\(fetured)"
        ]
        
        print(params as Any)
                
        for (key, value) in params!
        {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append(value.data(using: .utf8)!)
        }
        for(index,getImage) in self.arrImages.enumerated()
        {
            print(index)
            let image = getImage
            let currentDate = NSDate()
            let timestampFromDate = convertToTimestamp(date: currentDate)
            let imageName = timestampFromDate + ".png"            
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"image\(index+1)\"; filename=\"\(imageName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            data.append(image.pngData()!)
        }
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
                        for controller in self.navigationController!.viewControllers as Array
                        {
                            if controller.isKind(of: ViewController.self)
                            {
                                HelperApp.shared.isNewPost = true
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }
                        }
                    }
                }
            }
        }).resume()
    }
}

extension AddPostVC
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: 100, height: 130)
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cellID = "addImagesCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath as IndexPath) as! addImagesCell
        cell.backgroundColor = UIColor.white

        cell.addImage.image = self.arrImages[indexPath.row]
        cell.addImage.layer.cornerRadius = 50
       
        cell.removeBtn.addTarget(self, action: #selector(removeImage), for: .touchUpInside)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
    }
}

extension AddPostVC
{
    @objc func removeImage(sender: UIButton)
    {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.addImagesCollection)
        let indexPath = self.addImagesCollection.indexPathForItem(at: buttonPosition)
        if indexPath != nil
        {
            self.arrImages.remove(at: indexPath!.row)
            self.addImagesCollection.deleteItems(at: [indexPath!])
            self.addImagesCollection.reloadData()
        }
    }
    
    @IBAction func addImagesAction(_ sender: Any)
    {
        self.showPickerOption()
    }
    
    @IBAction func getCurrentPlace(_ sender: UIButton)
    {
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue))!
        placesClient?.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
          (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }

          if let placeLikelihoodList = placeLikelihoodList {
            for likelihood in placeLikelihoodList {
              let place = likelihood.place
              print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
              print("Current PlaceID \(String(describing: place.placeID))")
            }
          }
        })
        
//        let placeFields = GMSPlaceField(rawValue:
//          GMSPlaceField.name.rawValue | GMSPlaceField.formattedAddress.rawValue
//        )!
//        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
//          guard let strongSelf = self else {
//            return
//          }
//
//          guard error == nil else
//          {
//            print("Current place error: \(error?.localizedDescription ?? "")")
//            return
//          }
//
//          guard let place = placeLikelihoods?.first?.place else
//          {
//            strongSelf.locBtn.setTitle("No current place", for: .normal)
//            return
//          }
//          
//          strongSelf.locBtn.setTitle(place.name, for: .normal)
//          //strongSelf.addressLabel.text = place.formattedAddress
//        }
    }
    
    @IBAction func submitAction(_ sender: Any)
    {
        self.view.endEditing(true)
        
        let register = validateRegister(title: self.titleFld.text, amount: self.amountFld.text, youtube: self.youtubeFld.text, desc: self.descriptionView.text, fixed: self.fixed.text, permonth: self.perMonth.text, perweek: self.perWeek.text, perday: self.perDay.text)
        if register.1 == true
        {
            self.sendPostAction()
        }
        else
        {
            self.showToast(message: register.0)
        }
    }
}

// MARK: - Image Picker

extension AddPostVC
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

extension AddPostVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
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
            self.arrImages.append(compressImg)
            self.addImagesCollection.reloadData()
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddPostVC
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        latitude = location.latitude
        longitude = location.longitude
        
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil)
            {
                print("error in reverseGeocode")
            }
            if let placemark = placemarks
            {
                if placemark.count>0
                {
                    let placemark = placemarks![0]
                    print(placemark)
                    print(placemark.locality!)
                    print(placemark.administrativeArea!)
                    print(placemark.country!)

                    self.locFld.text = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
                }
            }
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
}

extension AddPostVC
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
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItem.Style.done, target: self, action: #selector(AddPostVC.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.fixed.inputAccessoryView = doneToolbar
        self.perMonth.inputAccessoryView = doneToolbar
        self.perWeek.inputAccessoryView = doneToolbar
        self.perDay.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        if self.fixed.isFirstResponder
        {
            self.perMonth.becomeFirstResponder()
        }
        else if self.perMonth.isFirstResponder
        {
            self.perWeek.becomeFirstResponder()
        }
        else if self.perWeek.isFirstResponder
        {
            self.perDay.becomeFirstResponder()
        }
        else if self.perDay.isFirstResponder
        {
            self.titleFld.becomeFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == locFld
        {
            locFld.resignFirstResponder()
        }
        else if textField == titleFld
        {
            amountFld.becomeFirstResponder()
        }
        else if textField == amountFld
        {
            youtubeFld.becomeFirstResponder()
        }
        else
        {
            youtubeFld.resignFirstResponder()
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if (text == "\n")
        {
            textView.resignFirstResponder()
        }
        return true
    }

}
