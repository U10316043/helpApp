//
//  AnnotationInfoViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/27.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class AnnotationInfoViewController: UIViewController {
    var missionID:String?
    lazy var ref = Database.database().reference().child("Mission").child(missionID!)
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var needHelpName: UILabel!
    @IBOutlet weak var returnTime: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var itemDetail: UILabel!
    @IBOutlet weak var userPicture: UIImageView!
    
    var userNeedHeart:Double = 0.0 // userNeedStar from DB
    var userHelpHeart:Double = 0.0 // userHelpStar from DB
    var userAllHeart:Double = 0.0 // (userNeedHeart + userHelpHeart)/2
    @IBOutlet weak var userComplexHeart: UIImageView!
    @IBOutlet weak var userComplexHeartLabel: UILabel!
    var heartList:[UIImage] = [UIImage(named: "allHeart0")!,UIImage(named: "allHeart1")!,UIImage(named: "allHeart2")!,UIImage(named: "allHeart3")!,UIImage(named: "allHeart4")!,UIImage(named: "allHeart5")! ]
    
    var formatter:DateFormatter = DateFormatter()
    var currentTime:Date = Date()
    var needHelpEmail:String = ""
    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        Database.database().reference().child("Mission").observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if (self.missionID == (data["missionID"] as! String)) {
                    //這邊開始倒數計時
                    let setTime = data["setTime"] as! String
                    let waitingTime = data["waitingTime"] as! String
                    self.formatter.dateFormat = "YYYY-MMM-dd HH:mm:ss"
                    var newSetTime = self.formatter.date(from: setTime)
                    let newWaitingTime:Int = Int(waitingTime)!
                    newSetTime = newSetTime! + (TimeInterval(newWaitingTime * 60))
                    let dateComponent = DateComponentsFormatter()
                    dateComponent.allowedUnits = [.minute]
                    let time:String = dateComponent.string(from: self.currentTime, to:newSetTime!)!
                    self.type.text = data["title"] as! String
                    self.needHelpEmail  = data["missionUser"] as! String
                    self.returnTime.text = data["returnTime"] as! String
                    self.itemDetail.text = data["objectDetail"] as! String
                    if Auth.auth().currentUser?.email == data["missionUser"] as! String {
                        self.button.isHidden = true
                        if(data["status"]as! String == "waiting" ) {
                            self.status.text = "等待好心人"
                            self.time.text = " 還有\(time) 分鐘"
                        } else if (data["status"] as! String == "moving") {
                            self.status.text = "任務進行中"
                            self.time.text = "\(waitingTime)分內已找到"
                            self.button.isHidden = false
                            self.button.setTitle("聯繫對方", for: .normal)
                        } else {}
                    }else if(data["status"]as! String == "waiting" ){
                        self.button.isHidden = false
                        self.button.setTitle("我要幫忙", for: .normal)
                        self.status.text = "等待好心人"
                        self.time.text = " 還有\(time) 分鐘"
                    }else if (data["status"] as! String == "moving"){
                        self.button.isHidden = false
                        self.button.setTitle("聯繫對方", for: .normal)
                        self.status.text = "任務進行中"
                        self.time.text = "\(waitingTime)分內已找到"
                    } else {
                        self.status.text = "wrong"
                    }
                }
            }
        })
        Database.database().reference().child("User").observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if self.needHelpEmail == data["usermail"]as! String{
                    if self.needHelpEmail == Auth.auth().currentUser?.email {
                        self.needHelpName.text = "我自己"
                    } else {
                        self.needHelpName.text = data["username"] as! String
                    }
                    if let imageUrlString = data["userPicture"] as? String {
                        print("***** imageUrlString: ", imageUrlString)
                        if let imageUrl = URL(string: imageUrlString) {
                            URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, response, error) in
                                if error != nil {
                                    print("Download Image Task Fail: \(error!.localizedDescription)")
                                } else if let imageData = data {
                                    DispatchQueue.main.async {
                                        self.userPicture.image = UIImage(data: imageData)
                                        print("place a photo")
                                    }
                                }
                            }).resume()
                        }
                    }
                    self.userNeedHeart = data["userNeedStar"] as! Double
                    self.userHelpHeart = data["userHelpStar"] as! Double
                    self.userComplexHeart.isHidden = false
                    self.userComplexHeartLabel.isHidden = false
                    if self.userNeedHeart == -1 &&  self.userHelpHeart == -1{
                        self.userComplexHeart.isHidden = true
                        self.userComplexHeartLabel.isHidden = true
                    } else if self.userNeedHeart != -1 &&  self.userHelpHeart == -1 {
                        let newNum:Int = Int(round(self.userNeedHeart))
                        self.userComplexHeartLabel.text = "\(self.userNeedHeart)"
                        self.userComplexHeart.image = self.heartList[newNum]
                    } else if self.userNeedHeart == -1 &&  self.userHelpHeart != -1 {
                        let newNum:Int = Int(round(self.userHelpHeart))
                        self.userComplexHeartLabel.text = "\(self.userHelpHeart)"
                        self.userComplexHeart.image = self.heartList[newNum]
                    } else {
                        var num:Double = (self.userNeedHeart + self.userHelpHeart)/2
                        self.userComplexHeartLabel.text = "\((round(num*100))/100)"
                        let newNum:Int = Int(round(num))
                        self.userComplexHeart.image = self.heartList[newNum]
                    }
                }
            }
        })
    }
    
    
    
    @IBAction func helpAction(_ sender: Any) {
        let vc = UIApplication.shared.delegate as! AppDelegate
        let currentPosition = vc.locationManager.location?.coordinate
        if currentPosition == nil {
            let alertNoLocation = UIAlertController(title: "提示", message: "請先開啟定位服務！", preferredStyle: .alert)
            // 建立[確認]按鈕
            let okSeeAction = UIAlertAction(title: "確認",style: .cancel, handler: nil)
            alertNoLocation.addAction(okSeeAction)
            // 顯示提示框
            self.present(alertNoLocation,animated: true,completion: nil)
        } else {
            Database.database().reference().child("Mission").observe(.childAdded, with: { (snap) in
                if let data = snap.value as? [String:Any]{
                    if (self.missionID == (data["missionID"] as! String)) {
                        if data["status"] as! String == "waiting" {
                            let alertController = UIAlertController(title: "即將出借個人物品", message: "感謝您的好心幫忙，請盡量在時間內把物品借給對方唷！", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "確認", style: .default) { (defaultAction) -> Void in
                                self.ref.child("status").setValue("moving")
                                self.ref.child("helper").setValue(Auth.auth().currentUser?.email)
                                self.ref.child("helperLatitude").setValue(currentPosition?.latitude)
                                self.ref.child("helperLongitude").setValue(currentPosition?.longitude)
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabbarVC")
                                self.present(vc!, animated: true, completion: nil)
                            }
                            let cancelAction = UIAlertAction(title: "取消", style: .cancel,handler:nil)
                            alertController.addAction(cancelAction)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else if data["status"] as! String == "moving" {
                            let number:String = ""
                            Database.database().reference().child("User").observe(.childAdded, with: { (snap) in
                                if let userData = snap.value as? [String:Any]{
                                    if Auth.auth().currentUser?.email == data["helper"] as! String {
                                        if(data["missionUser"]as! String == userData["usermail"]as! String){
                                            let number = userData["userphone"] as! String
                                            let url: NSURL = URL(string: "TEL://\(number)")! as NSURL
                                            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                                        }
                                    } else if Auth.auth().currentUser?.email == data["missionUser"] as! String {
                                        if(data["helper"]as! String == userData["usermail"]as! String){
                                            let number:String = userData["userphone"] as! String
                                            let url: NSURL = URL(string: "TEL://\(number)")! as NSURL
                                            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                                        }
                                    } else {
                                        print("Error: 當前使用者不是helper也不是missionUser卻看得到status為moving的Annotaional info")
                                    }
                                }
                            })
                        }
                    }
                }
            })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
