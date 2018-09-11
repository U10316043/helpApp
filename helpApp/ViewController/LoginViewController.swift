//
//  LoginViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/26.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func loginAction(_ sender: Any) {
        if self.userMail.text == "" || self.userPassword.text == "" {
            let alertController = UIAlertController(title: "Error",message: "Please enter an email and password.",preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            Auth.auth().signIn(withEmail: self.userMail.text!,password: self.userPassword.text!){ (user, error) in
                if error == nil {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabbarVC")
                    self.present(vc!, animated: true, completion: nil)
                } else {
                    let alertController = UIAlertController(title: "Error",message: error?.localizedDescription,preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let user = Auth.auth().currentUser
        if user != nil {
            print("//User information")
            print(user)
            print(user?.uid)
            print(user?.email)
            print("//User logged in")
        } else {
            print("//User Not logged in")
            
        }
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
