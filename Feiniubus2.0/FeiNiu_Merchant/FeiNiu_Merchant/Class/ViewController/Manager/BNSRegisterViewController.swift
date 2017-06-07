//
//  BNSRegisterViewController.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNSwiftNetInterface
import FNUIView

class BNSRegisterViewController: BNSUserBaseUIViewController,UITableViewDataSource,UITableViewDelegate,SelectViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let arTitiles = ["选择城市:", "企业名称:", "企业地址:", "营业执照:", "负责人:", "手机号:", "验证码:"]
    var requestDic:NSMutableDictionary = [:]
    
    var txtCity:UITextField?
    var txtConpanyName:UITextField?
    var txtAdress:UITextField?
    var txtLicence:UITextField?
    var txtPICName:UITextField?
    var txtPhone:UITextField?
    var txtAuthCode:UITextField?
    var btnSelFile:UIButton? {
        didSet {
            btnSelFile?.addTarget(self, action: #selector(onButtonClick(_:)), for: .touchUpInside)
            btnSelFile?.tag = 1001
        }
    }
    var btnCode:UIButton? {
        didSet {
            btnCode?.addTarget(self, action: #selector(onButtonClick(_:)), for: .touchUpInside)
            btnCode?.tag = 1002
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initInterface()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //需要使用的控件
    var imagePicker : UIImagePickerController? {
        didSet{
            imagePicker!.delegate = self
        }
    }
    var selectImage:SelectView?

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

    @IBAction func onBtnSubmitClick(_ sender: AnyObject) {
        guard  self.validationMerchantData() else {
            return
        }
        self.startWait()
        NetInterfaceManager.shareInstance.sendRequstWithType(EMRequestType.emRequestType_PostRegistered.rawValue) { (params) in
            params.method = EMRequstMethod.emRequstMethod_POST
            params.data = self.requestDic
        }
        
    }
    
    func onButtonClick(_ sender:AnyObject) {
        //取消键盘
        self.cancelTheKeyboard()
        let tempButton:UIButton = sender as! UIButton
        switch tempButton.tag {
        case 1001:
            selectImage = SelectView.init()
            selectImage!.labelTitle.text = "选择文件";
            selectImage!.btn1.setTitle("拍照", for:UIControlState())
            selectImage!.btn2.setTitle("本地图片", for:UIControlState())
            selectImage!.show(in: self.view)
            selectImage!.delegate = self
        case 1002:
            let phoneNum = txtPhone?.text ?? ""
            if phoneNum.isEmpty {
                self.showTipsView("请输入正确的手机号")
                break
            }
            self.startWait()
            NetInterfaceManager.shareInstance.sendRequstWithType(EMRequestType.emRequestType_GetVerifyCode.rawValue, block: { (params) in
                params.method = EMRequstMethod.emRequstMethod_GET
                params.data = ["phone":phoneNum]  as AnyObject
            })
            
            if let timeButton:TimerButton = tempButton as? TimerButton {
                timeButton.startTimer(withInitialCount: 60)
            }
        default:
            break
        }
    }
    
    func initInterface() -> Void {
    }
    
    //验证数据
    func validationMerchantData() -> Bool {
        requestDic.setObject(self.txtAuthCode?.text ?? "", forKey: "token" as NSCopying)
        requestDic.setObject(self.txtConpanyName?.text ?? "", forKey: "name" as NSCopying)
        requestDic.setObject(self.txtPICName?.text ?? "", forKey: "contact" as NSCopying)
        requestDic.setObject(self.txtPhone?.text ?? "", forKey: "phone" as NSCopying)
        requestDic.setObject(self.txtAdress?.text ?? "", forKey: "address" as NSCopying)
        //adcode 与 file 在选择的时候赋值
        
        //验证码
        let token = requestDic.object(forKey: "token") as? String ?? ""
        if(token.isEmpty){
            self.showTipsView("请输入验证码")
            return false
        }
        //adcode
        let adcode = requestDic.object(forKey: "adcode") as? String ?? ""
        if(adcode.isEmpty){
            self.showTipsView("请选择城市")
            return false
        }
        //企业名称
        let name = requestDic.object(forKey: "name") as? String ?? ""
        if(name.isEmpty){
            self.showTipsView("请输入企业名称")
            return false
        }
        //负责人
        let contact = requestDic.object(forKey: "contact") as? String ?? ""
        if(contact.isEmpty){
            self.showTipsView("请输入负责人姓名")
            return false
        }
        //电话号码
        let phone = requestDic.object(forKey: "phone") as? String ?? ""
        if(phone.isEmpty){
            self.showTipsView("请输入电话号码")
            return false
        }
        //企业地址
        let address = requestDic.object(forKey: "address") as? String ?? ""
        if(address.isEmpty){
            self.showTipsView("请输入企业地址")
            return false
        }
        //上传的图片
        if requestDic.object(forKey: "file") == nil {
            self.showTipsView("请输入选择文件")
            return false
        }
        
        return true
    }
    
    //取消输入框焦点
    func cancelTheKeyboard() -> Void {
        self.txtCity?.resignFirstResponder()
        self.txtConpanyName?.resignFirstResponder()
        self.txtAdress?.resignFirstResponder()
        self.txtLicence?.resignFirstResponder()
        self.txtPICName?.resignFirstResponder()
        self.txtPhone?.resignFirstResponder()
        self.txtAuthCode?.resignFirstResponder()
    }
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "registerCell", for: indexPath)
        
        let labelTitle = cell.viewWithTag(101) as! UILabel
        let textField   = cell.viewWithTag(102) as! UITextField
        let button     = cell.viewWithTag(103) as! UIButton
        
        labelTitle.text = arTitiles[(indexPath as NSIndexPath).row]
        
        switch (indexPath as NSIndexPath).row {
        case 0:
            self.txtCity = textField;
            textField.isUserInteractionEnabled = false;
            textField.placeholder = "选择您的所在城市";
            button.isHidden = true;
        case 1:
            self.txtConpanyName = textField;
            textField.isUserInteractionEnabled = true;
            textField.placeholder = "营业执照上的工商注册名称";
            button.isHidden = true;
        case 2:
            self.txtAdress = textField;
            textField.isUserInteractionEnabled = true;
            textField.placeholder = "输入您的企业所在地";
            button.isHidden = true;
        case 3:
            self.txtLicence = textField;
            textField.isUserInteractionEnabled = false;
            textField.placeholder = "请选择文件";
            self.btnSelFile = button;
            button.isHidden = false;
            button.setTitle("选择文件", for: UIControlState())
        case 4:
            self.txtPICName = textField;
            textField.isUserInteractionEnabled = true;
            textField.placeholder = "输入姓名";
            button.isHidden = true;
        case 5:
            self.txtPhone = textField;
            textField.isUserInteractionEnabled = true;
            textField.placeholder = "输入手号码";
            textField.keyboardType = UIKeyboardType.numberPad
            button.isHidden = true;
        case 6:
            self.txtAuthCode = textField;
            textField.isUserInteractionEnabled = true;
            textField.placeholder = "输入短信验证码";
            textField.keyboardType = UIKeyboardType.numberPad
            self.btnCode = button;
            button.isHidden = false;
            button.setTitle("获取验证码", for: UIControlState())
        default:
            "default"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath as NSIndexPath).row {
        case 0:
            self.cancelTheKeyboard()
            self.startWait();
            NetInterfaceManager.shareInstance.sendRequstWithType(EMRequestType.emRequestType_GetCityOpen.rawValue, block: { (params) in
                params.method = EMRequstMethod.emRequstMethod_GET
            })
            break
        default:
            "default"
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.cancelTheKeyboard()
    }
    
    //MARK: - SelectViewDelegate
    func selectView(_ index: Int32) {
        if imagePicker == nil {
            imagePicker = UIImagePickerController.init()
        }
        switch index {
        case 0:
            //拍照功能
            let isCameraSupport = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            if isCameraSupport {
                imagePicker!.sourceType = UIImagePickerControllerSourceType.camera
            }
            
        case 1:
            imagePicker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
            break
        default:
            break
        }
    
        self.present(imagePicker!, animated: true) {
            //消失选择框
            self.selectImage?.cancelSelect(self.view)
        }
    }
    func selectViewCancel() {
        
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let newImage = info["UIImagePickerControllerOriginalImage"] as! UIImage
        let imageData = UIImageJPEGRepresentation(newImage,0.5)
        let encodedImageStr = "data:image/jpeg;base64, " + (imageData?.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) ?? "")
        self.txtLicence?.text = "\\:file"
        self.requestDic.setObject(encodedImageStr, forKey: "file" as NSCopying)
        //消失图片选择框
        picker.dismiss(animated: true) {
            
        }
    }
    
    
    //MARK: - http handler
    override func httpRequestFinished(_ notification:Notification){
        super.httpRequestFinished(notification)
        let resultData:NetResultDataModel = notification.object as! NetResultDataModel
        switch resultData.type {
        case EMRequestType.emRequestType_GetCityOpen.rawValue:
            self.stopWait()
            var itemArray:[String] = []
            let dataArray = resultData.data as! NSArray
            for item in dataArray {
                itemArray.append((item as! NSDictionary)["city_name"] as! String)
            }
            SelectPickerView.show(in: self.view, items: itemArray, select: 0, completion: { (index) in
                self.txtCity?.text = itemArray[index]
                let adcode = (dataArray[index] as! NSDictionary)["adcode"] as? String ?? ""
                self.requestDic.setObject(adcode, forKey: "adcode" as NSCopying)
                
            })
        case EMRequestType.emRequestType_GetVerifyCode.rawValue:
            self.stopWait()
            self.showTipsView("验证码发送成功")
        case EMRequestType.emRequestType_PostRegistered.rawValue:
            self.stopWait()
            self.showTips("申请成功，请联系管理员审核", type: FNTipTypeWarning)
            self.dismiss(animated: true, completion: {
                
            })
        default:
            "default"
        }
    }
    override func httpRequestFailed(_ notification:Notification){
        super.httpRequestFailed(notification)
    }

}
