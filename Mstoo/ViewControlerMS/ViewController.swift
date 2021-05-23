//
//  ViewController.swift
//  Mstoo
//
//  Created by Vishal on 20/07/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit
import CoreLocation

class BannerModel: NSObject
{
    var id: String = ""
    var image: String = ""
    
    override init()
    {
    }
    
    init(dict: NSDictionary)
    {
        id = dict.getStringValue(key: "id")
        image = dict.getStringValue(key: "name")
    }
}

class PostsModel: NSObject
{
    var id: String = ""
    var cateId: String = ""
    var cateImg: String = ""
    var cateName: String = ""
    var desc: String = ""
    var fixPrice: String = ""
    var perDay: String = ""
    var perMonth: String = ""
    var perWeek: String = ""
    var securityAmt: String = ""
    var subCateId: String = ""
    var subCateName: String = ""
    var title: String = ""
    var userId: String = ""
    var userImg: String = ""
    var userName: String = ""
    var youTubeUrl: String = ""
    var postImage: String = ""
    var firebase_id: String = ""
    var email: String = ""
    var postImages = NSArray()
    var mobile = ""
    var isFavourite = false
    var price = "0"
    
    override init()
    {
    }
    
    init(dict: NSDictionary)
    {
        id = dict.getStringValue(key: "id")
        cateId = dict.getStringValue(key: "categoryId")
        firebase_id = dict.getStringValue(key: "userFirebaseId")
        cateImg = dict.getStringValue(key: "categoryImage")
        cateName = dict.getStringValue(key: "categoryName")
        desc = dict.getStringValue(key: "description")
        fixPrice = dict.getStringValue(key: "fixed_price")
        perDay = dict.getStringValue(key: "per_day_price")
        perMonth = dict.getStringValue(key: "per_month_price")
        perWeek = dict.getStringValue(key: "per_week_price")
        securityAmt = dict.getStringValue(key: "security_amount")
        subCateId = dict.getStringValue(key: "subCategoryId")
        subCateName = dict.getStringValue(key: "subCategoryName")
        title = dict.getStringValue(key: "title")
        userId = dict.getStringValue(key: "userId")
        userImg = dict.getStringValue(key: "userImage")
        userName = dict.getStringValue(key: "userName")
        youTubeUrl = dict.getStringValue(key: "youtube_url")
        email = dict.getStringValue(key: "email")
        postImage = dict.getStringValue(key: "postImage")
        postImages = dict.value(forKey: "postImages") as! NSArray
        print("postImages",postImages)
        mobile = dict.getStringValue(key: "mobile")
        
        if dict.getStringValue(key: "isFavourite") == "0" {
            isFavourite = false
        }else{
            isFavourite = true
        }
        
        if fixPrice != "" {
            self.price  = fixPrice
        }else if perDay != "" {
            self.price  = perDay
        }else if perWeek != "" {
            self.price  = perWeek
        }else if perMonth != "" {
            self.price  = perMonth
        }
    }
}

class homeViewPostCell: UICollectionViewCell
{
    @IBOutlet weak var dealImage: UIImageView!
    @IBOutlet weak var dealTitle: UILabel!
    @IBOutlet weak var dealPrice: UILabel!
    @IBOutlet weak var dealTime: UILabel!
    @IBOutlet var btnHeart: UIButton!

    var postDetail = PostsModel()
    
    func setValues(){
        let replacedString = (self.postDetail.postImage).replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: replacedString)
        
