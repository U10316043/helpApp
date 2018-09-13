//
//  WelcomeViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/25.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import FirebaseAuth

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
    

    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        let currentPageNumber = sender.currentPage
//        tutorImage.image = imgList[sender.currentPage]
        let width = scrollView.frame.size.width
        let offset = CGPoint(x: width * CGFloat(currentPageNumber), y: 0)
        scrollView.setContentOffset(offset, animated: true)
    }
    var tutorImage: UIImageView!
  
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        if user != nil {
            print("user：\(user?.email)")

            
            
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
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
