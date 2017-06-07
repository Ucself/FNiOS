//
//  CouponsViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/20.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CouponsViewController.h"
#import <FNUIView/UIColor+Hex.h>
#import <FNUIView/MJRefresh.h>
#import "String+Price.h"
#import "FeiNiu_User-Swift.h"


@interface CouponCell()

@property (weak, nonatomic) IBOutlet UIImageView *headIcon;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *couponImage;

@end
@implementation CouponCell
- (void)awakeFromNib{
    [super awakeFromNib];
}

-(void)setCouponCell:(CouponObj*)coupon{

    //车类型
    if ([coupon.btype isEqualToString:@"Commute"]) {
        self.couponImage.image = [UIImage imageNamed:@"icon_tongqin"];
    }
    else if([coupon.btype isEqualToString:@"Carpool"]) {
        self.couponImage.image = [UIImage imageNamed:@"icon_pinche"];
    }
    else if([coupon.btype isEqualToString:@"Chartered"]) {
        self.couponImage.image = [UIImage imageNamed:@"icon_baoche"];
    }
    
    self.couponTypeLabel.text = coupon.name;
    //卷类型
    if ([coupon.kind isEqualToString:@"Cash"]) {    //定额优惠现金卷
        //定额优惠现金卷
        self.priceLabel.text = [[NSString alloc] initWithFormat:@"¥ %@",[NSString calculatePriceNO:coupon.value]];
        MyRange *peopleCountFontRange = [[MyRange alloc]initWithContent:0 length:1];
        self.priceLabel.attributedText = [NSString hintStringFontSize:self.priceLabel.text rangs:[@[peopleCountFontRange] mutableCopy] defaultFontSize:[UIFont systemFontOfSize:22] changeFontSize:[UIFont systemFontOfSize:11]];
    }
    else if ([coupon.kind isEqualToString:@"Fixed"]) {      //定额支付卷
        self.priceLabel.text = [[NSString alloc] initWithFormat:@"¥ %@",[NSString calculatePriceNO:coupon.value]];
        MyRange *peopleCountFontRange = [[MyRange alloc]initWithContent:0 length:1];
        self.priceLabel.attributedText = [NSString hintStringFontSize:self.priceLabel.text rangs:[@[peopleCountFontRange] mutableCopy] defaultFontSize:[UIFont systemFontOfSize:22] changeFontSize:[UIFont systemFontOfSize:11]];
    }
    else {      //折扣卷
        self.priceLabel.text = [[NSString alloc] initWithFormat:@"%ld折",(coupon.value/100)];
        MyRange *peopleCountFontRange = [[MyRange alloc]initWithContent:self.priceLabel.text.length - 1 length:1];
        self.priceLabel.attributedText = [NSString hintStringFontSize:self.priceLabel.text rangs:[@[peopleCountFontRange] mutableCopy] defaultFontSize:[UIFont systemFontOfSize:22 weight:UIFontWeightMedium] changeFontSize:[UIFont systemFontOfSize:11]];
    }
    
    
    //有效期
    NSDate *expiryDate = [DateUtils dateFromString:coupon.expire_at format:@"yyyy-MM-dd HH:mm:ss"];
    self.dateLabel.text = [DateUtils formatDate:expiryDate format:@"有效期至yyyy.MM.dd"];
    //优惠卷描述，先移除再添加
    for (UIView *view in self.subviews) {
        if (view.tag == 7843) {
            [view removeFromSuperview];
        }
    }
    for (int i=0; i < coupon.content.count; i++) {
        UILabel *desLabel = [[UILabel alloc] init];
        desLabel.textColor = UITextColor_DarkGray;
        desLabel.font = [UIFont systemFontOfSize:11];
        desLabel.text = [[NSString alloc] initWithFormat:@"%d.%@", i+1 ,coupon.content[i]];
        desLabel.tag = 7843;
        //布局
        [self addSubview:desLabel];
        [desLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.dateLabel);
            make.bottom.equalTo(self.dateLabel).offset( 16 + 16*i);
        }];
    }
}
@end


