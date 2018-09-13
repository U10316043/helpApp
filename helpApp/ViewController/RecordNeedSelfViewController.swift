//  紀錄 -> 求助頁面
//  RecordNeedSelfViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/29.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase

class RecordNeedSelfViewController: UIViewController {
    lazy var refM = Database.database().reference().child("Mission")
    lazy var refU = Database.database().reference().child("User")
    var objectTitle = ""
    var needMissionId = ""
    var needUserMail = ""
    // 拿來算倒數時間
    var currentTime:Date = Date()
    var formatter:DateFormatter = DateFormatter()
    var userNeedHeart:Double = 0.0 // userNeedStar from DB
    var userHelpHeart:Double = 0.0 // userHelpStar from DB
    var userAllHeart:Double = 0.0 // (userNeedHeart + userHelpHeart)/2
    @IBOutlet weak var userComplexHeart: UIImageView!
    @IBOutlet weak var userComplexHeartLabel: UILabel!
    var heartList:[UIImage] = [UIImage(named: "allHeart0")!,UIImage(named: "allHeart1")!,UIImage(named: "allHeart2")!,UIImage(named: "allHeart3")!,UIImage(named: "allHeart4")!,UIImage(named: "allHeart5")! ]
    
    @IBOutlet weak var heartNum: UILabel!
    @IBOutlet weak var ItemTitle: UILabel!
    @IBOutlet weak var objectDetail: UILabel!
    
    @IBOutlet weak var hopeWatingTime: UILabel!
    @IBOutlet weak var hopeReturnTime: UILabel!
    @IBOutlet weak var missionStatus: UILabel!
    
    @IBOutlet weak var goodmanLabel: UILabel!
    @IBOutlet weak var goodMan: UILabel!
    @IBOutlet weak var goodManSchool: UILabel!
    @IBOutlet weak var userPicture: UIImageView!
    
    @IBOutlet weak var needButton: UIButton!
    @IBOutlet weak var reportAction: UIButton!
   

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refM.observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if ( self.needMissionId == (data["missionID"] as! String)) {
                    if( data["status"] as! String == "waiting") {
                        self.needButton.isHidden = false
                        self.reportAction.isHidden = true
                        self.missionStatus.text = "等待好心人"
                        self.needButton.setTitle("取消請求", for: .normal)
                    } else if( data["status"] as! String == "moving"){
                        self.needButton.isHidden = false
                        self.reportAction.isHidden = false
                        self.needButton.setTitle("聯繫對方", for: .normal)
                        self.missionStatus.text = "任務進行中"
                    } else if ( data["status"] as! String == "fail"){
                        self.needButton.isHidden = true
                        self.reportAction.isHidden = true
                        self.missionStatus.text = "任務失敗"
                    } else if ( data["helperStar"] as! Int != -1){
                        self.needButton.isHidden = true
                        self.reportAction.isHidden = true
                        let numn:Int = data["helperStar"] as! Int
                        self.heartNum.text = "你已經給了\(numn)❤️"
                    } else if ( data["status"] as! String == "done"){
                        self.needButton.isHidden = false
                        self.reportAction.isHidden = true
                        self.missionStatus.text = "任務成功"
                        self.needButton.setTitle("評價對方", for: .normal)
                    } else if ( data["status"] as! String == "hate") {
                        self.needButton.isHidden = false
                        self.reportAction.isHidden = true
                        self.needButton.setTitle("評價對方", for: .normal)
                        self.self.missionStatus.text = "任務結束"
                    } else {
                        
                    }
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        title = objectTitle
        self.reportAction.isHidden = false
        self.needButton.isHidden = false
        
        refM.observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if ( self.needMissionId == (data["missionID"] as! String)) {
                    self.ItemTitle.text = data["title"] as! String
                    self.objectDetail.text = data["objectDetail"] as! String
                    self.hopeReturnTime.text = data["returnTime"] as! String
                    self.needUserMail = data["helper"] as! String
                    let setTime = data["setTime"] as! String
                    let waitingTime = data["waitingTime"] as! String
                    self.formatter.dateFormat = "YYYY-MMM-dd HH:mm:ss"
                    var newSetTime = self.formatter.date(from: setTime)
                    let newWaitingTime:Int = Int(waitingTime)!
                    newSetTime = newSetTime! + (TimeInterval(newWaitingTime * 60))
                    let dateComponent = DateComponentsFormatter()
                    dateComponent.allowedUnits = [.minute]
                    let time:String = dateComponent.string(from: self.currentTime, to:newSetTime!)!
                    if (data["status"] as! String == "waiting") {
                        self.hopeWatingTime.text = " 還有\(time) 分鐘"
                    } else {
                        self.hopeWatingTime.text = "已結束（\(data["waitingTime"] as! String)）"
                    }
                }
            }
        })
        Database.database().reference().child("User").observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if self.needUserMail == data["usermail"] as! String {
                    
                    if let imageUrlString = data["userPicture"] as? String {
                        if let imageUrl = URL(string: imageUrlString) {
                            URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, response, error) in
                                if error != nil {
                                    print("Download Image Task Fail: \(error!.localizedDescription)")
                                } else if let imageData = data {
                                    DispatchQueue.main.async {
                                        self.userPicture.image = UIImage(data: imageData)
                                    }
                                }
                            }).resume()
                        }
                    }
                    
                    self.goodMan.text = data["username"] as! String
                    self.userNeedHeart = data["userNeedStar"] as! Double
                    self.userHelpHeart = data["userHelpStar"] as! Double
                    self.goodManSchool.text = data["userschool"] as! String
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
    
    
    
    @IBAction func btnAction(_ sender: Any) {
        refM.observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if ( self.needMissionId == (data["missionID"] as! String)){
                    if( data["status"] as! String == "waiting") {
                        self.refM.child(data["missionID"]as!String).child("status").setValue("fail")
                    } else if( data["status"] as! String == "moving"){
                        //聯繫對方
                        self.refU.observe(.childAdded, with: { (snap) in
                            if let userData = snap.value as? [String:Any]{
                                if(data["helper"]as! String == userData["usermail"]as! String){
                                    let number:String = userData["userphone"] as! String
                                    let url: NSURL = URL(string: "TEL://\(number)")! as NSURL
                                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                                }
                            }
                        })
                    } else if ( data["status"] as! String == "done")||( data["status"] as! String == "hate") {
                        //跳到評價頁
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecordNeedStarVC") as! RecordNeedStarViewController
                        vc.missionID = self.needMissionId
                        vc.helperID = self.needUserMail
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        })
    }
    
    //回報任務
    @IBAction func reportTurnPage(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecordReturnMissionVC") as! RecordReturnMissionViewController
        vc.missionID = needMissionId
        self.present(vc, animated: true, completion: nil)
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
