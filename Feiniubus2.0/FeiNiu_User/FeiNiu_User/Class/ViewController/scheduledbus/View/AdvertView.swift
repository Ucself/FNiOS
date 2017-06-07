//
//  AdvertView.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 2017/3/21.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit

class AdvertView: UIView,UIScrollViewDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //数据
    var dataArray:Array<Any>?
    //点击回调
    typealias callbackFunc = (_ clickIndex:Int ) -> Void
    var clickCallback:callbackFunc?
    
    //控件
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var parentView:UIView?

    @IBAction func buttonClick(_ sender: Any) {
        self.hideInView()
    }
    
    @IBAction func scrollViewClick(_ sender: Any) {
        
        if self.clickCallback != nil {
            self.clickCallback!(self.pageControl.currentPage)
        }
        
        self.hideInView()
    }
    
    
    
    static func initWithDataArray(dataArray:Array<Any>) -> AdvertView {
        
        let advertView:AdvertView = Bundle.main.loadNibNamed("AdvertView", owner: self, options: nil)?.first as! AdvertView
        advertView.dataArray = dataArray
        advertView.scrollView.delegate = advertView;
        advertView.pageControl.numberOfPages = dataArray.count
        return advertView
    }
    
    func showInView(parentView:UIView) -> Void {

        self.alpha = 0;
        self.parentView = parentView
        self.parentView?.addSubview(self)
        self.frame = parentView.bounds
//        self.snp.makeConstraints { (make) in
//            make.edges.equalTo(parentView.snp.edges)
//        }
        
        let containerCount = dataArray?.count ?? 0
        let containerWidth:CGFloat = (deviceWidth - 60.0) * CGFloat(containerCount)
        let containerHeight:CGFloat = (deviceWidth - 60.0) * 85.0/65.0
        self.scrollView.contentSize = CGSize.init(width: containerWidth, height: containerHeight)
        
        for i in 0..<containerCount {
            let image:UIImageView = UIImageView.init(frame: CGRect.init(x: (deviceWidth - 60.0) * CGFloat(i), y: 0, width: (deviceWidth - 60.0), height: containerHeight))
            
            //放图片
            if let dicInfor:Dictionary<String,Any> = self.dataArray![i] as? Dictionary<String,Any>{
                //image.sd_setImage(with: URL.init(string: dicInfor["image_url"] ?? ""), placeholderImage: UIImage.init(named: "pic"))
                image.setImageWith(URL.init(string: (dicInfor["banner_min_image"] != nil) ? dicInfor["banner_min_image"] as! String : ""), placeholderImage: UIImage.init(named: "pic"))
            }
            
            self.scrollView.addSubview(image)
        }
        
        //数据为1个的时候不需要显示分页
        if let nowDataArray = self.dataArray {
            if nowDataArray.count <= 1 {
                self.pageControl.isHidden = true
            }
            else{
                self.pageControl.isHidden = false
            }
            
        }
        else {
            self.pageControl.isHidden = false
        }
        
        
        UIView.transition(with: self, duration: 0.8, options: .curveEaseInOut, animations: {
            self.alpha = 1;
        }, completion: nil)
    }
    func hideInView() -> Void {
        self.removeFromSuperview()
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)  {
        
        self.pageControl.currentPage = Int(self.scrollView.contentOffset.x/(deviceWidth - 60.0))
        
    }
}
