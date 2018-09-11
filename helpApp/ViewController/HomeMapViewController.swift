//
//  HomeMapViewController.swift
//  helpApp
//
//  Created by xin on 2018/8/26.
//  Copyright © 2018年 xin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import Firebase


class HomeMapViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate{
    @IBOutlet weak var mkMap: MKMapView!
    var position:CLLocation?
    var missionID = ""
    var timer:Timer!
    var keys:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigation有返回鍵
        let backButton = UIBarButtonItem(title: "返回", style:
            UIBarButtonItemStyle.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem  = backButton
        //設定起始可視範圍
        mkMap.delegate = self
        let latDelta = 1.0
        let longDelta = 1.0
        let currentLocationSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let currentLocation:CLLocation = CLLocation(latitude: 25.05, longitude: 121.515)
        let currentRegion = MKCoordinateRegion(center:currentLocation.coordinate, span:currentLocationSpan)
        mkMap.setRegion(currentRegion, animated: true)
    }
    
    func fetch(complection: @escaping()->Void){
        Database.database().reference().child("Mission").observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                self.keys.append(data["missionID"]as!String)
            }
            complection()
        })
    }
    
    @IBAction func toMEaction(_ sender: Any) {
        //比例尺
        let mySpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let toRegion = MKCoordinateRegion(center: mkMap.userLocation.coordinate, span: mySpan)
        mkMap.setRegion(toRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            
            let vc:AnnotationInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "Info") as! AnnotationInfoViewController
            let annotation = view.annotation as! MyAnnotation
            vc.missionID = annotation.desc
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        
        let annotations:[MyAnnotation] =  (mkMap.annotations as? [MyAnnotation])!
        mkMap.removeAnnotations(annotations)
        
        //設置Annotation
        Database.database().reference().child("Mission").observe(.childAdded, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                self.keys.append(data["missionID"]as!String)
            }
        })
        
        fetch { () in Database.database().reference().child("Mission").child(self.keys[self.keys.count-1]).observe(.value, with: { (snap) in
            if let data = snap.value as? [String:Any]{
                let pointAnnotation = MyAnnotation()
                let title:String = data["title"] as! String
                //let subtitle:String = data["subtitle"] as! String
                let positionLA = data["userLatitude"] as! CLLocationDegrees
                let positionLO = data["userLongitude"] as! CLLocationDegrees
                self.position = CLLocation(latitude: positionLA, longitude: positionLO)
                self.missionID = data["missionID"] as! String
                pointAnnotation.desc = self.missionID
                pointAnnotation.coordinate = (self.position)!.coordinate
                pointAnnotation.title = title
                pointAnnotation.subtitle = data["missionUser"] as! String
                if((data["status"]as! String == "waiting") || (Auth.auth().currentUser?.email ==  data["missionUser"] as! String && (data["status"]as! String == "moving")) || (Auth.auth().currentUser?.email ==  data["helper"] as! String && (data["status"]as! String == "moving"))){
                    self.mkMap.addAnnotation(pointAnnotation)
                }
            }
        })
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //自定義大頭針樣式
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation)-> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else {
            // 建立可重複使用的 MKPinAnnotationView
            let reuseId = "Pin"
            var pinView =
                mapView.dequeueReusableAnnotationView(
                    withIdentifier: reuseId) as? MKPinAnnotationView
            if pinView == nil {
                // 建立一個大頭針視圖
                pinView = MKPinAnnotationView(
                    annotation: annotation,
                    reuseIdentifier: reuseId)
                // 設置點擊大頭針後額外的視圖
                pinView?.canShowCallout = true
                // 會以落下釘在地圖上的方式出現
                pinView?.animatesDrop = true
                // 大頭針的顏色
                pinView?.pinTintColor = UIColor.blue
                // 這邊將額外視圖的右邊視圖設為一個按鈕
                let calloutButton = UIButton(type: .detailDisclosure)
                if((pinView?.annotation?.title) == "雨具"){
                    calloutButton.setBackgroundImage(UIImage(named: "ca1"), for: UIControlState())
                }else if((pinView?.annotation?.title) == "安全帽"){
                    calloutButton.setBackgroundImage(UIImage(named: "ca3"), for: UIControlState())
                }else if((pinView?.annotation?.title) == "充電設備"){
                    calloutButton.setBackgroundImage(UIImage(named: "ca2"), for: UIControlState())
                }
                
                pinView?.rightCalloutAccessoryView =
                calloutButton
            } else {
                pinView?.annotation = annotation
            }
            return pinView
        }
    }
}
