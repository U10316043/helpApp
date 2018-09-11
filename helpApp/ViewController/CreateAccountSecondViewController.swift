//
//  CreateAccountSecondViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/26.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class CreateAccountSecondViewController: UIViewController,UITextFieldDelegate {
    var ref = Database.database().reference().child("User")
    var mail = "hand@1.com"//從前一頁傳來的email
    @IBOutlet weak var usermail: UILabel!
    

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var usergender: UISegmentedControl!
    @IBOutlet weak var userschool: UITextField!
    @IBOutlet weak var usergrade: UITextField!
    @IBOutlet weak var userphone: UITextField!
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        usermail.text = "your mail: \(mail)"
        // Do any additional setup after loading the view.
        
     
    }
    
    
    
    
    @IBAction func completeCreateAccount(_ sender: Any) {
        if username.text == "" {
            emptyAlertFunction(alertMessage:"姓名不能為空")
        } else if userschool.text == "" {
             emptyAlertFunction(alertMessage:"學校不能為空")
        } else if usergrade.text == "" {
             emptyAlertFunction(alertMessage:"年級不能為空")
        } else if userphone.text == "" {
             emptyAlertFunction(alertMessage:"電話不能為空")
        } else {
            var gender:String = usergender.titleForSegment(at: usergender.selectedSegmentIndex)!
            print("gender: \(gender)")
            let userdata = ["usermail": mail,"username":username.text!,"usergender":gender,"userschool":userschool.text!,"usergrade":usergrade.text!,"userphone":userphone.text!,"userHelpStar":-1, "userNeedStar":-1] as [String : Any]
            
            let alertController = UIAlertController(title: "Success", message: "You have filled in  your information", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default) { (defaultAction) -> Void in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabbarVC")
                self.present(vc!, animated: true, completion: nil)
            }
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
            
            ref.childByAutoId().setValue(userdata)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}