@interface CouponsViewController ()<UITableViewDelegate>{
    NSInteger   _page;
    NSInteger   _rows;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noCouponView;

@end

@implementation CouponsViewController

+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Me" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"CouponsViewController"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _rows = 10;_page = 1;
    //配置刷新功能
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self request];
    }];
    self.tableView.header.automaticallyChangeAlpha = YES;
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _page++;
        [self request];
    }];

    [self startWait];
    [self request];
    
    //    self.coupons = [[NSArray alloc] initWithObjects:[[CouponObj alloc] init], nil];
    //刷新界面
    //    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    self.selectedCouponsCallback = nil;
}
-(void)updateUI{
    self.noCouponView.hidden = self.coupons.count != 0;
    [self.tableView reloadData];
}

#pragma mark - Request Methods
-(void)request{
     if (self.couponsParams) {
         [NetManagerInstance sendRequstWithType:EmRequestType_CouponList params:^(NetParams *params) {
             params.method = EMRequstMethod_POST;
             NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.couponsParams];
             [dict setObject:@(_page) forKey:@"page"];
             [dict setObject:@(_rows) forKey:@"take"];
             params.data = dict;
         }];
     }
     else {
         [NetManagerInstance sendRequstWithType:EmRequestType_CouponAll params:^(NetParams *params) {
             params.data = @{@"page": @(_page),
                             @"take": @(_rows)};
         }];
     }
}

////请求购买选择优惠卷
//-(void)requestBuySelectCoupons{
//    
//    if (self.couponsParams) {
//        [self startWait];
//        [NetManagerInstance sendRequstWithType:EmRequestType_CouponList params:^(NetParams *params) {
//            params.data = self.couponsParams;
//        }];
//    }
//    
//}
//
////请求分页优惠卷
//- (void)requestAllCoupons:(BOOL)isFirstRequest{
//    //第一次需要加载框
//    if (isFirstRequest) {
//        [self startWait];
//    }
//    
//    [NetManagerInstance sendRequstWithType:EmRequestType_CouponAll params:^(NetParams *params) {
//        params.data = @{@"page": @(_page),
//                        @"take": @(_rows)};
//    }];
//}

#pragma mark- uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coupons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CouponCell *cell = [tableView dequeueReusableCellWithIdentifier:@"couponCell"];
    [cell setCouponCell:(self.coupons[indexPath.row])];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.selectedCouponsCallback) {
        CouponObj *coupon = self.coupons[indexPath.row];
        if ([coupon.id isEqualToString:self.selectedCoupon.id]) {
            self.selectedCouponsCallback(nil);
        }else{
            self.selectedCouponsCallback(self.coupons[indexPath.row]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification {
    
    [super httpRequestFinished:notification];
    [self stopWait];
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    
    ResultDataModel *result = (ResultDataModel *)notification.object;
    if (result.type == EmRequestType_CouponAll || result.type == EmRequestType_CouponList) {
        
        NSMutableArray *tempResult;
        if (_page == 1) {
            tempResult = [NSMutableArray array];
        }else{
            tempResult = [NSMutableArray arrayWithArray:self.coupons];
        }
        
        NSArray *array = result.data;
        if (array.count <= 0) {
            [self.tableView.footer noticeNoMoreData];
        }else{
            for (NSDictionary *dic in array) {
                CouponObj *item = [CouponObj mj_objectWithKeyValues:dic];
                [tempResult addObject:item];
            }
            if (array.count < _rows) {
                [self.tableView.footer noticeNoMoreData];
            }else{
                [self.tableView.footer endRefreshing];
            }
        }
        
        [self.tableView.header endRefreshing];
        
        self.coupons = [NSArray arrayWithArray:tempResult];
        [self updateUI];
        
    }
//    else if (result.type == EmRequestType_CouponList) {
//        self.coupons = [CouponObj mj_objectArrayWithKeyValuesArray:result.data];
//        [self updateUI];
//    }
   
}

-(void)httpRequestFailed:(NSNotification *)notification{
    
    [super httpRequestFailed:notification];
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    [self updateUI];
}
@end
