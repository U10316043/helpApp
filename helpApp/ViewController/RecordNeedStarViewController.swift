//
//  RecordNeedStarViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/30.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase

class RecordNeedStarViewController: UIViewController {
    lazy var refM = Database.database().reference().child("Mission")
    lazy var refU = Database.database().reference().child("User")
    var missionID = ""
    var helperID = ""
    var giveHelperStar:Int = 0 //這次任務給了幾顆愛心(0~5)
    var helperMissionCount:Int = 0  // 幫助自己的人 他之前幫助過別人的次數（不加這次）
    var helperTotalStar:Int = 0 //幫助自己的人 他之前幫助過別人得到的總愛心數（不加這次）
    @IBOutlet weak var whoHelp: UILabel!
    @IBOutlet weak var itemDetail: UILabel!
    
    @IBAction func backbtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getFinishDB(complition: @escaping () -> Void){
        refM.observe(.childAdded, with: { (snap) in
            if let dataM = snap.value as? [String:Any]{
                if self.missionID == (dataM["missionID"] as! String) {
                    self.refM.child(self.missionID).child("helperStar").setValue(self.giveHelperStar)
                }else if (self.helperID == (dataM["helper"] as! String)) {
                    if(dataM["helperStar"] as! Int != -1) {
                        self.helperMissionCount = self.helperMissionCount + 1
                        self.helperTotalStar = self.helperTotalStar + (dataM["helperStar"] as! Int)
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
                    if ( self.helperID == (dataU["usermail"] as! String)) {
                        let x:Double = Double(Double(self.helperTotalStar + self.giveHelperStar)/Double(self.helperMissionCount + 1))
                        let star:Double = Double(round(100*x)/100) //取到小數第二位
                        Database.database().reference().child("User").child(snaps.key).child("userHelpStar").setValue(star)
                    }
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var h01: UIButton!
    @IBOutlet weak var h02: UIButton!
    @IBOutlet weak var h03: UIButton!
    @IBOutlet weak var h04: UIButton!
    @IBOutlet weak var h05: UIButton!
    var h1bool:Bool = false
    @IBAction func h1(_ sender: Any) {
        if(h1bool == false) {
            h01.setImage(UIImage(named: "heart"), for: .normal)
            h02.setImage(UIImage(named: "heart2"), for: .normal)
            h03.setImage(UIImage(named: "heart2"), for: .normal)
            h04.setImage(UIImage(named: "heart2"), for: .normal)
            h05.setImage(UIImage(named: "heart2"), for: .normal)
            h1bool = true
            giveHelperStar = 1
        }else {
            h01.setImage(UIImage(named: "heart2"), for: .normal)
            h02.setImage(UIImage(named: "heart2"), for: .normal)
            h03.setImage(UIImage(named: "heart2"), for: .normal)
            h04.setImage(UIImage(named: "heart2"), for: .normal)
            h05.setImage(UIImage(named: "heart2"), for: .normal)
            h1bool = false
            giveHelperStar = 0
        }
    }
    @IBAction func h2(_ sender: Any) {
        h01.setImage(UIImage(named: "heart"), for: .normal)
        h02.setImage(UIImage(named: "heart"), for: .normal)
        h03.setImage(UIImage(named: "heart2"), for: .normal)
        h04.setImage(UIImage(named: "heart2"), for: .normal)
        h05.setImage(UIImage(named: "heart2"), for: .normal)
        h1bool = false
        giveHelperStar = 2
    }
    @IBAction func h3(_ sender: Any) {
        h01.setImage(UIImage(named: "heart"), for: .normal)
        h02.setImage(UIImage(named: "heart"), for: .normal)
        h03.setImage(UIImage(named: "heart"), for: .normal)
        h04.setImage(UIImage(named: "heart2"), for: .normal)
        h05.setImage(UIImage(named: "heart2"), for: .normal)
        h1bool = false
        giveHelperStar = 3
    }
    @IBAction func h4(_ sender: Any) {
        h01.setImage(UIImage(named: "heart"), for: .normal)
        h02.setImage(UIImage(named: "heart"), for: .normal)
        h03.setImage(UIImage(named: "heart"), for: .normal)
        h04.setImage(UIImage(named: "heart"), for: .normal)
        h05.setImage(UIImage(named: "heart2"), for: .normal)
        h1bool = false
        giveHelperStar = 4
    }
    @IBAction func h5(_ sender: Any) {
        h01.setImage(UIImage(named: "heart"), for: .normal)
        h02.setImage(UIImage(named: "heart"), for: .normal)
        h03.setImage(UIImage(named: "heart"), for: .normal)
        h04.setImage(UIImage(named: "heart"), for: .normal)
        h05.setImage(UIImage(named: "heart"), for: .normal)
        h1bool = false
        giveHelperStar = 5
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(missionID)
        print(helperID)
        refM.observe(.childAdded, with: { (snap) in
            if let dataM = snap.value as? [String:Any]{
                if ( self.missionID == (dataM["missionID"] as! String)) {
                    self.itemDetail.text = dataM["objectDetail"] as! String
                }
            }
        })
        refU.observe(.childAdded, with: { (snaps) in
            if let dataU = snaps.value as? [String:Any]{
                if ( self.helperID == (dataU["usermail"] as! String)) {
                    self.whoHelp.text = dataU["username"] as! String
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
