//
//  AppDelegate.swift
//  Mstoo
//
//  Created by Vishal on 20/07/20.
//  Copyright © 2020 Vishal. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FacebookCore
import GoogleSignIn
import GooglePlaces
import Firebase
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    public var isReachable = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        //UserDefaults.standard.removeObject(forKey: "checkUserLogin")
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
       // FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = "630919033707-8bcb4ijpt487assvu9jau4shf49i3ui4.apps.googleusercontent.com"
        GMSPlacesClient.provideAPIKey("AIzaSyD9Z7-xkNsAmoGghPrqCwEfOXUQHsZYsAY")

        self.setupReachability()
        return true
    }
    
    fileprivate func setupReachability()
    {
        let reach = Reachability.forInternetConnection()
        self.isReachable = reach!.isReachable()
        reach?.reachableBlock = { (reachability) in
            DispatchQueue.main.async(execute: {
                self.isReachable = true
            })
        }
        reach?.unreachableBlock = { (reachability) in
            DispatchQueue.main.async(execute: {
                self.isReachable = false
            })
        }
        reach?.startNotifier()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool
    {
        return ApplicationDelegate.shared.application(
            application,
            open: url,
            sourceApplication: sourceApplication,
            annotation: annotation
        )
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    {
        return GIDSignIn.sharedInstance().handle(url)
    }
}

