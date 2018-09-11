//
//  AddMissionViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/27.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

let category:[String] = ["雨具","安全帽","充電設備"]
let getTime:[String] = ["10","20","30"]
class AddMissionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate {
    lazy var ref = Database.database().reference().child("Mission")
    var picker = UIPickerView()
    var formatter2: DateFormatter! = nil
    let myDatePicker2 = UIDatePicker()
    
    var picker2 = UIPickerView()
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBOutlet weak var categoryTextfield: UITextField!
    @IBOutlet weak var ItemTextfield: UITextField!
    @IBOutlet weak var getTimeTextfield: UITextField!
    @IBOutlet weak var returnBackTimeTextField: UITextField!
    
    @IBAction func uploadMissionAction(_ sender: Any) {
        let vc = UIApplication.shared.delegate as! AppDelegate
        if categoryTextfield.text == "" {
            emptyAlertFunction(alertMessage:"分類未選擇")
        } else if ItemTextfield.text == "" {
            emptyAlertFunction(alertMessage:"物品細項請填寫")
        } else if getTimeTextfield.text == "" {
            emptyAlertFunction(alertMessage:"希望借到時間請選擇")
        } else if returnBackTimeTextField.text == "" {
            emptyAlertFunction(alertMessage:"借用歸還時間請選擇")
        } else if vc.locationManager.location?.coordinate == nil {
            emptyAlertFunction(alertMessage:"請開啟定位服務")
        } else {
            let currentPosition = vc.locationManager.location?.coordinate
            let missionID = ref.childByAutoId()
            let childID:String = missionID.key
            let formatter:DateFormatter = DateFormatter()
            formatter.dateFormat = "YYYY-MMM-dd HH:mm:ss"
            let missionTime:Date = Date()
            let newMissonTime = formatter.string(from: missionTime)
            let user = Auth.auth().currentUser
            /* missionID: 任務亂數編號; title: 借東西的分類; subtitle: 希望借到的時間; missionUser: 發布任務的人信箱; latitude: 發佈任務人精度; longtitude:發佈任務人緯度; objectDetail:物品(詳細說明); setTime:發布任務人時間; watingTime:希望借到的時間; returnTime:歸還時間;status:任務狀態;helperStar:幫助者評價;userStar:受助者評價
             */
            let helperInitial:String = "null"
            let helperLatitudeInitial:String = "null"
            let helperLongitudeInitial:String = "null"
            let helperSt:Int = -1
            let userSt:Int = -1
            let alertController = UIAlertController(title: "即將發送借物請求", message: "提醒你選擇公共場所執行此任務，並好好愛護好心人的物品、如期歸還唷！", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "發送", style: .default) { (defaultAction) -> Void in
                let data:[String:Any] = ["missionID": childID,"title":self.categoryTextfield.text!,"subtitle":self.subtitle,"missionUser": user!.email,"userLatitude":currentPosition?.latitude,"userLongitude":currentPosition?.longitude,"objectDetail":self.ItemTextfield.text!, "setTime":newMissonTime,"waitingTime":self.subtitle,"returnTime":self.returnBackTimeTextField.text!, "status":"waiting","helper":helperInitial,"helperLatitude":helperLatitudeInitial,"helperLongitude":helperLongitudeInitial, "helperStar":helperSt,"userStar":userSt] as [String : Any]
                missionID.setValue(data)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabbarVC")
                self.present(vc!, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel,handler:nil)
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)

        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var itemcount = 0
        if pickerView.tag == 1001 {
            itemcount = category.count
        } else if pickerView.tag == 1002 {
            itemcount = getTime.count
        } else {
            
        }
        return itemcount
    }
    var subtitle:String = ""
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var item:String = ""
        if pickerView.tag == 1001 {
            item = category[row]
        } else if pickerView.tag == 1002 {
            subtitle = getTime[row]
            item = getTime[row] + " min"
        } else {
            
        }
        return item
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1001 {
            categoryTextfield?.text = category[row]
        } else if pickerView.tag == 1002 {
            getTimeTextfield?.text = getTime[row]
        } else {
            
        }
        self.view.endEditing(false)
    }
    

    

    
    @objc func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    // UIDatePicker 改變選擇時執行的動作
    @objc func datePickerChanged2(datePicker:UIDatePicker) {
        // 將 UITextField 的值更新為新的日期
        returnBackTimeTextField?.text = formatter2.string(from: datePicker.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        picker.tag = 1001
        picker2.tag = 1002
        // 將 UITextField 原先鍵盤的視圖更換成 UIPickerView
        categoryTextfield.inputView = picker
        
        picker2.delegate = self
        picker2.dataSource = self
        // 將 UITextField 原先鍵盤的視圖更換成 UIPickerView
        getTimeTextfield.inputView = picker2
        
        // 增加一個觸控事件(讓按到空白的地方隱藏pickerview)
        let tap = UITapGestureRecognizer(
            target: self,
            action:
            #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)// 加在最基底的 self.view 上
        
        //歸還時間設定
        formatter2 = DateFormatter()
        formatter2.dateFormat = "MM-dd HH:MM"
        // 設置 UIDatePicker 格式(日期和時間)
        myDatePicker2.datePickerMode = .dateAndTime
        // 選取時間時的分鐘間隔 這邊以 5 分鐘為一個間隔
        myDatePicker2.minuteInterval = 10
        // 設置 UIDatePicker 顯示的語言環境
        myDatePicker2.locale = NSLocale(localeIdentifier: "zh_TW") as Locale
        // 將 UITextField 原先鍵盤的視圖更換成 UIDatePicker
        returnBackTimeTextField.inputView = myDatePicker2
        // 設置 UITextField 預設的內容
        returnBackTimeTextField.text = formatter2.string(from: myDatePicker2.date)
        myDatePicker2.addTarget(
            self,
            action:
            #selector(datePickerChanged2),
            for: .valueChanged)
        
        
    }
    
    // 當任何的textfield為空時跳出提示
    func emptyAlertFunction(alertMessage:String) {
        let alertController = UIAlertController(title: "提示", message: alertMessage, preferredStyle: .alert)
        // 建立[確認]按鈕
        let okAction = UIAlertAction(title: "確認",style: .cancel, handler: nil)
        alertController.addAction(okAction)
        // 顯示提示框
        self.present(alertController,animated: true,completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


