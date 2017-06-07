//
//  DetaillistViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/27.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DetaillistViewController.h"
#import "CharterOrderItem.h"

@interface DetailListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *ivDot;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblDesc;

@end
@implementation DetailListCell



@end

#define kImageName      @"imageName"
#define kDetailTitle    @"title"
#define kDetailDesc     @"desc"

@interface DetaillistViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readonly) NSArray *dataList;
@end

@implementation DetaillistViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Travel" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"DetaillistViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.orderItem && [self.orderItem isKindOfClass:[CharterSuborderItem class]]) {
        CharterSuborderItem *item = self.orderItem;
        self.lblPrice.text = @(item.price / 100).stringValue;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSArray *)dataList{
    if (self.orderItem && [self.orderItem isKindOfClass:[CharterSuborderItem class]]) {
        CharterSuborderItem *item = self.orderItem;
        return @[
                 @{kImageName : @"dot_green", kDetailTitle:[NSString stringWithFormat:@"%@%@", item.bus.typeName, item.bus.levelName], kDetailDesc:[NSString stringWithFormat:@"%@元", @(item.price / 100) ]},
                 @{kImageName : @"dot_red", kDetailTitle:@"优惠券抵扣", kDetailDesc:@"200元"},
                 @{kImageName : @"dot_yellow", kDetailTitle:@"定金支付", kDetailDesc:@"100元"},
                 @{kImageName : @"dot_purple", kDetailTitle:@"对公转账", kDetailDesc:@"100元"},
                 ];
    }
    return @[
             @{kImageName : @"dot_green", kDetailTitle:@"大型高一级", kDetailDesc:@"1100元"},
             @{kImageName : @"dot_purple", kDetailTitle:@"大型高一级", kDetailDesc:@"1100元"},
             @{kImageName : @"dot_yellow", kDetailTitle:@"大型高一级", kDetailDesc:@"1100元"},

             ];
}
#pragma mark - TableViewDelegate && Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"DetailListCell";
    DetailListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[DetailListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dic = self.dataList[indexPath.row];
    cell.ivDot.image = [UIImage imageNamed:dic[kImageName]];
    cell.lblTitle.text = dic[kDetailTitle];
    cell.lblDesc.text = dic[kDetailDesc];
    
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
