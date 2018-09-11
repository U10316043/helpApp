//
//  CreateAccountFirstViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/26.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateAccountFirstViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func toNextAccountPage(_ sender: Any) {
        if userMail.text == "" {
            let alertController = UIAlertController(title: "Error", message: "please enter your email password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().createUser(withEmail: userMail.text!, password: userPassword.text!) { (user, error) in
                if error == nil {
                    let alertController = UIAlertController(title: "Success", message: "You have successfully signed up", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default) { (defaultAction) -> Void in
                        let vc:CreateAccountSecondViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountSecondVC") as! CreateAccountSecondViewController
                        vc.mail = self.userMail.text!
                        self.present(vc, animated: true, completion: nil)
                    }
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription,
                                                            preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