        self.dealImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "place_holder"))
        self.dealTitle.text = postDetail.title
        self.dealTime.text = postDetail.desc
        self.dealPrice.text = "Rs " + postDetail.price
        
    }
    
    @IBAction func tapHeart(_ sender: Any) {
        
        HelperApp.shared.addToFavroite(postId: postDetail.id) { (success) in
            if success {
                if self.postDetail.isFavourite {
                    self.postDetail.isFavourite = false
                    self.btnHeart.imageTintColor(color: .gray)
                }else{
                    self.postDetail.isFavourite = true
                    self.btnHeart.imageTintColor(color: .red)
                }
            }
            
        }
        
    }
    
}

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UISearchBarDelegate,CLLocationManagerDelegate
{

    lazy  var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    var locationManager:CLLocationManager!
    var latitude : Double?
    var longitude : Double?
    
    struct GlobalVariable
    {
        static var infoPagesData = [String : Any]()
    }

    @IBOutlet weak var bannerCollection: UICollectionView!
    @IBOutlet weak var allPostCollection: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!

    var bannerArr = [BannerModel]()
    var postsArr = [PostsModel]()

    override func viewDidLoad()     {
        super.viewDidLoad()
        
        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true)

        searchBar.placeholder = "Search"
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshFitlerData), name: NSNotification.Name(rawValue:ConstantGlobal.Notifier.refreshPost), object: nil)
        
        getLocation()
    }
    
    @objc func refreshFitlerData() {
        self.postsArr = HelperFitler.shared.arryPosts
        self.allPostCollection.reloadData()
    }
    
    
    func checkUser(){
        if let _ = UserDefaults.standard.string(forKey: "checkUserLogin")  {
            
        } else {
            self.performSegue(withIdentifier: "showLogin", sender: nil)
        }
    }
    
    func getLocation(){
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()

            if CLLocationManager.locationServicesEnabled()
            {
                locationManager.startUpdatingLocation()
            }
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
            checkUser()
        
        if HelperApp.shared.isNewPost {
            HelperApp.shared.isNewPost = false
            getLocation()
        }
    }
    
    
    @IBAction func tapFitler(_ sender: Any) {
        let vc = VCFilter.init(nibName: "VCFilter", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension ViewController
{
    func getAllPosts(){
        let latStr: String = String(format: "%.4f", latitude!)
        let lonStr: String = String(format: "%.4f", longitude!)

        var userDict = [String : Any]()
        userDict["latitude"] = latStr
        userDict["longitude"] = lonStr

        self.showLoading()
        ServiceHelper.request(params: userDict, method: .post, baseWebUrl:baseUrl , useToken: "no" , apiName: getAllPostsUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            
            self.hideLoading()
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = response!["data"] as? Dictionary<String, AnyObject>
                    print(jsonResult!)
                    
                    let bannerData = jsonResult!["banner"] as? NSArray
                    
                    let postData = jsonResult!["post"] as? Dictionary<String, AnyObject>
                    
                    let postsData = postData!["posts"] as? NSArray
                    print(postsData as Any)
                    
                    self.bannerArr = []
                    
                    for value in bannerData!
                    {
                        if let cuisineStr = value as? NSDictionary
                        {
                            let menu = BannerModel(dict: cuisineStr)
                            self.bannerArr.append(menu)
                        }
                    }
                    
                    self.postsArr = []
                    
                    for value in postsData!
                    {
                        if let cuisineStr = value as? NSDictionary
                        {
                            let menu = PostsModel(dict: cuisineStr)
                            self.postsArr.append(menu)
                        }
                    }
                    
                    self.bannerCollection.reloadData()
                    self.allPostCollection.reloadData()
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

extension ViewController
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
         return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == self.bannerCollection
        {
            let count = self.bannerArr.count
            pageControl.numberOfPages = count
            pageControl.isHidden = !(count > 1)

            return count
        }
        else
        {
            return self.postsArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if collectionView == self.bannerCollection
        {
            return CGSize(width: collectionView.frame.width, height: 200)
        }
        else
        {
            let width = UIScreen.main.bounds.size.width
            return CGSize(width: ((width / 2) - 10), height: 170.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == self.bannerCollection
        {
            let cellID = "homeViewPostCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath as IndexPath) as! homeViewPostCell
            
            let replacedString = (self.bannerArr[indexPath.row].image).replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: replacedString)
            cell.dealImage.sd_setImage(with: url, placeholderImage: nil)
            
            cell.backgroundColor = UIColor.white
            cell.contentView.layer.cornerRadius = 10.0

            return cell
        }
        else
        {
            let cellID = "homeViewPostCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath as IndexPath) as! homeViewPostCell
            
            cell.postDetail = self.postsArr[indexPath.row]
            cell.setValues()
            

            cell.backgroundColor = UIColor.white
            cell.contentView.layer.cornerRadius = 10.0
            
            if self.postsArr[indexPath.row].isFavourite {
                cell.btnHeart.imageTintColor(color: UIColor.red)
            }else{
                cell.btnHeart.imageTintColor(color: UIColor.lightGray)
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailPageVC") as? DetailPageVC
        vc?.singlePostData = self.postsArr
        vc?.rowno = indexPath.row
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
     //   self.navigationController?.pushViewController(vc!, animated: true)
        
    }
}

extension ViewController
{
    @IBAction func sideMenuAction(_ sender: Any)
    {
        self.performSegue(withIdentifier: "showSideMenu", sender: nil)
    }
    
    @IBAction func chatAction(_ sender: Any)
    {
       
    }
    
    @IBAction func myPostsAction(_ sender: Any)
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MyPostsVC") as! MyPostsVC
        nextViewController.modalPresentationStyle = .fullScreen
        nextViewController.postType = .mypost
        self.present(nextViewController, animated: true, completion: nil)
    }
    
    @IBAction func messagesAction(_ sender: Any)
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserChatListVC") as! UserChatListVC
            nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated: true, completion: nil)
    }
}

extension ViewController
{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        self.searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}

extension ViewController
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        
        guard let location: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        latitude = location.latitude
        longitude = location.longitude
        
        self.getAllPosts()

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

                    self.searchBar.text = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
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

extension ViewController
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    @objc func scrollToNextCell()
    {
        let cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let contentOffset = bannerCollection.contentOffset
        
        if bannerCollection.contentSize.width <= bannerCollection.contentOffset.x + cellSize.width
        {
            bannerCollection.scrollRectToVisible(CGRect(x: 0, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
        }
        else
        {
            bannerCollection.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
        }
    }
}

//                           Auth.auth().signIn(withEmail: self.usernameTextField.text!, password: self.passwordTextField.text!) {(user, error) in
//                                if user != nil {
//                                    print("User Has Sign In")
//                                }
//                                if error != nil {
//                                    print(":(",error)
//                                }
//                        }

//                    Auth.auth().createUser(withEmail: self.email.text!, password: self.password.text!) {(user, error) in
//                                               if user != nil {
//                                                   print("User Has SignUp")
//                                               }
//                                               if error != nil {
//                                                   print(":(",error as Any)
//                                               }
//                                           }
