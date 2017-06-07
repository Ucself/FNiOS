//
//  BNSRegisterViewController.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSRegisterViewController: BNSUserBaseUIViewController {
    
    let arTitiles = ["选择城市:", "企业名称:", "企业地址:", "营业执照:", "负责人:", "手机号:", "验证码:"]
    
    var txtCity:UITextField?
    var txtConpanyName:UITextField?
    var txtAdress:UITextField?
    var txtLicence:UITextField?
    var txtPICName:UITextField?
    var txtPhone:UITextField?
    var txtAuthCode:UITextField?
    var btnSelFile:UIButton? {
        didSet {
            btnSelFile?.addTarget(self, action: #selector(onButtonClick(_:)), forControlEvents: .TouchUpInside)
        }
    }
    var btnCode:UIButton? {
        didSet {
            btnCode?.addTarget(self, action: #selector(onButtonClick(_:)), forControlEvents: .TouchUpInside)
        }
    }
    
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
    
    func onButtonClick(sender:AnyObject) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 7
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("registerCell", forIndexPath: indexPath)
        
        let labelTitle = cell.viewWithTag(101) as! UILabel
        let textField   = cell.viewWithTag(102) as! UITextField
        let button     = cell.viewWithTag(103) as! UIButton
        
        labelTitle.text = arTitiles[indexPath.row]
        
        switch indexPath.row {
        case 0:
            self.txtCity = textField;
            textField.userInteractionEnabled = false;
            textField.placeholder = "选择您的所在城市";
            button.hidden = true;
        case 1:
            self.txtConpanyName = textField;
            textField.userInteractionEnabled = true;
            textField.placeholder = "营业执照上的工商注册名称";
            button.hidden = true;
        case 2:
            self.txtAdress = textField;
            textField.userInteractionEnabled = true;
            textField.placeholder = "输入您的企业所在地";
            button.hidden = true;
        case 3:
            self.txtLicence = textField;
            textField.userInteractionEnabled = true;
            textField.placeholder = "请选择文件";
            self.btnSelFile = button;
            button.hidden = false;
            button.setTitle("选择文件", forState: .Normal)
        case 4:
            self.txtPICName = textField;
            textField.userInteractionEnabled = true;
            textField.placeholder = "输入姓名";
            button.hidden = true;
        case 5:
            self.txtPhone = textField;
            textField.userInteractionEnabled = true;
            textField.placeholder = "输入手号码";
            button.hidden = true;
        case 6:
            self.txtAuthCode = textField;
            textField.userInteractionEnabled = true;
            textField.placeholder = "输入短信验证码";
            
            self.btnCode = button;
            button.hidden = false;
            button.setTitle("获取验证码", forState: .Normal)
        default:
            "default"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

}
