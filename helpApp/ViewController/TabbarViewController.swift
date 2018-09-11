//
//  TabbarViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/27.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase

class TabbarViewController: UITabBarController {
    lazy var ref = Database.database().reference().child("Mission")
    var missionID = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        Database.database().reference().child("Mission").observe(.childChanged, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if ((Auth.auth().currentUser?.email == data["missionUser"] as! String) && data["status"]as!String == "moving"){
                    self.missionID = data["missionID"] as! String
                    let alertController = UIAlertController(title: "人來拉！", message: "有人來幫你了", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "我知道了", style: .cancel,handler:nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    //要改成跳回紀錄
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
