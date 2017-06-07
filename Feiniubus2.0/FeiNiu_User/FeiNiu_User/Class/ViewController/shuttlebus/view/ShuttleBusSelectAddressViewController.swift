//
//  ShuttleBusSelectAddressViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/10/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ShuttleBusSelectAddressViewController: UserBaseUIViewController, MAMapViewDelegate, AMapLocationManagerDelegate {

    @IBOutlet weak var parentMapView: UIView!
    
    var mapView:MAMapView!
    var completionBlock: AMapLocatingCompletionBlock!
    var locationManager: AMapLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initInterface()
        // Do any additional setup after loading the view.
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
    func initInterface() -> Void {
        //地图初始化
        mapView = MAMapView.init()
        mapView.delegate = self
        parentMapView.addSubview(mapView)
//        mapView.snp.makeConstraints { (maker) in
//            maker.edges.equalTo(parentMapView)
//        }
        mapView.mas_makeConstraints { (maker) in
            maker!.edges.equalTo()(self.parentMapView)
        }
        //定位对象
        locationManager = AMapLocationManager()
        //定位回调
        self.initCompleteBlock()
        //定位一次
        self.locAction()
    }
    func initCompleteBlock() {
        
        completionBlock = { [weak self] (location: CLLocation?, regeocode: AMapLocationReGeocode?, error: Error?) in
            
            if let error = error {
                let error = error as NSError
                NSLog("locError:{\(error.code) - \(error.localizedDescription)};")
                
                if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                    return;
                }
            }
            
            if let location = location {
                let annotation = MAPointAnnotation()
                annotation.coordinate = location.coordinate
                
                if let regeocode = regeocode {
                    annotation.title = regeocode.formattedAddress
                    annotation.subtitle = "\(regeocode.citycode!)-\(regeocode.adcode!)-\(location.horizontalAccuracy)m"
                }
                else {
                    annotation.title = String(format: "lat:%.6f;lon:%.6f;", arguments: [location.coordinate.latitude, location.coordinate.longitude])
                    annotation.subtitle = "accuracy:\(location.horizontalAccuracy)m"
                }
                
                self?.addAnnotationsToMapView(annotation)
            }
            
        }
    }
    func addAnnotationsToMapView(_ annotation: MAAnnotation) {
        mapView.addAnnotation(annotation)
        
        mapView.selectAnnotation(annotation, animated: true)
        mapView.setZoomLevel(15.1, animated: false)
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    func locAction() -> Void {
//        self.mapView.removeAnnotation(self.mapView.annotations as! MAAnnotation!)
        self.locationManager.requestLocation(withReGeocode: false, completionBlock: completionBlock)
    }
    // MARK: - user Action
    @IBAction func toSeachAddressClick(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toSeachAddress", sender: nil)
    }
    
    @IBAction func locationClick(_ sender: AnyObject) {
        self.locAction()
    }
    //MARK: - MAMapVie Delegate
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAPointAnnotation {
            let pointReuseIndetifier = "pointReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as? MAPinAnnotationView
            
            if annotationView == nil {
                annotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView?.canShowCallout  = true
            annotationView?.animatesDrop    = true
            annotationView?.isDraggable     = false
            annotationView?.pinColor        = .purple
            
            return annotationView
        }
        
        return nil
    }
}
