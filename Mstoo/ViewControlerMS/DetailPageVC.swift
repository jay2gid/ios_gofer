//
//  DetailPageVC.swift
//  Mstoo
//
//  Created by Minkle Garg on 08/12/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit
import Lightbox
class DetailPageVC: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    struct GlobalVariable
    {
        static var infoPagesData = [String : Any]()
    }
    
    @IBOutlet weak var bannerCollection: UICollectionView!
    @IBOutlet weak var allPostCollection: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet weak var posTitle: UILabel!
    @IBOutlet weak var posTsub1: UILabel!
    @IBOutlet weak var posTsub2: UILabel!
    @IBOutlet weak var posTsub3: UILabel!
    @IBOutlet weak var posTsub4: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var postCategory: UILabel!
    @IBOutlet weak var postCondition: UILabel!
    @IBOutlet weak var postSecurityAmount: UILabel!
    @IBOutlet weak var posTransferMoney: UIButton!
    @IBOutlet weak var chatbtn: UIButton!
    
    @IBOutlet weak var postedBy: UILabel!
    @IBOutlet weak var postedBytime: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var postedView: UIView!
    @IBOutlet weak var subscriptionView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    var postsArr = [PostsModel]()
    
    var bannerArr = [BannerModel]()
    var singlePostData = [PostsModel]()
    var postImages = NSArray()
    var rowno = -1
    var postDetail = PostsModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //        categoryView.dropShadow(color: .lightGray, opacity: 1.0, offSet: CGSize(width: 8, height: 1), radius: 10, scale: true)
        //        postedView.dropShadow(color: .lightGray, opacity: 1.0, offSet: CGSize(width: 8, height: 1), radius: 10, scale: true)
        //        self.bordershadow(smallview: categoryView)
        //        self.bordershadow(smallview: postedView)
        self.posTransferMoney.layer.cornerRadius = 22.0
        self.posTransferMoney.layer.masksToBounds = true
        subscriptionView.layer.cornerRadius = 26.0
        subscriptionView.layer.masksToBounds = true
        
        // _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true)
        postDetail = singlePostData[rowno]
        allPostCollection.showsHorizontalScrollIndicator = false
        self.SimilarPosts()
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let post = singlePostData[rowno]
        let replacedString = post.userImg
        let url = URL(string: replacedString)
        self.categoryImage.sd_setImage(with: url, placeholderImage: nil)
        
        self.posTitle.text = postDetail.title
        
        if post.fixPrice != "" {
            self.posTsub1.text = postDetail.fixPrice + " " + "Rs" + "\n" + "fixed"
        }else{
            self.posTsub1.text = "-" + "\n" + "fixed"
        }
        
        if post.perDay != "" {
            self.posTsub2.text = post.perDay + " " + "Rs" + "\n" + "per day"
        }else{
            self.posTsub2.text =  "-" + "\n" + "per day"
        }
        
        if post.perWeek != "" {
            self.posTsub3.text = post.perWeek + " " + "Rs" + "\n" + "per week"
        }else{
            self.posTsub3.text = "-" + "\n" + "per week"
        }
        
        if post.perMonth != "" {
            self.posTsub4.text = post.perMonth + " " + "Rs" + "\n" + "per month"
        }else{
            self.posTsub4.text = "-" + "\n" + "per month"
        }
        
        
        self.postCategory.text = postDetail.cateName
        self.postCondition.text = postDetail.desc
        self.postSecurityAmount.text = "Security amount:" + postDetail.securityAmt + " " + "Rs"
        self.postedBy.text = postDetail.userName
        self.posTransferMoney.titleLabel?.text = "Transfer money to " + postDetail.title
        print("title..",postDetail.title)
        self.postImages = postDetail.postImages
        print("postimages",self.postImages)
        
        if self.postImages.count > 0 {
            self.bannerCollection.reloadData()
            self.allPostCollection.reloadData()
        }else{
            pageControl.isHidden = true
        }
        
        if postDetail.email == "\(defaults.value(forKey: kuseremail) ?? "")" {
            self.chatbtn.isHidden = true
        }
        
        
        self.chatbtn.isHidden = false
    }
    
    func SimilarPosts()
    {
        var userDict = [String : Any]()
        //        userDict["user_id"] = (defaults.value(forKey: "userId")!)
        userDict["category_id"] = postDetail.cateId
        
        ServiceHelper.request(params: userDict, method: .post, baseWebUrl:baseUrl , useToken: "no" , apiName: similarPostsUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = response!["data"] as? Dictionary<String, AnyObject>
                    print("similarposts",jsonResult!)
                    
                    // let postData = jsonResult!["post"] as? Dictionary<String, AnyObject>
                    
                    let postsData = jsonResult!["posts"] as? NSArray
                    print(postsData as Any)
                    
                    self.postsArr = []
                    
                    for value in postsData!
                    {
                        if let cuisineStr = value as? NSDictionary
                        {
                            let menu = PostsModel(dict: cuisineStr)
                            self.postsArr.append(menu)
                        }
                    }
                    
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
    @IBAction func back(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chatAction(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        nextViewController.senderuserid = postDetail.firebase_id
        nextViewController.senderemail = postDetail.email
        nextViewController.sendername = postDetail.userName
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated: true)
    }
    
    @IBAction func tapCall(_ sender: Any) {
        HelperApp.makeCall(number: postDetail.mobile)
    }
}

extension DetailPageVC
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == self.bannerCollection
        {
            if self.postImages.count > 0 {
                let count = self.postImages.count
                pageControl.numberOfPages = count
                pageControl.isHidden = !(count > 1)
                
                return count
            } else{
                return 0
            }
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
            //  let width = UIScreen.main.bounds.size.width
            return CGSize(width: 150, height: 150.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == self.bannerCollection {
            let cellID = "homeViewPostCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath as IndexPath) as! homeViewPostCell
            
            let replacedString = self.postImages[indexPath.row]
            let url = URL(string: replacedString as! String)
            cell.dealImage.sd_setImage(with: url, placeholderImage: UIImage(named: "logo2"))
            
            cell.backgroundColor = UIColor.clear
            // cell.contentView.layer.cornerRadius = 10.0
            
            return cell
        }else {
            
            let cellID = "homeViewPostCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath as IndexPath) as! homeViewPostCell
            
            cell.postDetail = self.postsArr[indexPath.row]
            cell.setValues()
            
            cell.backgroundColor = UIColor.clear
            cell.contentView.layer.cornerRadius = 10.0
            cell.dealImage.layer.cornerRadius = 10.0
            
            //  cell.contentView.layer.masksToBounds = true
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.bannerCollection {
            //
            
            
            var images = [LightboxImage]()
            
            for item in postImages {
                let str = (item as! String).replacingOccurrences(of: " ", with: "%20")
                if let url = URL(string:str) {
                    images.append(LightboxImage(imageURL: url))
                }
            }
            
            
            // Create an instance of LightboxController.
            let controller = LightboxController(images: images)
            
            // Set delegates.
            //            controller.pageDelegate = self
            //            controller.dismissalDelegate = self
            
            // Use dynamic background.
            controller.dynamicBackground = true
            
            // Present your controller.
            present(controller, animated: true, completion: nil)
            
            
        }
    }
}
extension DetailPageVC
{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    //    @objc func scrollToNextCell()
    //    {
    //        let cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
    //        let contentOffset = bannerCollection.contentOffset
    //
    //        if bannerCollection.contentSize.width <= bannerCollection.contentOffset.x + cellSize.width
    //        {
    //            bannerCollection.scrollRectToVisible(CGRect(x: 0, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
    //        }
    //        else
    //        {
    //            bannerCollection.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
    //        }
    //    }
}
extension UIView {
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func roundedLeftTopBottom(){
        self.clipsToBounds = true
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .bottomLeft],
                                     cornerRadii: CGSize(width:self.frame.size.height / 2, height:self.frame.size.height / 2))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
}
