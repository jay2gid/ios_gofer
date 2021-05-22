//
//  ServiceHelper.swift
//  FansKick
//
//  Created by FansKick-Nitin on 13/10/2017.
//  Copyright © 2017 FansKick Dev. All rights reserved.
//

import UIKit
import MobileCoreServices

let basicAuthUserName = "admin"
let basicAuthPassword = "12345"

let keyMultiPartData            = "data"
let keyMultiPartFileType        = "fileType"
let keyMultiPartKeyAtServerSide = "keyAtServerSide"
let keyMultiPartFilePath        = "filePath"
let multiPartFileTypeVideo      = "video"
let multiPartFileTypeAudio      = "audio"
let multiPartFileTypeImage      = "image"

let NO_INTERNET_CONNECTION = "The Internet connection appears to be offline. Please check your Internet connection."

let timeoutInterval:Double = 70

struct PAGE {
    var startIndex: Int = 1
    var pageSize: Int = 10
    var totalPage: Int = 1
}

enum loadingIndicatorType: CGFloat {
    
    case iLoader  = 0 // interactive loader => showing indicator + user interaction on UI will be enable
    case withoutLoader  = 2 // Actually no loader will be loaded => hiding indicator + user interaction on UI will be disable
}

struct ApiEndPoint {
    
}

enum MethodType: CGFloat {
    case get     = 0
    case post    = 1
    case put     = 2
    case delete  = 3
    case patch   = 4
}

//var hud_type: loadingIndicatorType = .iLoader
//var method_type: MethodType = .GET

class ServiceHelper: NSObject {
    
    //MARK:- Public Functions >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    
    class func request(params: [String: Any],
                       method: MethodType,
                       baseWebUrl: String,
                       useToken:String,
                       apiName: String,
                       hudType: loadingIndicatorType,
                       completionBlock: ((AnyObject?, Error?, Int)->())?) {
        let url = requestURL(method,baseUrl:baseWebUrl, apiName: apiName, parameterDict: params)
        var request = URLRequest(url: url)
        request.httpMethod = methodName(method)
        request.timeoutInterval = timeoutInterval
        let jsonData = body(method, parameterDict: params)
        request.httpBody = jsonData
        
        if method == .post  || method == .put || method == .patch || method == .get || method == .delete
        {
            let seconds = TimeZone.current.secondsFromGMT()
            let hours = seconds/3600
            let minutes = abs(seconds/60) % 60
            let totalUTCMinutes = String(((hours * 60) + minutes))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("en", forHTTPHeaderField: "content-language")
            request.setValue(totalUTCMinutes, forHTTPHeaderField: "utcoffset")
            
            if useToken == "yes"
            {
                if UserDefaults.standard.value(forKey: "accessToken") != nil
                {
                    request.setValue("Bearer \(defaults.value(forKey: "accessToken")!)" , forHTTPHeaderField: "Authorization")
                }
            }
        }

        
        print("request start time with api name:>>>>> ",apiName," ",Date())
        request.perform(hudType: hudType){ (responseObject: AnyObject?, error: Error?, httpResponse: HTTPURLResponse?) in
            guard let block = completionBlock else {
                return
            }
            DispatchQueue.main.async
                {
                    print(responseObject as Any)

                    guard let httpResponse = httpResponse else
                    {
                        block(responseObject, error, 9999)
                        return
                    }
                    if httpResponse.statusCode  == 200
                    {
                        if responseObject != nil
                        {
                            if let responseCode =  responseObject![kResponseCode]
                            {
                                if responseCode != nil
                                {
                                    if responseCode as! Int == 501
                                    {
                                        if let data = responseObject![kResponseMsg]
                                        {
                                            print(data as! String)
                                        }
                                    }
                                    else
                                    {
                                        block(responseObject, error, responseCode as! Int)
                                    }
                                }
                                else
                                {
                                    block(responseObject, error, httpResponse.statusCode)
                                }
                            }
                            else
                            {
                                block(responseObject, error, httpResponse.statusCode)
                            }
                        }
                        else
                        {
                            block(responseObject, error, httpResponse.statusCode)
                        }
                    }
                    else
                    {
                        block(responseObject, error, httpResponse.statusCode)
                    }
            }
        }
    }
    class private func mimeTypeForPath(for path: String) -> String {
        
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream";
    }
    class fileprivate func methodName(_ method: MethodType)-> String {
        
        switch method {
        case .get: return "GET"
        case .post: return "POST"
        case .delete: return "DELETE"
        case .put: return "PUT"
        case .patch: return "PATCH"
            
        }
    }
    
    class fileprivate func body(_ method: MethodType, parameterDict: [String: Any]) -> Data {
        
        switch method
        {
        case .post: fallthrough
        case .patch: fallthrough
        case .delete: fallthrough
        case .put: return parameterDict.toData()
        case .get: fallthrough
        default: return Data()
        }
    }
    
    class fileprivate func requestURL(_ method: MethodType, baseUrl: String, apiName: String, parameterDict: [String: Any]) -> URL
    {
        let urlString = baseUrl + apiName
        switch method
        {
        case .get:
            return getURL(apiName, baseUrl: baseUrl, parameterDict: parameterDict)
            
        case .post: fallthrough
        case .put: fallthrough
        case .patch: fallthrough
        case .delete: fallthrough
        default: return URL(string: urlString)!
        }
    }
    
