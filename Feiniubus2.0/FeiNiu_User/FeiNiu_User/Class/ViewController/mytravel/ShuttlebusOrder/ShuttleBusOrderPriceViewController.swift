//
//  ShuttleBusOrderDetailViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/10/13.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ShuttleBusOrderPriceViewController: UserBaseUIViewController,UITableViewDelegate,UITableViewDataSource {

    //包含：一口价 总价
    var dataSourceArray:Array<Any>?
    var payPrice:Double = 0
    
    //支付价格
    var headView:ShuttleBusOrderPriceViewHead?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //TableView 头部
        let orderPriceViewHead:ShuttleBusOrderPriceViewHead = (Bundle.main.loadNibNamed("ShuttleBusOrderPriceViewHead", owner: self, options: nil))?[0] as! ShuttleBusOrderPriceViewHead
        orderPriceViewHead.payPrice.text = "¥\(String(format: "%.2f", payPrice/100))"
        self.headView = orderPriceViewHead
        
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
    
    @IBAction func valuationRulesClick(_ sender: Any) {
        let webViewController:WebContentViewController = WebContentViewController.instance(withStoryboardName: "Me")
        webViewController.vcTitle = "常见问题帮助"
        webViewController.urlString = HTMLAddr_CallFeiniuRule 
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view:UIView?
        
        switch section {
        case 0:
            view = self.headView
        default:
            let tempView = UIView.init()
            tempView.backgroundColor = UIColor.clear
            view = tempView
        }
        return view!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 28
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headHeight:CGFloat = 0
        switch section {
        case 0:
            headHeight = 84
        default:
            headHeight = 14
        }
        return headHeight
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSourceArray == nil ? 0 : (self.dataSourceArray?.count)!
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCellId")
        let tempDic:NSDictionary = dataSourceArray![indexPath.row] as! NSDictionary
        //名称Label
        let nameLabel:UILabel = cell?.viewWithTag(101) as! UILabel
        //价格Label
        let priceLabel:UILabel = cell?.viewWithTag(102) as! UILabel
        
        if let name =  tempDic["name"] as? String{
            //名称
            nameLabel.text = name
            //值
            if let price:Double =  tempDic["price"] as? Double {
                switch name {
                case "拼车起步价":
                    priceLabel.text = String(format: "¥%.2f", price/100)
                case "拼车单价":
                    priceLabel.text = String(format: "¥%.2f/人", price/100)
                case "人数":
                    priceLabel.text = String(format: "%.0f人", price)
                case "总计","总价":
                    priceLabel.text = String(format: "¥%.2f", price/100)
                    //如果没有传入价格显示总价
                    if self.payPrice == 0 {
                        self.headView?.payPrice.text = "¥\(String(format: "%.2f", price/100))"
                    }
                default:
                    priceLabel.text = String(format: "¥%.2f", price/100)
                }
            }
        }
        
        
        
        return cell!
    }

}
