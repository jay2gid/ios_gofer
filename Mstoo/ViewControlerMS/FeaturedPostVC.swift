//
//  FeaturedPostVC.swift
//  Mstoo
//
//  Created by Nishan on 23/05/21.
//  Copyright © 2021 Vishal. All rights reserved.
//

import UIKit

class featuredCell: UICollectionViewCell
{
    @IBOutlet weak var dealImage: UIImageView!
    @IBOutlet weak var dealTitle: UILabel!
    @IBOutlet weak var dealPrice: UILabel!
    @IBOutlet weak var dealTime: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    
}
class FeaturedPostVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var featureCollection: UICollectionView!
    var featuredArr = [PostsModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getAllPosts()
    }
    func getAllPosts(){
     // let latStr: String = String(format: "%.4f", latitude!)
      //  let lonStr: String = String(format: "%.4f", longitude!)

        var userDict = [String : Any]()
//        userDict["latitude"] = latStr
//        userDict["longitude"] = lonStr

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
                    
                    
                    let postData = jsonResult!["post"] as? Dictionary<String, AnyObject>
                    
                    let postsData = postData!["posts"] as? NSArray
                    let featuredData = postData!["featuredPosts"] as? NSArray
                    print(postsData as Any)
                    
                    self.featuredArr = []
        
                    for value in featuredData!
                    {
                        if let cuisineStr = value as? NSDictionary
                        {
                            let menu = PostsModel(dict: cuisineStr)
                            self.featuredArr.append(menu)
                        }
                    }

                    
                   self.featureCollection.reloadData()
                }
                else
                {
                    if let data = response![kResponseMsg]
                    {
                      //  self.showToast(message: data as! String)
                    }
                }
            }
        }
    }

    @IBAction func actnBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {

        return featuredArr.count

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
            let width = UIScreen.main.bounds.size.width
            return CGSize(width: ((width / 2) - 10), height: 170.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
   
            let cellID = "featuredCell"
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath as IndexPath) as! featuredCell
            let replacedString = (self.featuredArr[indexPath.row].postImage).replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: replacedString)
            cell.dealImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "place_holder"))
            cell.dealTitle.text = self.featuredArr[indexPath.row].title
            cell.dealPrice.text = "Rs " + self.featuredArr[indexPath.row].fixPrice
            cell.dealTime.text = self.featuredArr[indexPath.row].desc

            cell.backgroundColor = UIColor.white
            cell.contentView.layer.cornerRadius = 10.0
            cell.btnShare.tag = indexPath.row
            cell.btnShare.addTarget(self, action: #selector(actnShare), for: .touchUpInside)
            
//            let replacedString = (self.bannerArr[indexPath.row].image).replacingOccurrences(of: " ", with: "%20")
//            let url = URL(string: replacedString)
//            cell.dealImage.sd_setImage(with: url, placeholderImage: nil)
//
//            cell.backgroundColor = UIColor.white
//            cell.contentView.layer.cornerRadius = 10.0

            return cell
    
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailPageVC") as? DetailPageVC
        vc?.singlePostData = self.featuredArr
        vc?.rowno = indexPath.row
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
    }
    @objc func actnShare(sender: UIButton)
    {
//        var imageView = UIImage()
//        var imageView1 = UIImageView()
//        let replacedString = (self.postsArr[sender.tag].postImage).replacingOccurrences(of: " ", with: "%20")
//        if replacedString != ""{
//        let url = URL(string: replacedString)
//       imageView1.sd_setImage(with:url, placeholderImage: #imageLiteral(resourceName: "loginBottomBg"), completed: {
//        (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
//        imageView = image!
//        })
            let link = "https://apps.apple.com/in/app/mstoo-rent-lease-hire/id1536396175"
           let shareItems:Array = [link]
           let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToVimeo]
            self.present(activityViewController, animated: true, completion: nil)
    }
}
