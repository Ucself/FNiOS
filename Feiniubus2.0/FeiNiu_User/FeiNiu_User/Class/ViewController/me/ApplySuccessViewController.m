//
//  ApplySuccessViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 2017/1/12.
//  Copyright © 2017年 tianbo. All rights reserved.
//

#import "ApplySuccessViewController.h"
#import "ApplyScheduledViewController.h"

@interface ApplySuccessViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ApplySuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnCommitClikc:(id)sender {
    ApplyScheduledViewController *c = [ApplyScheduledViewController instanceWithStoryboardName:@"Me"];
    
    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
    [viewControllers removeLastObject];
    [viewControllers addObject:c];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark -  uitableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"applyTableCell" forIndexPath:indexPath];
    UIView *lineView = [cell viewWithTag:101];
    
    if (indexPath.row != 3) {
        [lineView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(48);
            make.bottom.equalTo(cell);
            make.right.equalTo(cell);
            make.height.equalTo(0.5);
        }];
    }
    else {
        [lineView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.bottom.equalTo(cell);
            make.right.equalTo(cell);
            make.height.equalTo(0.5);
        }];
    }
    
    
    
    
    switch (indexPath.row) {
        case 0: {
            cell.imageView.image = [UIImage imageNamed:@"icon_home"];
            cell.textLabel.text = @"家庭住址";
            cell.detailTextLabel.text = self.homeAddr ? self.homeAddr : @"您住在哪儿?";
            cell.detailTextLabel.textColor = self.homeAddr == nil ? UITextColor_LightGray : UITextColor_DarkGray;
        }
            break;
        case 1: {
            cell.imageView.image = [UIImage imageNamed:@"icon_mac"];
            cell.textLabel.text = @"公司地址";
            cell.detailTextLabel.text = self.componyAddr ? self.componyAddr : @"公司在哪儿?";
            cell.detailTextLabel.textColor = self.componyAddr == nil ? UITextColor_LightGray : UITextColor_DarkGray;
        }
            break;
        case 2: {
            cell.imageView.image = [UIImage imageNamed:@"icon_time_work"];
            cell.textLabel.text = @"上班时间";
            cell.detailTextLabel.text = self.onworkTime ? self.onworkTime : @"几点上班?";
            cell.detailTextLabel.textColor = self.onworkTime == nil ? UITextColor_LightGray : UITextColor_DarkGray;
        }
            break;
        case 3: {
            cell.imageView.image = [UIImage imageNamed:@"icon_time_off_duty"];
            cell.textLabel.text = @"下班时间";
            cell.detailTextLabel.text = self.offworkTime ? self.offworkTime : @"几点下班?";
            cell.detailTextLabel.textColor = self.offworkTime == nil ? UITextColor_LightGray : UITextColor_DarkGray;
        }
            break;
            
        default:
            break;
    }
    
    
    return cell;
}

@end
