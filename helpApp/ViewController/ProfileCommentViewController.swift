//
//  ProfileCommentViewController.swift
//  helpApp
//
//  Created by xin on 2018/9/7.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase

class ProfileCommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    lazy var refM = Database.database().reference().child("Mission")
    lazy var refU = Database.database().reference().child("User")
    
    var heartList:[UIImage] = [UIImage(named: "allHeart0")!,UIImage(named: "allHeart1")!,UIImage(named: "allHeart2")!,UIImage(named: "allHeart3")!,UIImage(named: "allHeart4")!,UIImage(named: "allHeart5")! ]
    
    var commentNum:Int = 0
    var missionArray:[String] = [] //放入有給我評價的missionID
    var userEmailArray:[String] = [] //放入評價我的人的email
    var userNameArray:[String] = [] //放入評價我的人的name
    var helpNeedArray:[String] = [] //評價是助人還是求助
    var userHeartArray:[Int] = [] //放入評價
    var userPictureArray:[UIImage] = [] //放入評價
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var missionCount: UILabel!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellComment")
        let mycell = cell as! ProfileCommentTableViewCell
        mycell.userPicture.image = userPictureArray[indexPath.row]
        mycell.userName.text = "\(userNameArray[indexPath.row])"
        mycell.userHeart.image = heartList[userHeartArray[indexPath.row]]
        mycell.userHelpNeed.text = "\(helpNeedArray[indexPath.row])"
        mycell.userMessage.text = "非常熱心的人！謝謝你！"
        return cell!
       
    }
    
    
    
    
    func getFinish(complition: @escaping () -> Void){
        self.refM.observe(.childAdded, with: { (snapM) in
            if let dataM = snapM.value as? [String:Any]{
                if (Auth.auth().currentUser?.email == dataM["helper"] as! String) && (dataM["helperStar"] as! Int) != -1 {
                    self.missionArray.insert(dataM["missionID"] as! String ,at:0 )
                    self.userEmailArray.insert(dataM["missionUser"] as! String ,at:0 )
                    self.userNameArray.insert(dataM["missionUser"] as! String ,at:0 )
                    self.helpNeedArray.insert("給助人的你: " ,at:0 )
                    self.userHeartArray.insert(dataM["helperStar"] as! Int ,at:0 )
                    self.userPictureArray.insert(UIImage(named: "tab5")! ,at:0 )
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else if (Auth.auth().currentUser?.email == dataM["missionUser"] as! String) && (dataM["userStar"] as! Int) != -1 {
                    self.missionArray.insert(dataM["missionID"] as! String ,at:0 )
                    self.userEmailArray.insert(dataM["helper"] as! String ,at:0 )
                    self.userNameArray.insert(dataM["helper"] as! String ,at:0 )
                    self.helpNeedArray.insert("給受助的你: " ,at:0 )
                    self.userHeartArray.insert(dataM["userStar"] as! Int ,at:0 )
                    self.userPictureArray.insert(UIImage(named: "tab5")! ,at:0 )
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    
                }
            }
        })
        complition()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.tableView.reloadData()
        // 畫面載入時先清空陣列
        missionArray = [] //放入有給我評價的missionID
        userEmailArray = [] //放入評價我的人的email
        userNameArray = [] //放入評價我的人的name
        helpNeedArray = [] //評價是助人還是求助
        userHeartArray = [] //放入評價
        getFinish {
            self.refU.observe(.childAdded, with: { (snapU) in
                if let dataU = snapU.value as? [String:Any] {
                    for (index, mail) in self.userEmailArray.enumerated() {
                        if mail == dataU["usermail"] as! String {
                            self.userNameArray[index] = dataU["username"] as! String
                            self.missionCount.text = "累積\(self.missionArray.count)則評價"
                            if let imageUrlString = dataU["userPicture"] as? String {
                                if let imageUrl = URL(string: imageUrlString) {
                                    URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, response, error) in
                                        if error != nil {
                                            print("Download Image Task Fail: \(error!.localizedDescription)")
                                        } else if let imageData = data {
                                            DispatchQueue.main.async {
                                                self.userPictureArray[index] = UIImage(data: imageData)!
                                                DispatchQueue.main.async {
                                                    self.tableView.reloadData()
                                                }
                                            }
                                        }
                                    }).resume()
                                }
                            }
                        }
                    }
                    
                    
                }
            })
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
