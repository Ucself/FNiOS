//
//  MoreCarViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "MoreCarViewController.h"
#import "MoreCarTableViewCell.h"
@interface MoreCarViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startPlaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *endPlaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *kmLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MoreCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MoreCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MoreCarTableViewCell class]) forIndexPath:indexPath];
    return cell;
}

@end
