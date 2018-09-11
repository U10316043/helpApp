//
//  RecordHomeViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/28.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RecordHomeViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    lazy var refM = Database.database().reference().child("Mission")
    lazy var refU = Database.database().reference().child("User")
    //助人的項目
    var helpmissionArray:[String] = [] //放入任務的missionID
    var helpItemArray:[String] = [] //放入借物東西的細項objectDetail
    var helpUserMailArray:[String] = [] //放入被幫助人的mail
    var helpUserNameArray:[String] = [] //發布求救 的 人的名字
    var helpStatus:[String] = [] //任務狀態
    var helpCategory:[String] = []
    //求助的項目
    var needmissionArray:[String] = [] //放入任務的missionID
    var needItemArray:[String] = [] //放入借物東西的細項objectDetail
    var needUserMailArray:[String] = [] //放入幫助我的人的mail
    var needUserNameArray:[String] = [] //放入幫助我的人的name
    var needStatus:[String] = [] //任務狀態
    var needCategory:[String] = [] // 借的物品分類大項
    var cateA:[String] = ["雨具", "充電設備", "安全帽"]
    var imgList: [UIImage] = [UIImage(named: "ca1")!, UIImage(named: "ca2")!, UIImage(named: "ca3")!]
    
    
    @IBOutlet weak var helpTableview: UITableView! //table - 助人
    @IBOutlet weak var needTableview: UITableView! //table - 求助

    @IBOutlet weak var helpPeople: UIView! //view - 助人
    @IBOutlet weak var needHelp: UIView!  //view - 求助
    
    @IBOutlet weak var pageControl: UISegmentedControl!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int = 0
        if tableView.tag == 3000 {
            count = helpmissionArray.count
        } else if tableView.tag == 3001 {
            count = needmissionArray.count
        } else {
            
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var callwho:UITableViewCell?
        if tableView.tag == 3000 { //助人
            let cellHelp = tableView.dequeueReusableCell(withIdentifier: "cellHelp") as! RecordHelpPeopleTableViewCell
            let cindex = cateA.index(of: helpCategory[indexPath.row])
            cellHelp.helpImg.image = imgList[cindex!]
            cellHelp.Item.text = "\(helpItemArray[indexPath.row])"
            cellHelp.needHelpName.text = "\(helpUserNameArray[indexPath.row])"  //發布求救的人的名字
            if helpStatus[indexPath.row] == "waiting" {
                cellHelp.missionStatus.text = "等待好心人"
            } else if helpStatus[indexPath.row] == "moving" {
                cellHelp.missionStatus.text = "任務進行中"
            } else if helpStatus[indexPath.row] == "fail" {
                cellHelp.missionStatus.text = "任務失敗"
            } else if helpStatus[indexPath.row] == "done" {
                cellHelp.missionStatus.text = "任務成功"
            } else if helpStatus[indexPath.row] == "hate" {
                cellHelp.missionStatus.text = "任務結束"
            } else {
                
            }
            callwho = cellHelp
        } else if tableView.tag == 3001 {  // 求救
            let cellNeed = tableView.dequeueReusableCell(withIdentifier: "cellNeed") as! RecordNeedHelpTableViewCell
            let cindex = cateA.index(of: needCategory[indexPath.row])
            cellNeed.needImg.image = imgList[cindex!]
            cellNeed.Item.text = "\(needItemArray[indexPath.row])"
            cellNeed.helperName.text = "\(needUserNameArray[indexPath.row])"  //幫助我的人 的名字
            if needStatus[indexPath.row] == "waiting" {
                cellNeed.missionStatus.text = "等待好心人"
            } else if needStatus[indexPath.row] == "moving" {
                cellNeed.missionStatus.text = "任務進行中"
            } else if needStatus[indexPath.row] == "fail" {
                cellNeed.missionStatus.text = "任務失敗"
            } else if needStatus[indexPath.row] == "done" {
                cellNeed.missionStatus.text = "任務成功"
            } else if needStatus[indexPath.row] == "hate" {
                cellNeed.missionStatus.text = "任務結束"
            } else {
                
            }
            callwho = cellNeed
        } else {
            
        }
        return callwho!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 3000 {
            let Storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vcHelp:RecordHelpSelfViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecordHelpSelfVC") as! RecordHelpSelfViewController
            vcHelp.objectTitle = helpItemArray[indexPath.row]
            vcHelp.helpMissionId = helpmissionArray[indexPath.row]
            vcHelp.helpUserMail = helpUserMailArray[indexPath.row]
            self.navigationController?.pushViewController(vcHelp, animated: true)
        } else if tableView.tag == 3001 {
            let Storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vcNeed:RecordNeedSelfViewController = self.storyboard?.instantiateViewController(withIdentifier: "RecordNeedSelfVC") as! RecordNeedSelfViewController
            vcNeed.objectTitle = needItemArray[indexPath.row]
            vcNeed.needMissionId = needmissionArray[indexPath.row]
            vcNeed.needUserMail = needUserMailArray[indexPath.row]
            self.navigationController?.pushViewController(vcNeed, animated: true)
        } else {
            
        }
        
    }

    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch pageControl.selectedSegmentIndex
        {
        case 1:
            needHelp.isHidden = true
            helpPeople.isHidden = false
        case 0:
            needHelp.isHidden = false
            helpPeople.isHidden = true
        default:
            break;
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        //助人的項目
        helpmissionArray = [] //放入任務的missionID
        helpItemArray = [] //放入借物東西的細項objectDetail
        helpUserMailArray = [] //放入被幫助人的mail
        helpUserNameArray = [] //發布求救 的 人的名字
        helpStatus = [] //任務狀態
        helpCategory = []
        //求助的項目
        needmissionArray = [] //放入任務的missionID
        needItemArray = [] //放入借物東西的細項objectDetail
        needUserMailArray = [] //放入幫助我的人的mail
        needUserNameArray = [] //放入幫助我的人的name
        needStatus = [] //任務狀態
        needCategory = [] // 借的物品分類大項
        // 把每個array清空重新從資料庫取資料
        getFinishDB {
            // needUserNameArray  放入幫助我的人的name
            for (indexa, mail) in self.needUserNameArray.enumerated() {
                if mail == "null" {
                    self.needUserNameArray[indexa] = "沒人QQ"
                }
            }
            self.refU.observe(.childAdded, with: { (snapU) in
                if let dataU = snapU.value as? [String:Any]{
                    for (index, helpmail) in self.helpUserNameArray.enumerated() {
                        if helpmail == dataU["usermail"]as! String {
                            self.helpUserNameArray[index] = dataU["username"] as! String
                            DispatchQueue.main.async {
                                self.helpTableview.reloadData()
                            }
                        }
                    }
                    
                }
            })
            
            self.refU.observe(.childAdded, with: { (snapU) in
                if let dataU = snapU.value as? [String:Any]{
                    for (indexa, mail) in self.needUserNameArray.enumerated() {
                        if mail == dataU["usermail"]as! String {
                            self.needUserNameArray[indexa] = dataU["username"]as! String
                            DispatchQueue.main.async {
                                self.needTableview.reloadData()
                            }
                        }
                    }
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func getFinishDB(complition: @escaping () -> Void){
        refM.observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if ( Auth.auth().currentUser?.email == (data["helper"] as! String)) {
                    self.helpmissionArray.insert(data["missionID"] as! String ,at:0 )
                    self.helpCategory.insert(data["title"] as! String, at:0 )
                    self.helpItemArray.insert(data["objectDetail"] as! String, at:0)
                    self.helpUserMailArray.insert(data["missionUser"] as! String, at:0)
                    self.helpUserNameArray.insert(data["missionUser"] as! String, at:0)
                    self.helpStatus.insert(data["status"] as! String, at:0)
                    DispatchQueue.main.async {
                        self.helpTableview.reloadData()
                    }
                }
                if ( Auth.auth().currentUser?.email == (data["missionUser"] as! String)) {
                    self.needmissionArray.insert(data["missionID"] as! String, at:0)
                    self.needCategory.insert(data["title"] as! String, at:0)
                    self.needItemArray.insert(data["objectDetail"] as! String, at:0)
                    self.needUserMailArray.insert(data["helper"] as! String, at:0) //把helper的資訊 加入 needUserMailArray 的陣列中
                    self.needUserNameArray.insert(data["helper"] as! String, at:0)
                    self.needStatus.insert(data["status"] as! String, at:0)
  
                    DispatchQueue.main.async {
                        self.needTableview.reloadData()
                    }
                    // 當helper的資訊為null時,  把"gg" append加入 needUserNameArray的array
                }
                complition()
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        helpTableview.tag = 3000
        needTableview.tag = 3001
        self.pageControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], for: UIControlState.selected) //改變UISegmentedControl 按下時的字體顏色
        self.pageControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.darkGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], for: UIControlState.normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
