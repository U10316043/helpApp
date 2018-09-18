//
//  AppDelegate.swift
//  helpApp
//
//  Created by xin on 2018/8/25.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    var formatter:DateFormatter = DateFormatter()
    var currentTime:Date = Date()
    var timer:Timer!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Database
        FirebaseApp.configure()
        print("currentUser:  \(Auth.auth().currentUser?.email)")
        
//        Database.database().reference().child("User").observe(.childAdded, with: { (snap) in
//            if let data = snap.value as? [String:Any]{
//                if Auth.auth().currentUser?.email == data["usermail"] as? String {
//                    // 檢查有沒有使用者創建帳號後沒有填寫詳細身份資訊
//                    if (data["username"]! as! String) != "" {
//                        print("true")
//                        let storyboard = self.window?.rootViewController?.storyboard
//                        let vc:TabbarViewController = (storyboard?.instantiateViewController(withIdentifier: "TabbarVC")) as! TabbarViewController
//                        self.window?.rootViewController = vc
//                        self.window?.makeKeyAndVisible()
//                    } else {
//                        print("false")
//                        Auth.auth().currentUser?.delete { error in
////                            if let error = error {
////                                // An error happened.
////                            } else {
////
////                            }
////                        }
////                        // Delete the file
////                        Database.database().reference().child("User").child(snap.key).removeValue()
////
//                    }
//                }
//            }
//        })
        
        
        
        
        

        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(readTime), userInfo: nil, repeats: true)
        return true
    }
    
    
    
    @objc func readTime(){
        self.currentTime = Date()
        Database.database().reference().child("Mission").observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                let missionID = data["missionID"] as! String
                let status = data["status"] as! String
                let setTime = data["setTime"] as! String
                let waitingTime = data["waitingTime"] as! String
                self.formatter.dateFormat = "YYYY-MMM-dd HH:mm:ss"
                if status == "waiting" {  //超過設定時間10/20/30分鐘沒人幫，任務status = fail
                    var newSetTime = self.formatter.date(from: setTime)
                    let newWaitingTime:Int = Int(waitingTime)!
                    newSetTime = newSetTime! + (TimeInterval(newWaitingTime * 60))
                    let dateComponent = DateComponentsFormatter()
                    dateComponent.allowedUnits = [.minute]
                    let time:String = dateComponent.string(from: self.currentTime, to:newSetTime!)!
                    let t = time.replacingOccurrences(of: ",", with: "")
                    let newTime:Int? = Int(t)
                    if(newTime! < 0) {
                        Database.database().reference().child("Mission").child(missionID).child("status").setValue("fail")
                    }
                } else if status == "moving" { //當系統設置時間24小時超過，任務status = fail
                    var newSetTime = self.formatter.date(from: setTime)
                    let newWaitingTime:Int = 60*24 + Int(waitingTime)!
                    newSetTime = newSetTime! + (TimeInterval(newWaitingTime * 60))
                    let dateComponent = DateComponentsFormatter()
                    dateComponent.allowedUnits = [.minute]
                    let time:String = dateComponent.string(from: self.currentTime, to:newSetTime!)!
                    let t = time.replacingOccurrences(of: ",", with: "")
                    let newTime:Int? = Int(t)
                    if(newTime! < 0) {
                        Database.database().reference().child("Mission").child(missionID).child("status").setValue("fail")
                    }
                } else {
                    
                }
                
            }
        })
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

