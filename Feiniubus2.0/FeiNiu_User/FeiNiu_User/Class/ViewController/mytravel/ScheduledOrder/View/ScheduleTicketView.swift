//
//  ScheduleTicketView.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/1.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

protocol ScheduleTicketViewDelegate {
    func scheduleTicketViewOnShareAction(ticket:CommuteOrderObj)
    func scheduleTicketViewOnRefundAction(ticket:CommuteOrderObj)
    func scheduleTicketViewOnComplaintAction(ticket:CommuteOrderObj)
    func scheduleTicketViewOnValidateTicket(ticket:CommuteOrderObj)
}

class ScheduleTicketView: UIView, CircularProgressDelegate {
    
    var delegate:ScheduleTicketViewDelegate?
    var parentController:UIViewController?

    var ticket:CommuteOrderObj?
    
    var photoView:StationPhotoView?

    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var labelOrig: UILabel!
    
    @IBOutlet weak var labelDest: UILabel!
    
    @IBOutlet weak var labelStartTime: UILabel!
    
    @IBOutlet weak var labelEndTime: UILabel!
    
    @IBOutlet weak var labelStartStation: UILabel!
    
    @IBOutlet weak var labelEndStation: UILabel!
    
    @IBOutlet weak var labelCarLicenses: UILabel!

    @IBOutlet weak var circularView: CircularProgressView!
    
    @IBOutlet weak var labelTips: UILabel!
    
    @IBOutlet weak var labelDateTopCons: NSLayoutConstraint!
    
    //新增备注
    @IBOutlet weak var remarkImage: UIImageView!
    @IBOutlet weak var remarkLabel: UILabel!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func awakeFromNib() {
        self.circularView.delegate = self
        self.circularView.backColor = UIColor.white
        self.circularView.progressColor = UIColor_DefOrange
        self.circularView.lineWidth = 2
        
        self.circularView.setCenter(UIImage(named: "fingerprint_orange"))
        
        if deviceHeight < 667 {
            labelDateTopCons.constant = 8
        }
    }
    
    func setTicketStat() {
        
    }
    
    func setTicketData(_ ticket:CommuteOrderObj?) {
        guard let ticket = ticket else { return }
        self.ticket = ticket
        
        self.labelDate.text = DateUtils.formatDate(DateUtils.string(toDate: ticket.ticket_date), format: "yyyy-MM-dd")
        self.labelOrig.text = ticket.start_station_name
        self.labelDest.text = ticket.destination_station_name
        self.labelStartTime.text = DateUtils.formatDate(DateUtils.string(toDate: ticket.on_station_time), format: "HH:mm")
        self.labelEndTime.text = DateUtils.formatDate(DateUtils.string(toDate: ticket.off_station_time), format: "HH:mm")
        self.labelStartStation.text = ticket.on_station_name
        self.labelEndStation.text = ticket.off_station_name
        
        //路线备注
        if self.ticket?.remark == "" {
            self.remarkImage.isHidden = true
            self.remarkLabel.isHidden = true
        }
        else{
            self.remarkImage.isHidden = false
            self.remarkLabel.isHidden = false
            
            self.remarkLabel.text = self.ticket?.remark
        }
        
        if CommuteTicketState(rawValue: ticket.ticket_state) == .Uncheckable {
            self.circularView.setCenter(UIImage(named: "fingerprint"))
            self.circularView.backColor = UIColor.white
            self.circularView.isUserInteractionEnabled = true
            self.labelTips.text = "发车前30分钟可以验票哦~"
            self.circularView.isNeedDraw = false
        }
        else if CommuteTicketState(rawValue: ticket.ticket_state) == .Checked {
            self.circularView.setCenter(UIImage(named: "icon_okay"))
            self.circularView.backColor = UIColor_DefOrange
            self.circularView.isUserInteractionEnabled = false
            self.labelTips.text = "验票成功!"
        }
        else if CommuteTicketState(rawValue: ticket.ticket_state) == .Unchecked {
            self.circularView.setCenter(UIImage(named: "fingerprint_orange"))
            self.circularView.backColor = UIColor.white
            self.circularView.isUserInteractionEnabled = true
            self.labelTips.text = "上车时, 长按指纹处进行验票哦~"
            self.circularView.isNeedDraw = true
        }
        
        if let busArray = ticket.buses {
            var licenses:[String] = []
            for item in busArray.enumerated() {
                if let bus:busInforObj = item.element as? busInforObj {
                    if bus.license != nil {
                        licenses.append(bus.license ?? "")
                    }
                }
            }
            
            let string = licenses.joined(separator:", ")
            self.labelCarLicenses.text = string
        }
    }
    
