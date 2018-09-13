//
//  RecordReturnMissionViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/29.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase

class RecordReturnMissionViewController: UIViewController {
    var missionID:String = ""
    lazy var ref = Database.database().reference().child("Mission").child(missionID)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "回報任務"
        print(missionID)
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var getpic: UIButton!
    @IBOutlet weak var noGetPic: UIButton!
    
    var isGet = 0
    @IBAction func getItem(_ sender: Any) {
        isGet = 0
        getpic.setBackgroundImage(UIImage(named: "yesGet"), for: .normal)
        noGetPic.setBackgroundImage(UIImage(named: "noGet"), for: .normal)
    }
    
    @IBAction func noGetItem(_ sender: Any) {
        isGet = 1
        getpic.setBackgroundImage(UIImage(named: "noGet"), for: .normal)
        noGetPic.setBackgroundImage(UIImage(named: "yesGet"), for: .normal)
    }
    @IBAction func checkAction(_ sender: Any) {
        Database.database().reference().child("Mission").observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if (self.missionID == (data["missionID"] as! String)) {
                    if self.isGet == 0 {
                        self.ref.child("status").setValue("done")
                        
                    } else {
                        self.ref.child("status").setValue("hate")
                    }
                }
            }
        })
        sleep(1)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backbtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    


}
