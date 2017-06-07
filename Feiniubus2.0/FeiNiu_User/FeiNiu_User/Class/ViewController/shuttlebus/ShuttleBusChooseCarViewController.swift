//
//  ShuttleBusChooseCarViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/9/29.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ShuttleBusChooseCarViewController: UserBaseUIViewController {

    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeInterface()
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
    
    // MARK: - Navigation
    func initializeInterface() {
        //确认用车按钮
        self.confirmButton.layer.masksToBounds = true
        self.confirmButton.layer.cornerRadius = 22.5
        self.confirmButton.layer.borderWidth = 1
        self.confirmButton.layer.borderColor = UIColorFromRGB(0xFE6E00).cgColor
    }

}
