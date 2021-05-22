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


import Foundation
import UIKit
import Firebase

class Message {
    
    //MARK: Properties
    var owner: MessageOwner
    var type: MessageType
    var content: Any
    var idreciver: String
    var idsender: String
    var timestamp: Int
    var isRead: Bool
    var image: UIImage?
    var firebaseid: String

    private var toID: String?
    private var fromID: String?
    
    //MARK: Methods
    class func downloadAllMessages(forUserID: String, roomid :Int32, completion: @escaping (Message) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid
        {
            Database.database().reference().child("message").child("\(roomid)").observeSingleEvent(of: .value, with: { (snapshot) in
                if !(snapshot.exists())
                {
                    NotificationCenter.default.post(name: Notification.Name("stoploading"), object: nil)
                }
            })
            Database.database().reference().child("message").child("\(roomid)").observe(.childAdded, with: { (snapshot) in
                if snapshot.exists()
                {
                    let data = snapshot.value as! Dictionary<String, AnyObject>
                    print(data)
                    let timestamp      = "\(data.validatedValue("timestamp", expected: "" as AnyObject))"
                    let idReceiver      = "\(data.validatedValue("idReceiver", expected: "" as AnyObject))"
                    let idSender      = "\(data.validatedValue("idSender", expected: "" as AnyObject))"
                    let text      = "\(data.validatedValue("text", expected: "" as AnyObject))"
                    let location      = "\(data.validatedValue("location", expected: "" as AnyObject))"
                    let userfirbaseid      = "\(data.validatedValue("idReciverFirebase", expected: "" as AnyObject))"
                    let isread      = "\(data.validatedValue("isRead", expected: "" as AnyObject))"
                    
                    if text == ""
                    {
                        if !(location == "")
                        {
                            if idSender == currentUserID
                            {
                                if !(isread == "")
                                {
                                    if isread == "true"
                                    {
                                        let message = Message.init(type: MessageType.location, content: location, owner: .receiver, timestamp: Int(timestamp)!, isRead: true,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                        completion(message)
                                    }
                                    else
                                    {
                                        let message = Message.init(type: MessageType.location, content: location, owner: .receiver, timestamp: Int(timestamp)!, isRead: false,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                        completion(message)
                                    }
                                }
                                else
                                {
                                    let message = Message.init(type: MessageType.location, content: location, owner: .receiver, timestamp: Int(timestamp)!, isRead: false,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                    completion(message)
                                }
                            }
                            else
                            {
                                if !(isread == "")
                                {
                                    if isread == "true"
                                    {
                                        let message = Message.init(type: MessageType.location, content: location, owner: .sender, timestamp: Int(timestamp)!, isRead: true,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                        completion(message)
                                    }
                                    else
                                    {
                                        let message = Message.init(type: MessageType.location, content: location, owner: .sender, timestamp: Int(timestamp)!, isRead: false,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                        completion(message)
                                        
                                    }
                                }
                                else
                                {
                                    let message = Message.init(type: MessageType.location, content: location, owner: .sender, timestamp: Int(timestamp)!, isRead: false,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                    completion(message)
                                    
                                }
                            }
                        }
                    }
                    else
                    {
                        if idSender == currentUserID
                        {
                            if !(isread == "")
                            {
                                if isread == "true"
                                {
                                    let message = Message.init(type: MessageType.text, content: text, owner: .receiver, timestamp: Int(timestamp)!, isRead: true,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                    completion(message)
                                }
                                else
                                {
                                    let message = Message.init(type: MessageType.text, content: text, owner: .receiver, timestamp: Int(timestamp)!, isRead: false,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                    completion(message)
                                }
                            }
                            else
                            {
                                let message = Message.init(type: MessageType.text, content: text, owner: .receiver, timestamp: Int(timestamp)!, isRead: false,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                completion(message)
                            }
                        }
                        else
                        {
                            if !(isread == "")
                            {
                                if isread == "true"
                                {
                                    let message = Message.init(type: MessageType.text, content: text, owner: .sender, timestamp: Int(timestamp)!, isRead: true,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                    completion(message)
                                }
                                else
                                {
                                    let message = Message.init(type: MessageType.text, content: text, owner: .sender, timestamp: Int(timestamp)!, isRead: false,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                    completion(message)
                                }
                            }
                            else
                            {
                                let message = Message.init(type: MessageType.text, content: text, owner: .sender, timestamp: Int(timestamp)!, isRead: false,idsender: idSender,idreciver: idReceiver,firebaseid: userfirbaseid)
                                completion(message)
                            }
                        }
                    }
                }
            })
        }
    }
    
    func downloadImage(indexpathRow: Int, completion: @escaping (Bool, Int) -> Swift.Void)  {
        if self.type == .photo {
            let imageLink = self.content as! String
            let imageURL = URL.init(string: imageLink)
            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
                if error == nil {
                    self.image = UIImage.init(data: data!)
                    completion(true, indexpathRow)
                }
            }).resume()
        }
    }
    
    class func markMessagesRead(forUserID: String)  {
        if let currentUserID = Auth.auth().currentUser?.uid
        {
            Database.database().reference().child("message").child(forUserID).observeSingleEvent(of: .value, with: { (snap) in
                if snap.exists()
                {
                    for item in snap.children
                    {
                        print(item)
                        let data = (item as! DataSnapshot).value as! Dictionary<String, AnyObject>
                        let isread      = "\(data.validatedValue("isRead", expected: "" as AnyObject))"
                        let idSender      = "\(data.validatedValue("idSender", expected: "" as AnyObject))"
                        if idSender != currentUserID
                        {
                            if !(isread == "")
                            {
                                if isread == "0"
                                {
                                    Database.database().reference().child("message").child(forUserID).child((item as! DataSnapshot).key).child("isRead").setValue(true)
                                }
                            }
                        }
                    }
                }
            })
        }
    }
   
    func downloadLastMessage(forLocation: String, completion: @escaping () -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid {
            Database.database().reference().child("conversations").child(forLocation).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    for snap in snapshot.children {
                        let receivedMessage = (snap as! DataSnapshot).value as! [String: Any]
                        self.content = receivedMessage["content"]!
                        self.timestamp = receivedMessage["timestamp"] as! Int
                        let messageType = receivedMessage["type"] as! String
                        let fromID = receivedMessage["fromID"] as! String
                        self.isRead = receivedMessage["isRead"] as! Bool
                        var type = MessageType.text
                        switch messageType {
                        case "text":
                            type = .text
                        case "photo":
                            type = .photo
                        case "location":
                            type = .location
                        default: break
                        }
                        self.type = type
                        if currentUserID == fromID {
                            self.owner = .receiver
                        } else {
                            self.owner = .sender
                        }
                        completion()
                    }
                }
            })
        }
    }

    class func send(message: Message, toID: String,firebaseid:String,reciveremail:String,recivername:String, completion: @escaping (Bool) -> Swift.Void)  {
        if let currentUserID = Auth.auth().currentUser?.uid {
            switch message.type
            {
            case .location:
                let values = ["location": message.content, "idSender": currentUserID, "idReceiver": toID, "timestamp": message.timestamp, "idReciverFirebase" : firebaseid,"isRead" : message.isRead]
                
                print(values)
                Message.uploadMessage(withValues: values, toID: toID, reciveremail:reciveremail,recivername:recivername, completion: { (status) in
                    completion(status)
                })
            case .text:
                let values = ["text": message.content, "idSender": currentUserID, "idReceiver": toID, "timestamp": message.timestamp, "idReciverFirebase" : firebaseid,"isRead" : message.isRead]
                
                
                Message.uploadMessage(withValues: values, toID: toID, reciveremail:reciveremail,recivername:recivername, completion: { (status) in
                    completion(status)
                })
            case .photo:
                break
                
            }
        }
    }
    
    class func uploadMessage(withValues: [String: Any], toID: String, reciveremail:String,recivername:String, completion: @escaping (Bool) -> Swift.Void) {
        if let currentUserID = Auth.auth().currentUser?.uid
        {
            Database.database().reference().child("message").child(toID).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists()
                {
                    Database.database().reference().child("message").child(toID).childByAutoId().setValue(withValues, withCompletionBlock: { (error, _) in
                        if error == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                }
                else
                {
                    Database.database().reference().child("message").child(toID).childByAutoId().setValue(withValues, withCompletionBlock: { (error, reference) in
                        if error == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                }
            })
            self.createChatlist(withValues: withValues, toID: toID,reciveremail:reciveremail,recivername:recivername, completion: { (status) in
                completion(status)
            })
        }
    }
    class func createChatlist(withValues: [String: Any], toID: String,reciveremail:String,recivername:String, completion: @escaping (Bool) -> Swift.Void)
    {
        if let currentUserID = Auth.auth().currentUser?.uid
        {
            let values = ["sender_email": "\(defaults.value(forKey: kuseremail) ?? "")", "sender_name": "\(defaults.value(forKey: kusername) ?? "")", "reciver_email": reciveremail, "reciver_name": recivername,"room_id" : toID]
            
            Database.database().reference().child("ChatList").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists()
                {
                    print(snapshot)
                    var value = String()
                    for item in snapshot.children
                    {
                        print(item)
                        let data = (item as! DataSnapshot).value as! Dictionary<String, AnyObject>
                        let sender_email      = "\(data.validatedValue("sender_email", expected: "" as AnyObject))"
                        let reciver_email      = "\(data.validatedValue("reciver_email", expected: "" as AnyObject))"
                        if ((sender_email == values["sender_email"]) && (reciver_email == values["reciver_email"]))
                        {
                            value = "Yes"
                            break
                        }
                        else
                        {
                            value = "No"
                        }
                    }
                    if value == "No"
                    {
                        Database.database().reference().child("ChatList").childByAutoId().setValue(values, withCompletionBlock: { (error, reference) in
                            if error == nil {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        })
                    }
                }
                else
                {
                    Database.database().reference().child("ChatList").childByAutoId().setValue(values, withCompletionBlock: { (error, reference) in
                        if error == nil {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                }
            })
        }
    }
    
    //MARK: Inits
    init(type: MessageType, content: Any, owner: MessageOwner, timestamp: Int, isRead: Bool,idsender: String,idreciver: String,firebaseid :String) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.isRead = isRead
        self.idsender = idsender
        self.idreciver = idreciver
        self.firebaseid = firebaseid

    }
}

class ChatList {
    
    
    //MARK: Properties

    var sender_email: String
    var sender_name: String
    var reciver_email: String
    var reciver_name: String
    var room_id: String

    
    init( sender_email: String, sender_name: String,reciver_email: String,reciver_name: String,room_id :String) {
        self.sender_email = sender_email
        self.sender_name = sender_name
        self.reciver_email = reciver_email
        self.reciver_name = reciver_name
        self.room_id = room_id
       
    }
    
    class func downloadchatlist(forUserID: String, completion: @escaping (ChatList) -> Swift.Void) {
        if (Auth.auth().currentUser?.uid) != nil
        {
            Database.database().reference().child("ChatList").observeSingleEvent(of: .value, with: { (snapshot) in
                if !(snapshot.exists())
                {
                    NotificationCenter.default.post(name: Notification.Name("stoploading1"), object: nil)
                }
            })
            Database.database().reference().child("ChatList").observe(.childAdded, with: { (snapshot) in
                if snapshot.exists()
                {
                    let data = snapshot.value as! Dictionary<String, AnyObject>
                    print(data)
                    let reciver_email      = "\(data.validatedValue("reciver_email", expected: "" as AnyObject))"
                    let sender_email      = "\(data.validatedValue("sender_email", expected: "" as AnyObject))"
                    let sender_name      = "\(data.validatedValue("sender_name", expected: "" as AnyObject))"
                    let reciver_name      = "\(data.validatedValue("reciver_name", expected: "" as AnyObject))"
                    let room_id      = "\(data.validatedValue("room_id", expected: "" as AnyObject))"
                    
                    if sender_email == forUserID || reciver_email == forUserID
                    {
                        let message = ChatList.init(sender_email: sender_email, sender_name: sender_name,reciver_email: reciver_email,reciver_name: reciver_name,room_id: room_id)
                        completion(message)
                    }
                    else
                    {
                        NotificationCenter.default.post(name: Notification.Name("stoploading1"), object: nil)
                    }
                }
            })
        }
    }
    
    
}
