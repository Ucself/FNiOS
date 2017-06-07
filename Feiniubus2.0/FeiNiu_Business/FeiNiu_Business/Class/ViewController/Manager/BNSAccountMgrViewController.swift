//
//  BNSAccountMgrViewController.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSAccountMgrViewController: BNSUserBaseUIViewController {
    
    

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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnTestClick(sender: AnyObject) {
        let loginController = BNSLoginViewController.instanceWithStoryboardName("Manager")
        self.navigationController?.pushViewController(loginController, animated: true)
    }
}
