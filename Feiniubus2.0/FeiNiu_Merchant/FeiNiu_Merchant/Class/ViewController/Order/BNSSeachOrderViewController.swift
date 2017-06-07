//
//  BNSSeachOrderViewController.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView
import FNSwiftNetInterface

class BNSSeachOrderViewController: BNSUserBaseUIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var seachTextField: InsetsTextField!
    @IBOutlet weak var orderIntroduce: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    
    //搜索的航班号
    var flight_number:String = ""
    //数据源
    var tableDataSource:NSMutableArray?{
        didSet{
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let toViewControl = segue.destination
        switch toViewControl.self {
        case is BNSDetailOrderViewController:
            if let detailOrderViewController:BNSDetailOrderViewController = toViewControl as? BNSDetailOrderViewController {
                detailOrderViewController.orderModel = sender as? Order
            }
            break
        default:
            break
        }
    }
 

    //MARK: ----------
    func initialization() -> Void {
        self.seachTextField.layer.masksToBounds = true
        self.seachTextField.layer.cornerRadius = 5.0
        self.seachTextField.layer.borderWidth = 1.0
        self.seachTextField.layer.borderColor = UIColor.red.cgColor
        self.seachTextField.leftViewMode = .always
        let imgView = UIImageView.init(image: UIImage.init(named: "smallquary"))
        imgView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.seachTextField.leftView = imgView
        self.seachTextField.insetsLeft = 10
        self.seachTextField.delegate = self
        
        //请求数据
        self.requestOrderList()
    }
    
    func textRectForBounds(_ bounds:CGRect) -> CGRect {
        
        var newBounds = CGRect.init(origin: bounds.origin, size: bounds.size)
        newBounds.origin.x += 10
        
        return newBounds
    }
    
    func requestOrderList() -> Void {
        //        self.startWait()
        //请求数据
        NetInterfaceManager.shareInstance.sendRequstWithType(EMRequestType.emRequestType_GetOrderCenterList.rawValue) { (params) in
            params.method = .emRequstMethod_GET
            params.data = ["page":1,
                           "take":100,
                           "flight_number":self.flight_number]  as AnyObject
        }
    }
    
    @IBAction func seachClick(_ sender: AnyObject) {
        self.flight_number = self.seachTextField.text! ?? ""
        self.seachTextField.resignFirstResponder()
        self.requestOrderList();
    }
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.seachClick(textField)
        return true
    }
    
    //MARK: ----------UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toDetailOrder", sender:self.tableDataSource![(indexPath as NSIndexPath).row])
    }
    
    //MARK: ----------UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableDataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdent = "OrderCenterTableViewCellID"
        var cell:BNSOrderCenterTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdent) as? BNSOrderCenterTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("OrderCenterTableViewCell", owner: self, options: nil)?.first as? BNSOrderCenterTableViewCell
        }
        let orderInfor:Order = tableDataSource![(indexPath as NSIndexPath).row] as! Order
        //订单人数
        cell?.people_number.text = "人数\(orderInfor.people_number)人"
        //订单姓名
        if orderInfor.contacts!.count > 0 {
            if let contacts:contactsObject = orderInfor.contacts![0]{
                cell?.name.text = contacts.name
            }
        }
        //订单状态
        let switchOrderState = orderInfor.order_state ?? "0"
        switch switchOrderState {
        case "PendingDispatch":
            cell?.order_state.text = "等待派车"
            break
        case "QueuingDispatch":
            cell?.order_state.text = "预约排队"
            break
        case "Dispatched":
            cell?.order_state.text = "预约成功"
            break
        case "Transporting":
            cell?.order_state.text = "接送中"
            break
        case "PendingSettlement":
            cell?.order_state.text = "等待结算"
            break
        case "Completed":
            cell?.order_state.text = "已完成"
            break
        case "Waiting":
            cell?.order_state.text = "等待上车"
            break
        case "DispatchFail":
            cell?.order_state.text = "预约失败"
            break
        case "Cancelled":
            cell?.order_state.text = "已取消"
            break
        default:
            cell?.order_state.text = "未知状态"
        }
        //航班号
        cell?.flight_number.text = "航班号：\(orderInfor.flight_number ?? "")"
        //城市名称
        cell?.city_name.text = orderInfor.city_name
        //接送时间
        cell?.use_time.text = "接送时间：\(orderInfor.use_time ?? "")"
        
        return cell!
    }
    
    //MARK: - http handler
    override func httpRequestFinished(_ notification:Notification){
        super.httpRequestFinished(notification)
        let resultData:NetResultDataModel = notification.object as! NetResultDataModel
        switch resultData.type {
        case EMRequestType.emRequestType_GetOrderCenterList.rawValue:
            let returnData:NSDictionary = resultData.data as! NSDictionary
            //联系人个数
            let total_contacts = returnData["total_contacts"] as? Int ?? 0
            //总价
            let total_price = returnData["total_price"] as? Int ?? 0
            //订单数
            let total_rows = returnData["total_rows"] as? Int ?? 0
            if let dataArray = returnData["data"] {
                tableDataSource = Order.mj_objectArray(withKeyValuesArray: dataArray)
            }
            self.mainTableView.reloadData()
            self.orderIntroduce.text = "你一共有\(total_rows)个订单，\(total_contacts)个联系人，总价共计：\(total_price/100)元"
            break
        default:
            "default"
        }
    }
    override func httpRequestFailed(_ notification:Notification){
        super.httpRequestFailed(notification)
    }
    
}





