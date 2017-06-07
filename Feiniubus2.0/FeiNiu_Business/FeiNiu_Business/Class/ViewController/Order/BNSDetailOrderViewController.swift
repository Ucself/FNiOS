//
//  BNSDetailOrderViewController.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSDetailOrderViewController: BNSUserBaseUIViewController,UITableViewDelegate,UITableViewDataSource {

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
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 145
        case 1:
            return 125
        case 2:
            return 168
        default:
            return 120
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("detailOrderStatusCell")
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("detailOrderCarInfoCell")
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("detailOrderPassengerCell")
        default:
            cell = UITableViewCell()
        }
        return cell!;
    }
    
    // MARK: - actions
   
    @IBAction func btnPayClick(sender: AnyObject) {
        self.performSegueWithIdentifier("toPayment", sender: nil)
    }
    
    @IBAction func btnCancelClick(sender: AnyObject) {
    }
    
}
