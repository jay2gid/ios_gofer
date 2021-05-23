//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import UIKit
import Photos
import Firebase
import CoreLocation
import IQKeyboardManagerSwift

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate,NVActivityIndicatorViewable
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var inputBar: UIView!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var chatname: UILabel!
    
    typealias NSComparisonResult = Int
    
    var senderemail = String()
    var sendername = String()
    var senderid = String()
    var useravatar = String()

    var firebaseid = String()

    let locationManager = CLLocationManager()
    var items = [Message]()
    let imagePicker = UIImagePickerController()
    let barHeight: CGFloat = 70
    var currentUser: UserFirebase?
    var canSendLocation = true
    var roomid2 = Int32()
    var senderuserid = String()
    var newTimer : Timer?
    var counter = 0
    var newTime = Int()
    var fromchatview =  String()
    
    enum Enum1 : Int {
        case nsOrderedAscending = -1
        case nsOrderedSame
        case nsOrderedDescending
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tabBarController?.tabBar .isHidden = true
        self.title = sendername
        inputBar .isHidden = false
        self.customization()
        self.fetchData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.bookingview(notification:)), name: Notification.Name("stoploading"), object: nil)
        
        inputTextField.textColor = ConstantGlobal.Color.DarkBlack
    }
    @IBAction func backbtn(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func bookingview(notification: Notification)
    {
        self.stopAnimating()
        self.inputBar .isHidden = false
        
    }
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        IQKeyboardManager.shared.enable = false
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.showKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar .isHidden = false

        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
        Message.markMessagesRead(forUserID: "\(roomid2)")
    }
    override var canBecomeFirstResponder: Bool
    {
        return true
    }
    override var inputAccessoryView: UIView?
        {
        get {
            self.inputBar.frame.size.height = self.barHeight
            self.inputBar.clipsToBounds = true
            return self.inputBar
        }
    }
    func customization()
    {
        self.imagePicker.delegate = self
        self.tableView.estimatedRowHeight = self.barHeight
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.contentInset.bottom = self.barHeight
        self.tableView.scrollIndicatorInsets.bottom = self.barHeight
        self.locationManager.delegate = self
    }

    func fetchData()
    {
        if fromchatview  == "Yes"
        {
            roomid2 = Int32(senderuserid)!
        }
        else
        {
            let retValue: ComparisonResult = senderuserid.compare("\(defaults.value(forKey: kfirebaseid)!)")
            print(retValue.rawValue)
            if retValue.rawValue > 0
            {
                roomid2 = ("\(defaults.value(forKey: kfirebaseid)!)" + senderuserid).hashCode()
            }
            else
            {
                roomid2 =  (senderuserid + "\(defaults.value(forKey: kfirebaseid)!)").hashCode()
            }

            print(senderuserid , "\(defaults.value(forKey: kfirebaseid)!)")
            
            print("roomid",roomid2)
        }
        
        self.inputBar .isHidden = true
        startAnimating(CGSize(width: 50,height: 50), type: NVActivityIndicatorType.lineScalePulseOut)
        Message.downloadAllMessages(forUserID: "\(defaults.value(forKey: kfirebaseid)!)" ,roomid: roomid2, completion: {[weak weakSelf = self] (message) in
            
            print(message)
            weakSelf?.items.append(message)
            weakSelf?.items.sort{ $0.timestamp < $1.timestamp }
            DispatchQueue.main.async
                {
                    self.stopAnimating()
                    self.inputBar .isHidden = false

                if let state = weakSelf?.items.isEmpty, state == false
                {
                    weakSelf?.tableView.reloadData()
                    weakSelf?.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        })
    }
    @IBAction func selectLocation(_ sender: Any)
    {
        self.canSendLocation = true
        if self.checkLocationPermission()
        {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if text.count > 0
            {
                self.composeMessage(type: .text, content: self.inputTextField.text!)
                self.inputTextField.text = ""
            }
        }
    }
    func composeMessage(type: MessageType, content: Any)
    {
        let message = Message.init(type: type, content: content, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false, idsender: "",idreciver: "", firebaseid: firebaseid)
        print(message)
        Message.send(message: message, toID: "\(roomid2)", firebaseid: firebaseid,reciveremail: senderemail,recivername: sendername, completion: {(_) in
        })
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.items.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if tableView.isDragging
        {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch self.items[indexPath.row].owner
        {
        case .receiver:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
            cell.clearCellData()

            
//          cell.profilePic? .sd_setImage(with: URL(string: "\(defaults.value(forKey: koriginal)!)"), placeholderImage: UIImage (named: "dummy_profile"),options: .refreshCached, completed: { image, error, cacheType, imageURL in
//                if (error != nil) {
//                    cell.profilePic?.image = UIImage (named: "dummy_profile")
//                } else {
//                    cell.profilePic?.image = image
//                }
//            })
            switch self.items[indexPath.row].type
            {
            case .text:
                cell.message.text = self.items[indexPath.row].content as? String
                
                cell.timelabel.text = "\(self.getDateFromTimeStamp(timeStamp: Double(self.items[indexPath.row].timestamp)))"

                print(self.items[indexPath.row].content as! String)
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            case .location:
                cell.messageBackground.image = UIImage.init(named: "locationThumbnail")
                cell.message.isHidden = true
            }
            return cell
        case .sender:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
            cell.clearCellData()
//            cell.profilePic? .sd_setImage(with: URL(string: useravatar), placeholderImage: UIImage (named: "dummy_profile"),options: .refreshCached, completed: { image, error, cacheType, imageURL in
//                if (error != nil) {
//                    cell.profilePic?.image = UIImage (named: "dummy_profile")
//                } else {
//                    cell.profilePic?.image = image
//                }
//            })
            switch self.items[indexPath.row].type {
            case .text:
                cell.message.text = self.items[indexPath.row].content as? String
                cell.timelabel.text = "\(self.getDateFromTimeStamp(timeStamp: Double(self.items[indexPath.row].timestamp)))"
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { (state, index) in
                        if state == true
                        {
                            DispatchQueue.main.async
                                {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            case .location:
                cell.messageBackground.image = UIImage.init(named: "locationThumbnail")
                cell.message.isHidden = true
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.inputTextField.resignFirstResponder()
        switch self.items[indexPath.row].type
        {
        case .photo:
            if let photo = self.items[indexPath.row].image {
                let info = ["viewType" : ShowExtraView.preview, "pic": photo] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
                self.inputAccessoryView?.isHidden = true
            }
        case .location:
            let coordinates = (self.items[indexPath.row].content as! String).components(separatedBy: ":")
            let location = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(coordinates[0])!, longitude: CLLocationDegrees(coordinates[1])!)
            
//            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
//                UIApplication.shared.openURL(NSURL(string:
//                    "comgooglemaps://?saddr=\(appDelegate?.userLocation?.coordinate.latitude),\(appDelegate?.userLocation?.coordinate.longitude)&daddr=\(location.latitude),\(location.longitude)&directionsmode=driving")! as URL)
//                
//            } else {
//                // if GoogleMap App is not installed
//                UIApplication.shared.openURL(NSURL(string:
//                    "https://maps.google.com/?q=@\(location.latitude),\(location.longitude)")! as URL)
//            }
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func showKeyboard(notification: Notification)
    {
        if let frame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let height = frame.cgRectValue.height
            self.tableView.contentInset.bottom = height
            self.tableView.scrollIndicatorInsets.bottom = height
            if self.items.count > 0
            {
                print(items.count)
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    func checkLocationPermission() -> Bool
    {
        var state = false
        switch CLLocationManager.authorizationStatus()
        {
        case .authorizedWhenInUse:
            state = true
        case .authorizedAlways:
            state = true
        default: break
        }
        return state
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        if let lastLocation = locations.last {
            if self.canSendLocation
            {
                let coordinate = String(lastLocation.coordinate.latitude) + ":" + String(lastLocation.coordinate.longitude)
                
//                let message = Message.init(type: .location, content: coordinate, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false, idsender: "", idreciver: "")
//                Message.send(message: message, toID: "\(roomid2)", completion: {(_) in
//                })
                self.canSendLocation = false
            }
        }
    }
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
//    {
//        if let image = info[.editedImage] as? UIImage
//        {
//            self.composeMessage(type: .photo, content: image)
//        }
//        else
//        {
//            let image = info[.originalImage] as? UIImage
//            self.composeMessage(type: .photo, content: image as Any)
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//    func animateExtraButtons(toHide: Bool)  {
//        switch toHide {
//        case true:
//            self.bottomConstraint.constant = 0
//            UIView.animate(withDuration: 0.3) {
//                self.inputBar.layoutIfNeeded()
//            }
//        default:
//            self.bottomConstraint.constant = -50
//            UIView.animate(withDuration: 0.3) {
//                self.inputBar.layoutIfNeeded()
//            }
//        }
//    }
//    @IBAction func showOptions(_ sender: Any) {
//        self.animateExtraButtons(toHide: false)
//    }
//    @IBAction func showMessage(_ sender: Any)
//    {
//        self.animateExtraButtons(toHide: true)
//    }
//    @IBAction func selectGallery(_ sender: Any) {
//        self.animateExtraButtons(toHide: true)
//        let status = PHPhotoLibrary.authorizationStatus()
//        if (status == .authorized || status == .notDetermined)
//        {
//            self.imagePicker.sourceType = .savedPhotosAlbum;
//            self.present(self.imagePicker, animated: true, completion: nil)
//        }
//    }
//    @IBAction func selectCamera(_ sender: Any)
//    {
//        self.animateExtraButtons(toHide: true)
//        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
//        if (status == .authorized || status == .notDetermined) {
//            self.imagePicker.sourceType = .camera
//            self.imagePicker.allowsEditing = false
//            self.present(self.imagePicker, animated: true, completion: nil)
//        }
//    }
    func getDateFromTimeStamp(timeStamp : Double) -> String {
        
        let date = NSDate(timeIntervalSince1970: timeStamp)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "hh:mm a"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }
}


extension String
{
    var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
    func hashCode() -> Int32
    {
        var h : Int32 = 0
        for i in self.asciiArray {
            h = 31 &* h &+ Int32(i) // Be aware of overflow operators,
        }
        return h
    }
}
