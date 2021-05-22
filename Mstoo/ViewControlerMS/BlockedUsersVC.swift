//
//  BlockedUsersVC.swift
//  Mstoo
//
//  Created by Vishal on 17/02/21.
//  Copyright © 2021 Vishal. All rights reserved.
//

import UIKit

class blockedCell: UITableViewCell
{
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
}

class BlockedUsersVC: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    @IBOutlet weak var usersTable: UITableView!
    let arrSideMenu: [String] = ["Vishal", "Manjit"]

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.getBlockedUsers()
    }
}

extension BlockedUsersVC
{
    func getBlockedUsers()
    {
        var userDict = [String : Any]()
        userDict["user_id"] = (defaults.value(forKey: "userId")!)

        ServiceHelper.request(params: userDict, method: .post, baseWebUrl:baseUrl , useToken: "no" , apiName: blockedUsersUrl , hudType: loadingIndicatorType.iLoader)
        { (response, error, responseCode) in
            if (error == nil)
            {
                if responseCode == 200
                {
                    let jsonResult = response!["data"] as? Dictionary<String, AnyObject>

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

extension BlockedUsersVC
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
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 10.0
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockedCell", for: indexPath) as! blockedCell

        cell.titleLbl?.text = arrSideMenu[indexPath.section]
        cell.titleLbl?.font = UIFont.systemFont(ofSize: 16.0)
        cell.userImg?.image = UIImage(named: "user")

        cell.accessoryType =  UITableViewCell.AccessoryType.disclosureIndicator
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension BlockedUsersVC
{
    @IBAction func backAction(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}

extension BlockedUsersVC
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
    
