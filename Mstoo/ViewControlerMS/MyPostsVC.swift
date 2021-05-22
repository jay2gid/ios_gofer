//
//  MyPostsVC.swift
//  Mstoo
//
//  Created by Minkle Garg on 09/12/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit

class MyPostsVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var allPostCollection: UICollectionView!
    var postsArr = [PostsModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.MyPostsVC()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func back(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MyPostsVC
{
    func MyPostsVC()
    {

        var userDict = [String : Any]()
        userDict["user_id"] = (defaults.value(forKey: "userId")!)
        ServiceHelper.request(params: userDict, method: .post, baseWebUrl:baseUrl , useToken: "no" , apiName: getMyPostsUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = response!["data"] as? Dictionary<String, AnyObject>
                    let postsData = jsonResult?["posts"] as? NSArray
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
}

extension MyPostsVC
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
         return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.postsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
            let width = UIScreen.main.bounds.size.width
            return CGSize(width: ((width / 2) - 10), height: 170.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cellID = "homeViewPostCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath as IndexPath) as! homeViewPostCell
        
        let replacedString = (self.postsArr[indexPath.row].postImage).replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: replacedString)
        cell.dealImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "place_holder"))
        cell.dealTitle.text = self.postsArr[indexPath.row].title
        cell.dealPrice.text = self.postsArr[indexPath.row].fixPrice
        cell.dealTime.text = self.postsArr[indexPath.row].desc

        cell.backgroundColor = UIColor.white
        cell.contentView.layer.cornerRadius = 10.0

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailPageVC") as? DetailPageVC
        vc?.singlePostData = self.postsArr
        vc?.rowno = indexPath.row
        vc?.modalPresentationStyle = .fullScreen
        self.present(vc!, animated: true, completion: nil)
        //self.navigationController?.pushViewController(vc!, animated: true)
    }
}
