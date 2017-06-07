//
//  BNSSeachOrderViewController.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView

class BNSSeachOrderViewController: BNSUserBaseUIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var seachTextField: InsetsTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialization()
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

    //MARK: ----------
    func initialization() -> Void {
        self.seachTextField.layer.masksToBounds = true
        self.seachTextField.layer.cornerRadius = 5.0
        self.seachTextField.layer.borderWidth = 1.0
        self.seachTextField.layer.borderColor = UIColor.redColor().CGColor
        self.seachTextField.leftViewMode = .Always
        let imgView = UIImageView.init(image: UIImage.init(named: "smallquary"))
        imgView.frame = CGRectMake(0, 0, 20, 20)
        self.seachTextField.leftView = imgView
        self.seachTextField.insetsLeft = 10
    }
    
    func textRectForBounds(bounds:CGRect) -> CGRect {
        
        var newBounds = CGRect.init(origin: bounds.origin, size: bounds.size)
        newBounds.origin.x += 10
        
        return newBounds
    }
    //MARK: ----------UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 108.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("toManyOrderList", sender: nil)
    }
    
    //MARK: ----------UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdent = "OrderCenterTableViewCellID"
        var cell:BNSOrderCenterTableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdent) as? BNSOrderCenterTableViewCell
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed("OrderCenterTableViewCell", owner: self, options: nil).first as? BNSOrderCenterTableViewCell
        }
        return cell!
    }
    
}





