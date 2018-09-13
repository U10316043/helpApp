//
//  ProfileSettingViewController.swift
//  helpApp
//
//  Created by xin on 2018/9/11.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import Firebase

class ProfileSettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    lazy var ref = Database.database().reference().child("User")
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var userGender: UISegmentedControl!
    @IBOutlet weak var userSchool: UITextField!
    @IBOutlet weak var userGrade: UITextField!
    @IBOutlet weak var userPhone: UITextField!
    @IBOutlet weak var userPicture: UIImageView!
    
    
    @IBAction func changePicture(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        // 委任代理
        imagePickerController.delegate = self
        // 建立一個 UIAlertController 的實體
        // 設定 UIAlertController 的標題與樣式為 動作清單 (actionSheet)
        let imagePickerAlertController = UIAlertController(title: "上傳圖片", message: "請選擇要上傳的圖片", preferredStyle: .actionSheet)
        // 建立三個 UIAlertAction 的實體
        // 新增 UIAlertAction 在 UIAlertController actionSheet 的 動作 (action) 與標題
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { (Void) in
            // 判斷是否可以從照片圖庫取得照片來源
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.photoLibrary)，並 present UIImagePickerController
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (Void) in
            // 判斷是否可以從相機取得照片來源
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.camera)，並 present UIImagePickerController
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        // 新增一個取消動作，讓使用者可以跳出 UIAlertController
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (Void) in
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        // 將上面三個 UIAlertAction 動作加入 UIAlertController
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        // 當使用者按下 uploadBtnAction 時會 present 剛剛建立好的三個 UIAlertAction 動作與
        present(imagePickerAlertController, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.ref.observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                if Auth.auth().currentUser?.email == data["usermail"] as? String {
                    self.userEmail.text = data["usermail"] as? String
                    self.userName.text = data["username"] as? String
                    if data["usergender"] as! String == "male" {
                        self.userGender.selectedSegmentIndex = 0
                    } else {
                        self.userGender.selectedSegmentIndex = 1
                    }
                    self.userSchool.text = data["userschool"] as? String
                    self.userGrade.text = data["usergrade"] as? String
                    self.userPhone.text = data["userphone"] as? String
                    
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
                    
                }
            }
        })
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        // 取得從 UIImagePickerController 選擇的檔案
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = pickedImage
        }
        // 可以自動產生一組獨一無二的 ID 號碼，方便等一下上傳圖片的命名
        let uniqueString = NSUUID().uuidString
        // 當判斷有 selectedImage 時，我們會在 if 判斷式裡將圖片上傳
        if let selectedImage = selectedImageFromPicker {
            let storageRef = Storage.storage().reference().child("ImageFireUpload").child("\(uniqueString).png")
            if let uploadData = UIImagePNGRepresentation(selectedImage) {
                // if let uploadData = UIImageJPEGRepresentation(selectedImage, 0.1) {
                // 這行就是 FirebaseStorage 關鍵的存取方法。
                storageRef.putData(uploadData, metadata: nil, completion: { (data, error) in
                    if error != nil {
                        // 若有接收到錯誤，我們就直接印在 Console 就好，在這邊就不另外做處理。
                        print("Error: \(error!.localizedDescription)")
                        return
                    }
                    // 連結取得方式就是：data?.downloadURL()?.absoluteString。
                    if let uploadImageUrl = data?.downloadURL()?.absoluteString {
                        // 我們可以 print 出來看看這個連結是不是我們剛剛所上傳的照片。
                        print("Photo Url: \(uploadImageUrl)")
                        
                        self.ref.observe(.childAdded, with: { (snaps) in
                            if let data = snaps.value as? [String:Any]{
                                if Auth.auth().currentUser?.email == data["usermail"] as? String {
                                    self.ref.child(snaps.key).child("userPicture").setValue(uploadImageUrl, withCompletionBlock: { (error, dataRef) in
                                        if error != nil {
                                            print("Database Error: \(error!.localizedDescription)")
                                        }else {
                                            print("圖片已儲存")
                                        }
                                    })
                                }
                            }
                        })

                    }
                })
            }
            print("\(uniqueString), \(selectedImage)")
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func checkChange(_ sender: Any) {
        if userName.text == "" {
            alertFunction(alertTitle:"提示", alertMessage:"姓名不能為空")
        } else if userSchool.text == "" {
            alertFunction(alertTitle:"提示", alertMessage:"學校不能為空")
        } else if userGrade.text == "" {
            alertFunction(alertTitle:"提示", alertMessage:"年級不能為空")
        } else if userPhone.text == "" {
            alertFunction(alertTitle:"提示", alertMessage:"電話不能為空")
        } else {
            let gender:String = userGender.titleForSegment(at: userGender.selectedSegmentIndex)!
            let name:String = self.userName.text!
            let school:String = self.userSchool.text!
            let grade:String = self.userGrade.text!
            let phone:String = self.userPhone.text!
            self.ref.observe(.childAdded, with: { (snaps) in
                if let data = snaps.value as? [String:Any]{
                    if Auth.auth().currentUser?.email == data["usermail"] as? String {
                        self.ref.child(snaps.key).child("username").setValue(name)
                        self.ref.child(snaps.key).child("usergender").setValue(gender)
                        self.ref.child(snaps.key).child("userschool").setValue(school)
                        self.ref.child(snaps.key).child("usergrade").setValue(grade)
                        self.ref.child(snaps.key).child("userphone").setValue(phone)
                    }
                }
            })
            alertFunction(alertTitle:"成功", alertMessage:"已修改個人資料")
        }
    }
    
    func alertFunction(alertTitle:String, alertMessage:String) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "確認", style: .default) { (defaultAction) -> Void in
            self.viewWillAppear(true)
        }
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
