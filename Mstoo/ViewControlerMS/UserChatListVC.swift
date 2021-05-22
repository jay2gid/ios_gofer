//
//  UserChatListVC.swift
//  Sporddy
//
//  Created by MAC on 28/08/18.
//  Copyright © 2018 MAC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class UserChatListVC: UIViewController,UITableViewDataSource,UITableViewDelegate,NVActivityIndicatorViewable
{
    
    var sendcoustomerdid = String()
    var sendcategoryid = String()
    @IBOutlet weak var chattable: UITableView!
    @IBOutlet weak var morebtn: UIButton!

    @IBOutlet weak var all: UIButton!
    @IBOutlet weak var sporddy: UIButton!
    @IBOutlet weak var trainer: UIButton!
    
    var senderid = String()
    var useravatar = String()
    var roomid2 = Int32()
    var sendername = String()
    var sportname = String()
    
    var mongoid = String()
    var usertype = String()
    
    var checklistfordata = String()
    var userlist = [ChatList]()
    
    var userdata : UserFirebase?

    override func viewDidLoad()
    {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.booking(notification:)), name: Notification.Name("stoploading1"), object: nil)
        // Do any additional setup after loading the view.
    }
    @objc func booking(notification: NSNotification) {
        self.stopAnimating()
    }

    override func viewDidAppear(_ animated: Bool)
    {
        super .viewDidAppear(animated)
        self.getchatlist()
    }
    func getchatlist()
    {
        userlist = [ChatList]()
        startAnimating(CGSize(width: 50,height: 50), type: NVActivityIndicatorType.lineScalePulseOut)
        ChatList.downloadchatlist(forUserID: "\(defaults.value(forKey: kuseremail) ?? "")", completion: {[weak weakSelf = self] (message) in
            
            print(message)
            weakSelf?.userlist.append(message)
            DispatchQueue.main.async
                {
                    self.stopAnimating()

                if let state = weakSelf?.userlist.isEmpty, state == false
                {
                    weakSelf?.chattable.reloadData()
                    self.stopAnimating()
                }
            }
        })
    }
    @IBAction func backbtn(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if userlist.count > 0
        {
            return userlist.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL")
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "CELL")
        }
        cell?.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let profileimage = cell?.viewWithTag(2) as? UIImageView
        let namelabel = cell?.viewWithTag(3) as? UILabel
        let messagelabel = cell?.viewWithTag(4) as? UILabel
        let timelabel = cell?.viewWithTag(5) as? UILabel
        let profileBtn = cell?.viewWithTag(6) as? UIButton
        profileimage?.layer.cornerRadius = (profileimage?.frame.size.width)! / 2
        profileimage?.layer.masksToBounds = true
        namelabel?.text = userlist[indexPath.row].sender_name
        Database.database().reference().child("message/" + "\(userlist[indexPath.row].room_id)").queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            for snap in snapshot.children.allObjects as! [DataSnapshot]
            {
                let data = snap.value as! Dictionary<String, AnyObject>
                print(data)
                let text      = "\(data.validatedValue("text", expected: "" as AnyObject))"
                messagelabel?.text = text
                let timestamp      = "\(data.validatedValue("timestamp", expected: "" as AnyObject))"
                timelabel?.text = "\(self.getDateFromTimeStamp(timeStamp: Double(timestamp) ?? 0))"
            }
        })
        { (error) in
            print(error.localizedDescription)
        }

//        profileimage? .sd_setImage(with: URL(string: userlist[indexPath.row].avatar), placeholderImage: #imageLiteral(resourceName: "no_image"),options: .refreshCached, completed: { image, error, cacheType, imageURL in
//            if (error != nil) {
//                profileimage?.image = #imageLiteral(resourceName: "no_image")
//            } else {
//                profileimage?.image = image
//            }
//        })


       
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        nextViewController.senderuserid = userlist[indexPath.row].room_id
        nextViewController.senderemail = userlist[indexPath.row].reciver_email
        nextViewController.sendername = userlist[indexPath.row].reciver_name
        nextViewController.fromchatview = "Yes"
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "chattingsegue"
        {
            sendcoustomerdid = ""
            let secondViewController = segue.destination as! ChatVC
            secondViewController.senderuserid = senderid
           // secondViewController.avatar = useravatar
            secondViewController.sendername = sendername

        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableView.automaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getDateFromTimeStamp(timeStamp : Double) -> String {
        
        let date = NSDate(timeIntervalSince1970: timeStamp)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "hh:mm a"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
