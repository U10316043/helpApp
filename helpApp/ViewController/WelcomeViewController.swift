//
//  WelcomeViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/25.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

let pageNum = 3
class WelcomeViewController: UIViewController, UIScrollViewDelegate {
    
    let fullScreenSize = UIScreen.main.bounds.size
    var imgList: [UIImage] = [
        UIImage(named: "tech01")!,
        UIImage(named: "tech02")!,
        UIImage(named: "tech03")!
    ]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createCountButton: UIButton!
    

    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        let currentPageNumber = sender.currentPage
//        tutorImage.image = imgList[sender.currentPage]
        let width = scrollView.frame.size.width
        let offset = CGPoint(x: width * CGFloat(currentPageNumber), y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    var tutorImage: UIImageView!

    
    @IBAction func toLogin(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC")
        self.present(vc!, animated: true, completion: nil)
    }
    @IBAction func toCreateCount(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateAccountFirstVC")
        self.present(vc!, animated: true, completion: nil)
    }
    
    var isWelcomePage:Bool = true
    
    override func viewWillDisappear(_ animated: Bool) {
        print("welcome page viewWillDisappear")
        isWelcomePage = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        isWelcomePage = true
        if user == nil {
            loginButton.isHidden = false
            createCountButton.isHidden = false
        }else {
            loginButton.isHidden = true
            createCountButton.isHidden = true
            Database.database().reference().child("User").observe(.childAdded, with: { (snap) in
                if let data = snap.value as? [String:Any]{
                    if Auth.auth().currentUser?.email == data["usermail"] as? String {
                        // 在這個welcome page時才檢查有沒有使用者創建帳號後沒有填寫詳細身份資訊
                        if self.isWelcomePage == true {
                            if (data["username"]! as! String) != "" {
                                print("true")
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabbarVC")
                                self.present(vc!, animated: true, completion: nil)
                            } else {
                                print("false")
                                Auth.auth().currentUser?.delete { error in
                                    if error != nil {
                                        // An error happened.
                                    } else {
                                        
                                    }
                                }
                                // Delete the file
                                Database.database().reference().child("User").child(snap.key).removeValue()
                                self.loginButton.isHidden = false
                                self.createCountButton.isHidden = false
                            }
                        }
                    }
                }
            })
            print("welcome page viewWillApear")
        }
        
        
        
        scrollView.contentSize.width = (fullScreenSize.width) * CGFloat(imgList.count)
        scrollView.contentSize.height = scrollView.bounds.height
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        pageControl.numberOfPages = imgList.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .blue
        pageControl.pageIndicatorTintColor = .brown
        
        for i in 0..<3{
            tutorImage = UIImageView()
            tutorImage.frame = CGRect(x: fullScreenSize.width * CGFloat(i), y: 0, width: fullScreenSize.width, height: scrollView.bounds.height)
            tutorImage.image = imgList[i]
            self.scrollView.addSubview(tutorImage)
        }
    }
    
    //利用捲到的位置來決定pageControll的currentPage ，以ScrollView來影響PageControll
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = currentPage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
