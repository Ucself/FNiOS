//
//  ConfirmOrderViewCell.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/3.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "ConfirmOrderViewCell.h"
#import "CharterOrderItem.h"

@implementation UserTableViewCell

+ (NSString *)identifier{
    return NSStringFromClass(self);
}

@end

@implementation OrderInfoCell

+ (NSString *)identifier{
    return @"OrderInfoCell";
}
- (void)setType:(OrderInfoCellType)type withContent:(NSString *)content{
    _type = type;
    switch (type) {
        case OrderInfoCellTypeTime:{
            _ivIcon.image = [UIImage imageNamed:@"bus_startTime_icon"];
            _splitTop.hidden = YES;
            _splitBottom.hidden = YES;
            break;
        }
        case OrderInfoCellTypeStart:{
            _ivIcon.image = [UIImage imageNamed:@"place_green"];
            _splitTop.hidden = YES;
            _splitBottom.hidden = NO;
            break;
        }
        case OrderInfoCellTypeCover:{
            _ivIcon.image = [UIImage imageNamed:@"place_red"];
            _splitTop.hidden = NO;
            _splitBottom.hidden = NO;
            break;
        }
        case OrderInfoCellTypeEnd:{
            _ivIcon.image = [UIImage imageNamed:@"place_red"];
            _splitTop.hidden = NO;
            _splitBottom.hidden = YES;
            break;
        }
        case OrderInfoCellTypeBus:{
            _ivIcon.image = [UIImage imageNamed:@"bus_car_icon"];
            _splitTop.hidden = YES;
            _splitBottom.hidden = YES;
            break;
        }
        default:
            return;
    }
    
    _lblContent.text = content;
}
@end

NSString * const keyType = @"type";
NSString * const keyContent = @"content";

@interface ConfirmOrderViewCell (){
    NSArray<NSDictionary *> *_data;
}

@end
@implementation ConfirmOrderViewCell
+ (CGFloat)heightForRow{
    return 38;
}
- (void)loadData{
    NSMutableArray *temp =[NSMutableArray array];
    NSString *content = [NSString stringWithFormat:@"%@ - %@", [self.suborder.startingTime timeStringByFormat:@"MM月dd日 HH:mm"], [self.suborder.returnTime timeStringByFormat:@"MM月dd日 HH:mm"]];

    
    NSDictionary *item = @{keyType:@(OrderInfoCellTypeTime), keyContent:content};
    [temp addObject:item];
    
    item = @{keyType:@(OrderInfoCellTypeStart), keyContent:[NSString stringWithFormat:@"%@", self.suborder.starting.name]};
    [temp addObject:item];
    
    if (self.suborder.route.count > 0) {
        for (CharterPlace *place in self.suborder.route) {
            item = @{keyType:@(OrderInfoCellTypeCover), keyContent:[NSString stringWithFormat:@"%@", place.name]};
            [temp addObject:item];
        }
    }
    
    item = @{keyType:@(OrderInfoCellTypeEnd), keyContent:[NSString stringWithFormat:@"%@",self.suborder.destination.name]};
    [temp addObject:item];
    
    item = @{keyType : @(OrderInfoCellTypeBus), keyContent:[NSString stringWithFormat:@"%@", self.suborder.bus]};
    [temp addObject:item];
    _data = [NSArray arrayWithArray:temp];
}
- (void)setSuborder:(CharterSuborderItem *)suborder{
    _suborder = suborder;
    [self loadData];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.suborder.route.count + 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:[OrderInfoCell identifier]];
    OrderInfoCellType type = [_data[indexPath.row][keyType] intValue];
    NSString *content = _data[indexPath.row][keyContent];
    [(OrderInfoCell *)cell setType:type withContent:content];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[self class] heightForRow];
}
@end

@implementation PayInfoCell
+ (NSString *)paymentPrefix{
    return @"Payment_";
}
+ (NSDictionary *)paymentDes{
    return @{
             [[self paymentPrefix] stringByAppendingFormat:@"%@",@(PaymentChannel_Weixin)]: @{@"title" : @"微信支付", @"subtitle" : @"", @"icon" : @"pay_icon_wechat"},
             [[self paymentPrefix] stringByAppendingFormat:@"%@", @(PaymentChannel_ALI)] : @{@"title" : @"支付宝支付", @"subtitle" : @"", @"icon" : @"pay_icon_alipay"},
             [[self paymentPrefix] stringByAppendingFormat:@"%@", @(PaymentChannel_UPMP)] : @{@"title" : @"企业对公转账", @"subtitle" : @"", @"icon" : @"pay_icon_enterprise"},
             [[self paymentPrefix] stringByAppendingFormat:@"%@", @(PaymentChannel_EarnestFeiniu)] : @{@"title" : @"飞牛巴士定金支付", @"subtitle" : @"合作商家可先付定金", @"icon" : @"pay_icon_earnest"},
//             [[self paymentPrefix] stringByAppendingFormat:@"%@", @(PaymentChannel_Duigong)] : @{@"title" : @"企业对公转账", @"subtitle" : @"", @"icon" : @"pay_icon_enterprise"},
             };

}
- (void)setPaymentType:(PaymentChannel)paymentType{
    _paymentType = paymentType;
    NSDictionary *des = [PayInfoCell paymentDes][[[PayInfoCell paymentPrefix] stringByAppendingFormat:@"%@",@(paymentType)]];
    self.lblTitle.text = des[@"title"];
    self.lblDetail.text = des[@"subtitle"];
    self.ivIcon.image = [UIImage imageNamed:des[@"icon"]];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    self.btnCheck.selected = selected;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    self.btnCheck.selected = selected;
}
@end
