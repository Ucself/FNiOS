//
//  ScheduleSeachViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ScheduleSearchViewController: UserBaseUIViewController, FNSearchViewControllerDelegate {
    
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var endView: UIView!
    @IBOutlet weak var startText: UITextField!
    @IBOutlet weak var endText: UITextField!

    @IBOutlet weak var statrtViewTopCons: NSLayoutConstraint!
    @IBOutlet weak var endViewTopCons: NSLayoutConstraint!
    
    
    var bChanged:Bool = false
    var bSelectedStart:Bool = false
    
    var startLocation:FNLocation?
    var endLocation:FNLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    //MARK: - Action

    @IBAction func btnChangeClick(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            
            let constant: CGFloat = self.statrtViewTopCons.constant
            self.statrtViewTopCons.constant = self.endViewTopCons.constant
            self.endViewTopCons.constant = constant
            
            self.view.layoutIfNeeded()
            
        }, completion: { (result:Bool) in
            
            self.bChanged = !self.bChanged
            if self.bChanged {
                self.startText.placeholder = "您要去哪儿?"
                self.endText.placeholder = "在哪儿上车?"
            }
            else {
                self.startText.placeholder = "在哪儿上车?"
                self.endText.placeholder = "您要去哪儿?"
            }
            
//            let text = self.startText.text
//            self.startText.text = self.endText.text
//            self.endText.text = text
        })
        
        
    }

    @IBAction func btnSearchClick(_ sender: Any) {
        
        if self.startLocation == nil || self.endLocation == nil {
            self.showTip("请选择上车点或者下车点", with: FNTipTypeFailure)
            return
        }
        
        let controller:ScheduleSearchResultViewController = ScheduleSearchResultViewController.instance(withStoryboardName: "ScheduledBus")
        
        var requestParameter:SearchParameterStruct = SearchParameterStruct()
        
        if CityInfoCache.sharedInstance().commuteCurCity != nil {
            requestParameter.adcode = CityInfoCache.sharedInstance().commuteCurCity.adcode ?? ""
        }
        
        if bChanged {
            requestParameter.from = self.endText.text
            requestParameter.to = self.startText.text
            requestParameter.onlatitude = self.endLocation?.latitude ?? 0
            requestParameter.onlongitude = self.endLocation?.longitude ?? 0
            requestParameter.offlatitude = self.startLocation?.latitude ?? 0
            requestParameter.offlongitude = self.startLocation?.longitude ?? 0
        }
        else{
            requestParameter.from = self.startText.text
            requestParameter.to = self.endText.text
            requestParameter.onlatitude = self.startLocation?.latitude ?? 0
            requestParameter.onlongitude = self.startLocation?.longitude ?? 0
            requestParameter.offlatitude = self.endLocation?.latitude ?? 0
            requestParameter.offlongitude = self.endLocation?.longitude ?? 0
        }
        
        //设置数据
        controller.requestParameter = requestParameter
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func startViewClick(_ sender: Any) {
        self.bSelectedStart = true
        self.gotoSearchMapViewController()
    }
    
    @IBAction func endViewClick(_ sender: Any) {
        self.bSelectedStart = false
        self.gotoSearchMapViewController()
    }
    
    func gotoSearchMapViewController() {
        let searchController:FNSearchViewController  = FNSearchViewController.instance(withStoryboardName: "ShuttleBus")
        searchController.fnSearchDelegate = self
        searchController.isShuttleBus = false;
        
        if self.bChanged {
            self.bSelectedStart = !self.bSelectedStart
        }
        
        if self.bSelectedStart {
            searchController.navTitle = "选择上车地点";
        }
        else {
            searchController.navTitle = "选择下车地点";
        }
        self.navigationController?.pushViewController(searchController, animated: true)
        
        
        
//        let controller:FNSearchMapViewController = FNSearchMapViewController.instance(withStoryboardName: "ShuttleBus")
//        controller.fnMapSearchDelegate = self;
//        controller.isShuttleBus = false
//        
//        if self.bChanged {
//            self.bSelectedStart = !self.bSelectedStart
//        }
//        
//        if self.bSelectedStart {
//            controller.type = 2;
//        }
//        else {
//            controller.type = 1;
//        }
//        
//        if let city:CityObj = CityInfoCache.sharedInstance().commuteCurCity {
//            controller.adcode = city.adcode
//            controller.coordinate = CLLocationCoordinate2D(latitude: city.central_latitude, longitude: city.central_longitude)
//        }
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func searchViewController(_ searchViewController: FNSearchViewController!, didSelect location: FNLocation!) {
        
        if let selLocation = location {
            if self.bChanged {
                self.bSelectedStart = !self.bSelectedStart
            }
            
            if bSelectedStart {
                self.startText.text = selLocation.name
                self.startLocation = selLocation
            }
            else {
                self.endText.text = selLocation.name
                self.endLocation = selLocation
            }
            
        }
    }
    
}
