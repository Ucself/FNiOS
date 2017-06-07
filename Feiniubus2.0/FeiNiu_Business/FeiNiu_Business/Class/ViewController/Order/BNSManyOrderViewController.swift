//
//  BNSManyOrderViewController.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSManyOrderViewController: BNSUserBaseUIViewController {

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
    //MARK: ----------UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 165.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toDetailOrder", sender: nil)
    }
    
    //MARK: ----------UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdent = "manyorderCell"
        var cell:BNSManyOrderTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdent) as? BNSManyOrderTableViewCell
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed("ManyOrderTableViewCell", owner: self, options: nil).first as? BNSManyOrderTableViewCell
        }
        return cell!
    }
}
