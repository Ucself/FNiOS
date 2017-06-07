//
//  ShuttleBusOrderStatusViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/10/11.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ShuttleBusOrderStatusViewController: UserBaseUIViewController {

    
    @IBOutlet weak var starView: ShuttleBusRatingBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        starView.setImageDeselected("icon_star_hui", halfSelected: "icon_star_0.5", fullSelected: "icon_star_cheng", andDelegate: nil)
        starView.setRating(1.5)
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
