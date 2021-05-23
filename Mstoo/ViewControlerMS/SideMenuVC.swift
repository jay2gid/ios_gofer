//
//  SideMenuVC.swift
//  Mstoo
//
//  Created by Vishal on 01/09/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit

class SideMenuVC: UIViewController
{
    @IBOutlet weak var sideMenuTable: UITableView!
    let arrSideMenu: [String] = ["Home", "Profile", "Change Password", "Blocked Users", "About Mstoo", "How Mstoo Works", "Contact Us","Favourites", "Subscription","Logout"]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.sideMenuTable.dataSource = self
        self.sideMenuTable.delegate = self
        self.sideMenuTable.tableFooterView = UIView()
        self.sideMenuTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.getInfoPages()
    }
}

extension SideMenuVC
{
    func getInfoPages()
    {
        let userDict = [String : Any]()
        
        ServiceHelper.request(params: userDict, method: .get, baseWebUrl:baseUrl , useToken: "no" , apiName: getInfoPagesUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = response!["data"] as? Dictionary<String, AnyObject>

                    if jsonResult!.count > 0
                    {
                        ViewController.GlobalVariable.infoPagesData["about_us"] = (jsonResult!["about"])
                        ViewController.GlobalVariable.infoPagesData["contact_us"] = (jsonResult!["contact"])
                        ViewController.GlobalVariable.infoPagesData["howItWorks"] = (jsonResult!["how-it-works"])
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

extension SideMenuVC: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return arrSideMenu.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let view:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 10))
        view.backgroundColor = .clear

        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 10.0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellReuseIdentifier = "cell"
        let cell:UITableViewCell = (tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        
        cell.textLabel?.text = arrSideMenu[indexPath.section]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
        cell.accessoryType =  UITableViewCell.AccessoryType.disclosureIndicator
        
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 10.0
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0
        {
            self.dismiss(animated: true, completion: nil)
        }
        else if indexPath.section == 1
        {
            self.performSegue(withIdentifier: "showProfile", sender: nil)
        }
        else if indexPath.section == 2
        {
            self.performSegue(withIdentifier: "showChangepwd", sender: nil)
        }
        else if indexPath.section == 3
        {
            self.performSegue(withIdentifier: "showBlocked", sender: nil)
        }
        else if indexPath.section == 4
        {
            self.performSegue(withIdentifier: "showInfoPages", sender: "aboutUs")
        }
        else if indexPath.section == 5
        {
            self.performSegue(withIdentifier: "showInfoPages", sender: "howItWorks")
        }
        else if indexPath.section == 6
        {
            self.performSegue(withIdentifier: "showInfoPages", sender: "contactUs")
        }
        else if indexPath.section == 7
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MyPostsVC") as! MyPostsVC
            nextViewController.modalPresentationStyle = .fullScreen
            nextViewController.postType = .favorite
            self.present(nextViewController, animated: true, completion: nil)
        }
        else if indexPath.section == 8
        {
            self.performSegue(withIdentifier: "showSubscription", sender: nil)
        }
        else if indexPath.section == 9
        {
            UserDefaults.standard.removeObject(forKey: "checkUserLogin")
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension SideMenuVC
{
    @IBAction func backAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SideMenuVC
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showInfoPages"
        {
            if let nextViewController = segue.destination as? InfoPagesVC
            {
                nextViewController.getInfo = sender as! String
            }
        }
    }
}
