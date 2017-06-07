//
//  CouponsViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/20.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CouponsViewController.h"
#import "ConfirmOrderViewCell.h"
#import "UIColor+Hex.h"

NSString *FNRequestCouponTypeKey = @"type";
NSString *FNRequestCouponStateKey = @"state";
NSString *FNRequestCouponLimitKey = @"limit";

@interface CouponCell : UserTableViewCell
@property (nonatomic, weak) IBOutlet UIView *roundCornerBack;
@property (weak, nonatomic) IBOutlet UIImageView *ivCoupon;
@property (weak, nonatomic) IBOutlet UILabel *lblCouponName;
@property (weak, nonatomic) IBOutlet UILabel *lblCouponDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblCouponExpire;
@property (weak, nonatomic) IBOutlet UIImageView *ivCouponState;
@property (weak, nonatomic) IBOutlet UILabel *lblTotal;

@end
@implementation CouponCell
- (void)awakeFromNib{
    [super awakeFromNib];
    self.roundCornerBack.layer.cornerRadius = 4;
}
- (void)setCoupon:(Coupon *)coupon{
    self.lblCouponName.text = coupon.name;
    self.lblCouponDesc.text = [NSString stringWithFormat:@"满%@元即可使用", @(coupon.limit)];
    self.lblCouponExpire.text = [NSString stringWithFormat:@"有效期至：%@", [coupon.expiry timeStringByFormat:@"yyyy-MM-dd"]];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"￥" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    [str appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@(coupon.total / 100).stringValue attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:25]}]];
    self.lblTotal.attributedText = str;
    
    UIColor *textColor = [UIColor colorWithHex:0x666666];

    if (coupon.state == CouponStateNormal) {
        self.ivCouponState.image = [UIImage imageNamed:@"seal_normal"];
        self.ivCoupon.image = [UIImage imageNamed:@"coupon_yellow_bg"];
        self.lblTotal.textColor = [UIColor whiteColor];
        textColor = [UIColor colorWithHex:0x666666];
    }else if (coupon.state == CouponStateUsed){
        self.ivCouponState.image = [UIImage imageNamed:@"seal_used"];
        self.ivCoupon.image = [UIImage imageNamed:@"coupon_gray_bg"];
        self.lblTotal.textColor = [UIColor colorWithHex:0xb4b4b4];
        textColor = [UIColor colorWithHex:0xb4b4b4];
    }else{
        self.ivCouponState.image = [UIImage imageNamed:@"seal_expire"];
        self.ivCoupon.image = [UIImage imageNamed:@"coupon_gray_bg"];
        self.lblTotal.textColor = [UIColor colorWithHex:0xb4b4b4];
        textColor = [UIColor colorWithHex:0xb4b4b4];
    }
    
    self.lblCouponName.textColor = textColor;
    self.lblCouponExpire.textColor = textColor;
    self.lblCouponDesc.textColor = textColor;
}
- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        self.roundCornerBack.layer.borderWidth = 1;
        self.roundCornerBack.layer.borderColor = [UIColor colorWithHex:GloabalTintColor].CGColor;
    }else{
        self.roundCornerBack.layer.borderWidth = 0;
    }
    
}
- (void)drawRect:(CGRect)rect{
    if (self.selected) {
        self.roundCornerBack.layer.borderWidth = 1;
        self.roundCornerBack.layer.borderColor = [UIColor colorWithHex:GloabalTintColor].CGColor;
    }else{
        self.roundCornerBack.layer.borderWidth = 0;
    }
}
@end


@interface CouponsViewController ()<UITableViewDelegate>{
    NSInteger   _page;
    NSInteger   _pageSize;
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
    _pageSize = 20;
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 0;
        [self requestCoupons];
    }];
    self.tableView.header.automaticallyChangeAlpha = YES;
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _page++;
        [self requestCoupons];
    }];
    if (!self.coupons || self.coupons.count <= 0) {
        [self requestCoupons];
        [self.tableView.header beginRefreshing];
    }
//    self.tableView.backgroundView = self.noCouponView;
    [self updateUI];
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

- (CouponType)typeRequest{
    if (!self.couponsParams) {
        return CouponTypeCharter;
    }else{
        return [self.couponsParams[FNRequestCouponTypeKey] integerValue];
    }
}
- (CouponState)stateRequest{
    if (!self.couponsParams) {
        return CouponStateNormal;
    }else{
        return [self.couponsParams[FNRequestCouponStateKey] integerValue];
    }
}
- (NSInteger)limitRequest{
    return [self.couponsParams[FNRequestCouponLimitKey] integerValue];
}
#pragma mark - Request Methods
- (void)requestCoupons{
    NSString *url = [KServerAddr stringByAppendingString:@"coupons"];
    NSMutableDictionary *dict = [self.couponsParams mutableCopy];
    if (!dict) {
        dict = [@{FNRequestCouponStateKey:@(CouponStateNormal), FNRequestCouponLimitKey:@(0)} mutableCopy];
    }
    [dict setObject:@(_page * _pageSize) forKey:@"spik"];
    [dict setObject:@(_pageSize) forKey:@"rows"];
    
    [NetManagerInstance sendRequstWithType:FNUserRequestType_Coupons params:^(NetParams *params) {
        params.data = dict;
    }];
}

#pragma mark- uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.coupons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CouponCell";
    CouponCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setCoupon:self.coupons[indexPath.row]];
    if (self.selectedCoupon && [self.coupons[indexPath.row].couponId isEqualToString:self.selectedCoupon.couponId]) {
//        cell.selected = YES;
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectedCouponsCallback) {
        Coupon *coupon = self.coupons[indexPath.row];
        if ([coupon.couponId isEqualToString:self.selectedCoupon.couponId]) {
            self.selectedCouponsCallback(nil);
        }else{
            self.selectedCouponsCallback(self.coupons[indexPath.row]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    return nil;
}

#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    
    NSMutableArray *tempResult;
    if (_page == 0) {
        tempResult = [NSMutableArray array];
    }else{
        tempResult = [NSMutableArray arrayWithArray:self.coupons];
    }
    NSArray *results = resultData.data[@"list"];
    if (results.count <= 0) {
        [self.tableView.footer noticeNoMoreData];
    }else{
        for (NSDictionary *dic in results) {
            Coupon *item = [[Coupon alloc]initWithDictionary:dic];
            [tempResult addObject:item];
        }
        if (results.count < _pageSize) {
            [self.tableView.footer noticeNoMoreData];
        }else{
            [self.tableView.footer endRefreshing];
        }
    }
    
    [self.tableView.header endRefreshing];
    
    self.coupons = [NSArray arrayWithArray:tempResult];
    [self updateUI];
}

-(void)httpRequestFailed:(NSNotification *)notification{
    @try {
        [((NSMutableDictionary *)notification.object) setObject:@(YES) forKey:NeedToHomeKey];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    [super httpRequestFailed:notification];
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    
}
@end