    class fileprivate func getURL(_ apiName: String, baseUrl: String, parameterDict: [String: Any]) -> URL {
        
        var urlString = baseUrl + apiName
        
        var isFirst = true
        
        for key in parameterDict.keys {
            
            let object = parameterDict[key]
            
            if object is NSArray {
                
                let array = object as! NSArray
                for eachObject in array {
                    var appendedStr = "&"
                    if (isFirst == true) {
                        appendedStr = "?"
                    }
                    urlString += appendedStr + (key) + "=" + (eachObject as! String)
                    isFirst = false
                }
            } else
            {
                var appendedStr = "&"
                if (isFirst == true) {
                    appendedStr = "?"
                }
                let parameterStr = parameterDict[key] as! String
                urlString += appendedStr + (key) + "=" + parameterStr
            }
            isFirst = false
        }
        
        let strUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return URL(string:strUrl!)!
    }
    
    class func hideAllHuds(_ status: Bool, type: loadingIndicatorType)
    {
        if (type == .withoutLoader)
        {
            return
        }
        DispatchQueue.main.async(execute:
            {
                var hud = MBProgressHUD(for: APPDELEGATE.window!)
                if hud == nil
                {
                    hud = MBProgressHUD.showAdded(to: APPDELEGATE.window!, animated: true)
                }
                hud?.bezelView.layer.cornerRadius = 8.0
                hud?.bezelView.color = UIColor(red: 222/225.0, green: 222/225.0, blue: 222/225.0, alpha: 222/225.0)
                hud?.margin = 12
                
                if (status == false)
                {
                    if (type  == .withoutLoader)
                    {
                    }
                    else
                    {
                        hud?.show(animated: true)
                    }
                }
                else
                {
                    hud?.hide(animated: true, afterDelay: 0.3)
                }
        })
    }
}

extension URLRequest  {
    
    mutating func addBasicAuth() {
        let authStr = basicAuthUserName + ":" + basicAuthPassword
        let authData = authStr.data(using: .ascii)
        let authValue = "Basic " + (authData?.base64EncodedString(options: .lineLength64Characters))!
        self.setValue(authValue, forHTTPHeaderField: "Authorization")
    }
    
    func perform(hudType: loadingIndicatorType,completionBlock: @escaping (AnyObject?, Error?, HTTPURLResponse?) -> Void) -> Void
    {
        if (APPDELEGATE.isReachable == false)
        {
            AlertController.alert(title: "Connection Error!", message: NO_INTERNET_CONNECTION)
            let err  =  NSError.init(domain: "com.fanskick", code: 100, userInfo: nil) as Error
            completionBlock(nil, err, nil)
            return
        }
        //        ServiceHelper.hideAllHuds(false, type: hudType)
        HelperFitler.shared.showLoading()
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: self, completionHandler:
        {
            (data, response, error) in
//            ServiceHelper.hideAllHuds(true, type: hudType)
            HelperFitler.shared.hideLoading()
            if let error = error
            {
                completionBlock(nil, error, nil)
            }
            else
            {
                let httpResponse = response as! HTTPURLResponse
                let responseCode = httpResponse.statusCode
                do {
                    let result = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    completionBlock(result as AnyObject?, nil, httpResponse)
                }
                catch
                {
                    if responseCode == 200
                    {
                        let result = ["responseCode":"200"]
                        completionBlock(result as AnyObject?, nil, httpResponse)
                    }
                    else
                    {
                        AlertController.alert(title: "", message: "Something went wrong. Please try after some time.")
                        completionBlock(nil, error, httpResponse)
                    }
                }
            }
        })
        task.resume()
    }
}

extension NSDictionary {
    func toData() -> Data {
        return try! JSONSerialization.data(withJSONObject: self, options: [])
    }
    
    func toJsonString() -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        return jsonString
    }
}

extension Dictionary {
    
    func toData() -> Data {
        return try! JSONSerialization.data(withJSONObject: self, options: [])
    }
    
    func toJsonString() -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        return jsonString
    }
    
    func formData() -> Data{
        var isFirst = true
        var urlString = ""
        for key in self.keys {
            let object = self[key]
            
            var appendedStr = "&"
            if (isFirst == true) {
                appendedStr = ""
            }
            let parameterStr = object as! String
            urlString += appendedStr + "\(key)" + "=" + parameterStr
            isFirst = false
        }
        
        print(urlString)
        let data =  urlString.data(using: .utf8)
        return data!
    }
}


extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
    private static let mimeTypeSignatures: [UInt8 : String] = [
        0xFF : "image/jpeg",
        0x89 : "image/png",
        0x47 : "image/gif",
        0x49 : "image/tiff",
        0x4D : "image/tiff",
        0x25 : "application/pdf",
        0xD0 : "application/vnd",
        0x46 : "text/plain",
        ]
    var mimeType: String {
        var c: UInt8 = 0
        copyBytes(to: &c, count: 1)
        return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
    }
}




