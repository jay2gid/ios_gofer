//
//  SubscriptionVC.swift
//  Mstoo
//
//  Created by Vishal on 30/09/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit
import Razorpay

class subscriptionCell: UICollectionViewCell
{
    
    @IBOutlet weak var lblFeaturedAds: UILabel!
    @IBOutlet weak var lblFreeAds: UILabel!
    @IBOutlet weak var subscriptionView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var subscribeBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        subscriptionView.layer.configureGradientBackground(UIColor(red: 99.0/255.0, green: 40.0/255.0, blue: 183.0/255.0, alpha: 1.0).cgColor, UIColor(red: 240.0/255.0, green: 0.0/255.0, blue: 135.0/255.0, alpha: 1.0).withAlphaComponent(1).cgColor, view: subscriptionView)
        
    }
}

class packageModel: NSObject
{
    var name: String = ""
    var id: String = ""
    var price: String = ""
    var desc: String = ""

    override init()
    {
    }
    
    init(dict: NSDictionary)
    {
        name = dict.getStringValue(key: "title")
        id = dict.getStringValue(key: "id")
        price = dict.getStringValue(key: "price")
        desc = dict.getStringValue(key: "description")
    }
}


class SubscriptionVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, RazorpayPaymentCompletionProtocol
{
    
    @IBOutlet weak var subscriptionCollection: UICollectionView!
    @IBOutlet var pageControl: UIPageControl!

    var packageData = [packageModel]()
    var packageId: String = ""
    var razorpay: RazorpayCheckout!
    let razorpayTestKey = "rzp_test_uDY0hX684eCxe9"
    let razorpayKey = "rzp_live_DeNigP0q98nfOP"

    override func viewDidLoad()
    {
        super.viewDidLoad()
     
        razorpay = RazorpayCheckout.initWithKey(razorpayKey, andDelegate: self)
        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true)
        pageControl.numberOfPages = 3
        
        self.getPackages()
    }
    
    func onPaymentSuccess(_ payment_id: String)
    {
        let alert = UIAlertController(title: "Paid", message: "Payment Success", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func onPaymentError(_ code: Int32, description str: String)
    {
        let alert = UIAlertController(title: "Error", message: "\(code)\n\(str)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}

extension SubscriptionVC
{
    func getPackages()
    {
        let userDict = [String : Any]()
        
        ServiceHelper.request(params: userDict, method: .get, baseWebUrl:baseUrl , useToken: "no" , apiName: packageListUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = (response!["data"] as? NSArray)!
                    print(jsonResult)
                    
                    self.packageData = []
                    
                    for value in jsonResult
                    {
                        if let cuisineStr = value as? NSDictionary
                        {
                            let menu = packageModel(dict: cuisineStr)
                            self.packageData.append(menu)
                        }
                    }
                    self.subscriptionCollection.reloadData()
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
    
    func showPaymentForm(orderId:String, pName:String)
    {
        let options: [String:Any] = [
                    "amount": "100", //This is in currency subunits. 100 = 100 paise= INR 1.
                    "currency": "INR",//We support more that 92 international currencies.
                    "description": "purchase description",
                    "order_id": orderId,
                    "image": "",
                    "name": pName,
                    "prefill": [
                        "contact": "8837582556",
                        "email": "aman8366singh@gmail.com"
                    ],
                    "theme": [
                        "color": "#528FF0"
                    ]
                ]
        razorpay.open(options, displayController: self)
    }
    
    func generateOrder(name:String)
    {
        var userDict = [String : Any]()
        
        if UserDefaults.standard.value(forKey: "userId") != nil
        {
            userDict["user_id"] = (defaults.value(forKey: "userId")!)
        }
        userDict["package_id"] = self.packageId
        
        print(userDict)

        ServiceHelper.request(params: userDict, method: .post, baseWebUrl:baseUrl , useToken: "yes" , apiName: generateOrderUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = response!["data"] as? Dictionary<String, AnyObject>
                    print(jsonResult!)
                
                    //self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)

                    DispatchQueue.main.async {
                        self.showPaymentForm(orderId: (jsonResult!["order_id"] as! String), pName: name)
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
}

extension SubscriptionVC
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
         return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let count = self.packageData.count
        pageControl.numberOfPages = count
        pageControl.isHidden = !(count > 1)

        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cellID = "subscriptionCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath as IndexPath) as! subscriptionCell
        
        cell.titleLbl.text = packageData[indexPath.row].name
        cell.priceLbl.text = "Rs.\(packageData[indexPath.row].price)"
        cell.descLbl.text =  packageData[indexPath.row].desc
        let json = packageData[indexPath.row].desc.parseJSONString as! [Any]
        print("Parsed JSON: \(json[0])")
        cell.descLbl.text! = "\(json[0])"
        cell.lblFreeAds.text! = "\(json[1])"
        cell.lblFeaturedAds.text! = "\(json[2])"

        cell.subscribeBtn.addTarget(self, action: #selector(subscriptionAction), for: .touchUpInside)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
    }
  
}

extension SubscriptionVC
{
    @objc func subscriptionAction(sender: UIButton)
    {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.subscriptionCollection)
        let indexPath = self.subscriptionCollection.indexPathForItem(at: buttonPosition)
        if indexPath != nil
        {
            self.packageId = self.packageData[indexPath!.row].id
            self.generateOrder(name: self.packageData[indexPath!.row].name)
        }
    }
    
    @IBAction func backAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SubscriptionVC
{
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
        let contentOffset = subscriptionCollection.contentOffset
        
        if subscriptionCollection.contentSize.width <= subscriptionCollection.contentOffset.x + cellSize.width
        {
            subscriptionCollection.scrollRectToVisible(CGRect(x: 0, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
        }
        else
        {
            subscriptionCollection.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
        }
    }
}

extension SubscriptionVC
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
}
extension CALayer {
    public func configureGradientBackground(_ colors:CGColor..., view:UIView){
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
       gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
       gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.colors = colors
        gradient.masksToBounds = true
        //gradient.locations = [0.0, 0.25, 0.75, 1.0]
        self.insertSublayer(gradient, at: 0)
    }
}
extension String
    {
        var parseJSONString: AnyObject?
        {
            let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)

            if let jsonData = data
            {
                // Will return an object or nil if JSON decoding fails
                do
                {
                    let message = try JSONSerialization.jsonObject(with: jsonData, options:.mutableContainers)
                    if let jsonResult = message as? NSMutableArray
                    {
                        print(jsonResult)

                        return jsonResult //Will return the json array output
                    }
                    else
                    {
                        return nil
                    }
                }
                catch let error as NSError
                {
                    print("An error occurred: \(error)")
                    return nil
                }
            }
            else
            {
                // Lossless conversion of the string was not possible
                return nil
            }
        }
    }
