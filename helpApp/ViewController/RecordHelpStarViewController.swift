//
//  RecordHelpStarViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/30.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase

class RecordHelpStarViewController: UIViewController {
    
    lazy var refM = Database.database().reference().child("Mission")
    lazy var refU = Database.database().reference().child("User")
    var mID:String = ""
    var uID:String = ""
    var giveHelperStar:Int = 0 //這次任務給了幾顆愛心(0~5)
    var needMissionCount:Int = 0  // 受助者 他之前受助過的次數（不加這次）
    var needTotalStar:Int = 0 //受助者 他之前受助過得到的總愛心數（不加這次）
    
    @IBOutlet weak var needName: UILabel!
    @IBOutlet weak var objectDetail: UILabel!
    
    @IBOutlet weak var hh1: UIButton!
    @IBOutlet weak var hh2: UIButton!
    @IBOutlet weak var hh3: UIButton!
    @IBOutlet weak var hh4: UIButton!
    @IBOutlet weak var hh5: UIButton!
    var h1bool:Bool = false
    @IBAction func ha1(_ sender: Any) {
        if(h1bool == false) {
            hh1.setImage(UIImage(named: "heart"), for: .normal)
            hh2.setImage(UIImage(named: "heart2"), for: .normal)
            hh3.setImage(UIImage(named: "heart2"), for: .normal)
            hh4.setImage(UIImage(named: "heart2"), for: .normal)
            hh5.setImage(UIImage(named: "heart2"), for: .normal)
            h1bool = true
            giveHelperStar = 1
        }else {
            hh1.setImage(UIImage(named: "heart2"), for: .normal)
            hh2.setImage(UIImage(named: "heart2"), for: .normal)
            hh3.setImage(UIImage(named: "heart2"), for: .normal)
            hh4.setImage(UIImage(named: "heart2"), for: .normal)
            hh5.setImage(UIImage(named: "heart2"), for: .normal)
            h1bool = false
            giveHelperStar = 0
        }
    }
    @IBAction func ha2(_ sender: Any) {
        hh1.setImage(UIImage(named: "heart"), for: .normal)
        hh2.setImage(UIImage(named: "heart"), for: .normal)
        hh3.setImage(UIImage(named: "heart2"), for: .normal)
        hh4.setImage(UIImage(named: "heart2"), for: .normal)
        hh5.setImage(UIImage(named: "heart2"), for: .normal)
        h1bool = false
        giveHelperStar = 2
    }
    @IBAction func ha3(_ sender: Any) {
        hh1.setImage(UIImage(named: "heart"), for: .normal)
        hh2.setImage(UIImage(named: "heart"), for: .normal)
        hh3.setImage(UIImage(named: "heart"), for: .normal)
        hh4.setImage(UIImage(named: "heart2"), for: .normal)
        hh5.setImage(UIImage(named: "heart2"), for: .normal)
        h1bool = false
        giveHelperStar = 3
    }
    @IBAction func ha4(_ sender: Any) {
        hh1.setImage(UIImage(named: "heart"), for: .normal)
        hh2.setImage(UIImage(named: "heart"), for: .normal)
        hh3.setImage(UIImage(named: "heart"), for: .normal)
        hh4.setImage(UIImage(named: "heart"), for: .normal)
        hh5.setImage(UIImage(named: "heart2"), for: .normal)
        h1bool = false
        giveHelperStar = 4
    }
    @IBAction func ha5(_ sender: Any) {
        hh1.setImage(UIImage(named: "heart"), for: .normal)
        hh2.setImage(UIImage(named: "heart"), for: .normal)
        hh3.setImage(UIImage(named: "heart"), for: .normal)
        hh4.setImage(UIImage(named: "heart"), for: .normal)
        hh5.setImage(UIImage(named: "heart"), for: .normal)
        h1bool = false
        giveHelperStar = 5
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getFinishDB(complition: @escaping () -> Void){
        refM.observe(.childAdded, with: { (snap) in
            if let dataM = snap.value as? [String:Any]{
                if self.mID == (dataM["missionID"] as! String) {
                    self.refM.child(self.mID).child("userStar").setValue(self.giveHelperStar)
                }else if (self.uID == (dataM["missionUser"] as! String)) {
                    if((dataM["userStar"] as! Int) !=  -1) {
                        self.needMissionCount = self.needMissionCount + 1
                        self.needTotalStar = self.needTotalStar + (dataM["userStar"] as! Int)
                    }
                }
            }
        })
        complition()
    }
    
    @IBAction func giveStar(_ sender: Any) {
        getFinishDB {
            self.refU.observe(.childAdded, with: { (snaps) in
                if let dataU = snaps.value as? [String:Any]{
                    if ( self.uID == (dataU["usermail"] as! String)) {
                        let x:Double = Double(Double(self.needTotalStar + self.giveHelperStar)/Double(self.needMissionCount + 1))
                        let star:Double = Double(round(100*x)/100) //取到小數第二位
                        Database.database().reference().child("User").child(snaps.key).child("userNeedStar").setValue(star)
                    }
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(mID)
        print(uID)

        refM.observe(.childAdded, with: { (snap) in
            if let dataM = snap.value as? [String:Any]{
                if ( self.mID == (dataM["missionID"] as! String)) {
                    self.objectDetail.text = dataM["objectDetail"] as! String
                }
            }
        })
        refU.observe(.childAdded, with: { (snaps) in
            if let dataU = snaps.value as? [String:Any]{
                if ( self.uID == (dataU["usermail"] as! String)) {
                    self.needName.text = dataU["username"] as! String
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
