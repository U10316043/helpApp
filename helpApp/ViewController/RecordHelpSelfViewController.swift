//
//  RecordHelpSelfViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/29.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase

class RecordHelpSelfViewController: UIViewController {
    lazy var refM = Database.database().reference().child("Mission")
    lazy var refU = Database.database().reference().child("User")
    var objectTitle = ""
    var helpMissionId = ""
    var helpUserMail = ""
    var userNeedHeart:Double = 0.0 // userNeedStar from DB
    var userHelpHeart:Double = 0.0 // userHelpStar from DB
    var userAllHeart:Double = 0.0 // (userNeedHeart + userHelpHeart)/2
    @IBOutlet weak var userComplexHeart: UIImageView!
    @IBOutlet weak var userComplexHeartLabel: UILabel!
    var heartList:[UIImage] = [UIImage(named: "allHeart0")!,UIImage(named: "allHeart1")!,UIImage(named: "allHeart2")!,UIImage(named: "allHeart3")!,UIImage(named: "allHeart4")!,UIImage(named: "allHeart5")! ]
    
    @IBOutlet weak var heartNum: UILabel!
    
    @IBOutlet weak var Itemtitle: UILabel!
    @IBOutlet weak var itemDetail: UILabel!
    
    @IBOutlet weak var helpUserName: UILabel!
    @IBOutlet weak var helpUserSchool: UILabel!
    @IBOutlet weak var hopewaitingTime: UILabel!
    @IBOutlet weak var hopeReturnTime: UILabel!
    @IBOutlet weak var missionStatus: UILabel!
    
    @IBOutlet weak var calltobtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        self.heartNum.isHidden = true
        super.viewWillAppear(animated)
        refM.observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if ( self.helpMissionId == (data["missionID"] as! String)) {
                    if( data["status"] as! String == "waiting") {
                        // 助人者的地方不會出現waiting
                        self.calltobtn.isHidden = true
                    } else if( data["status"] as! String == "moving"){
                        self.calltobtn.isHidden = false
                        self.missionStatus.text = "任務進行中"
                        self.calltobtn.setTitle("聯繫對方", for: .normal)
                    } else if ( data["userStar"] as! Int != -1){
                        self.heartNum.isHidden = false
                        let numn:Int = data["userStar"] as! Int
                        self.heartNum.text = "你已經給了\(numn)❤️"
                        self.calltobtn.isHidden = true
                    } else if ( data["status"] as! String == "done"){
                        self.calltobtn.isHidden = false
                        self.missionStatus.text = "任務成功"
                        self.calltobtn.setTitle("評價對方", for: .normal)
                    } else if ( data["status"] as! String == "fail"){
                        // 助人者的地方不會出現fail
                       self.calltobtn.isHidden = true
                    } else if ( data["status"] as! String == "hate") {
                        self.calltobtn.isHidden = false
                        self.missionStatus.text = "任務結束"
                        self.calltobtn.setTitle("評價對方", for: .normal)
                    } else {
                        
                    }
            
                    
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = objectTitle
        self.tabBarController?.tabBar.isHidden = true
        self.calltobtn.isHidden = false
        refM.observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if ( self.helpMissionId == (data["missionID"] as! String)) {
                    self.Itemtitle.text = data["title"] as! String
                    self.itemDetail.text = data["objectDetail"] as! String
                    self.hopewaitingTime.text = "\(data["waitingTime"] as! String)分鐘(謝謝借我)"
                    self.hopeReturnTime.text = data["returnTime"] as! String
                    self.missionStatus.text = data["status"] as! String
                    self.helpUserMail = data["missionUser"] as! String
                }
            }
        })
        refU.observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if self.helpUserMail == data["usermail"] as! String {
                    self.helpUserName.text = data["username"] as! String
                    self.helpUserSchool.text = data["userschool"] as! String
                    
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

    @IBAction func btnaction(_ sender: Any) {
        refM.observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if ( self.helpMissionId == (data["missionID"] as! String)) {
                    if( data["status"] as! String == "moving"){
                        //跳提示框給電話
                        self.refU.observe(.childAdded, with: { (snap) in
                            if let userData = snap.value as? [String:Any]{
                                if(data["missionUser"]as! String == userData["usermail"]as! String){
                                    let number:String = userData["userphone"] as! String
                                    let url: NSURL = URL(string: "TEL://\(number)")! as NSURL
                                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                                }
                            }
                        })
                    } else if ( data["status"] as! String == "done")||( data["status"] as! String == "hate") {
                        //跳到評價頁
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecordHelpStarVC") as! RecordHelpStarViewController
                        vc.mID = self.helpMissionId
                        vc.uID = self.helpUserMail
                        self.present(vc, animated: true, completion: nil)
                    } else {
                        
                    }
                }
            }
        })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
