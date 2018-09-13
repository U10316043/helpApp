//
//  ProfileHomeViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/27.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase


class ProfileHomeViewController: UIViewController {
    lazy var refM = Database.database().reference().child("Mission")
    lazy var refU = Database.database().reference().child("User")
    var completeMissionNum:Int = 0
    var helperHeart:Int = 0
    var needHeart:Int = 0
    var userNeedHeart:Double = 0.0 // userNeedStar from DB
    var userHelpHeart:Double = 0.0 // userHelpStar from DB
    var userAllHeart:Double = 0.0 // (userNeedHeart + userHelpHeart)/2
    @IBOutlet weak var userComplexHeart: UIImageView!
    @IBOutlet weak var userComplexHeartLabel: UILabel!
    @IBOutlet weak var userPicture: UIImageView!
    
    let user = Auth.auth().currentUser
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userschool: UILabel!
   
    @IBAction func logout(_ sender: Any) {
        if Auth.auth().currentUser != nil{
            do{
                try Auth.auth().signOut()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
                self.present(vc!, animated: true, completion: nil)
            }catch let error as NSError{
                print(error.localizedDescription)
            }
        }
    }
    
    var heartList:[UIImage] = [UIImage(named: "allHeart0")!,UIImage(named: "allHeart1")!,UIImage(named: "allHeart2")!,UIImage(named: "allHeart3")!,UIImage(named: "allHeart4")!,UIImage(named: "allHeart5")! ]
    
    override func viewWillAppear(_ animated: Bool) {
        refU.observe(.childAdded, with: {(snap) in
            if let data = snap.value as? [String:Any] {
                if (self.user?.email == data["usermail"] as! String) {
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
                    self.userName.text = data["username"] as! String
                    self.userschool.text = data["userschool"] as! String
                    self.userNeedHeart = data["userNeedStar"] as! Double
                    self.userHelpHeart = data["userHelpStar"] as! Double
                    self.userComplexHeartLabel.isHidden = false
                    self.userComplexHeart.isHidden = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