    func getPhotoView() -> StationPhotoView {
        if self.photoView == nil {
            self.photoView = Bundle.main.loadNibNamed("StationPhotoView", owner: self, options: nil)?.first as? StationPhotoView
        }
        
        return self.photoView!
    }
    
    //MARK: - Action
    @IBAction func btnMoreClick(_ sender: Any) {
        let btn:UIButton = sender as! UIButton
        
        let popoverMenu:PopoverMenu = PopoverMenu()
        let point:CGPoint = CGPoint(x: btn.frame.maxX, y: btn.frame.maxY + 44+30)
        let item1:MenuItem = MenuItem(text: "分享线路", image: UIImage(named: "icon_share_line"))
        
        var item2:MenuItem?
        
        if self.ticket?.is_refundable == true {
            //预约成功可退票
            item2 = MenuItem(text: "退票", image: UIImage(named: "icon_tuipiao"))
        }
        else {
            item2 = MenuItem(text: "投诉", image: UIImage(named: "icon_complaint"))
        }
        popoverMenu.show(at: point, in: self.parentController?.view, items: [item1, item2!])
        
        popoverMenu.selectHandler = { (index) -> () in
            if index == 0 {
                self.onShareAction()
            }
            else if index == 1 {
                if self.ticket?.is_refundable == true {
                    self.onRefundAction()
                }
                else {
                    self.onCompliantAction()
                }
                
            }
        }
    }

    @IBAction func btnLookStartStationClick(_ sender: Any) {
        let view = self.getPhotoView()
        view.labelTitle.text = self.ticket?.on_station_name
        view.labelDetail.text = self.ticket?.on_station_address
        if let url = self.ticket?.on_station_image_uri {
            //view.imageView.sd_setImage(with: URL(string: url))
            view.imageView.setImageWith(URL(string: url))
        }
        
        let superC = self.delegate as! UIViewController
        view.showIn(superC.view)
    }
    
    @IBAction func btnLookEndStationClick(_ sender: Any) {
        let view = self.getPhotoView()
        view.labelTitle.text = self.ticket?.off_station_name
        view.labelDetail.text = self.ticket?.off_station_address
        if let url = self.ticket?.off_station_image_uri {
            //view.imageView.sd_setImage(with: URL(string: url))
            view.imageView.setImageWith(URL(string: url))
        }
        let superC = self.delegate as! UIViewController
        view.showIn(superC.view)
    }

    
    func onShareAction() {
        if self.delegate != nil {
            self.delegate?.scheduleTicketViewOnShareAction(ticket: self.ticket!)
        }
    }
    
    func onRefundAction() {
        if self.delegate != nil {
            self.delegate?.scheduleTicketViewOnRefundAction(ticket: self.ticket!)
        }
    }
    
    func onCompliantAction() {
        if self.delegate != nil {
            self.delegate?.scheduleTicketViewOnComplaintAction(ticket: self.ticket!)
        }
    }
    
    //MARK: -
    func circularProgressViewDidFinished(_ circularProgressView: CircularProgressView!) {
        
        if self.delegate != nil {
            self.delegate?.scheduleTicketViewOnValidateTicket(ticket: self.ticket!)
        }
    }
    
    func circularProgressViewDidCancel() {
        
    }

}
