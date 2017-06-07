//
//  MoreViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/20.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "MoreViewController.h"
#import <FNNetInterface/FNNetInterface.h>
#import <FNUIView/REFrostedViewController.h>
#import <FNUIView/UIViewController+REFrostedViewController.h>
#import "RuleViewController.h"
#import "LoginViewController.h"

@interface MoreViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *array;
@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.array = @[@"关于我们", @"功能介绍", @"使用协议"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setVersionLabel:(NSString *)versionId cell:(UITableViewCell *)cell{
    
    UILabel *detailLabel = [[UILabel alloc] init];
    [detailLabel setTextAlignment:NSTextAlignmentCenter];
    [detailLabel setText:[NSString stringWithFormat:@"当前版本%@",versionId]];
    [detailLabel setFont:[UIFont systemFontOfSize:15]];
    [detailLabel setTextColor:[UIColor grayColor]];
    [cell.contentView addSubview:detailLabel];
    [detailLabel makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(cell.right).offset(-30);
        make.centerY.equalTo(cell.centerY);
        make.width.equalTo(100);
        make.height.equalTo(40);
    }];
}

#pragma mark - Actions
- (IBAction)actionSignOut:(UIButton *)sender {
    [[UserPreferences sharedInstance] setToken:nil];
    [[UserPreferences sharedInstance] setUserId:nil];
    [[UserPreferences sharedInstance] setUserInfo:nil];
    [[PushConfiguration sharedInstance] resetAlias];
    [NetManagerInstance setAuthorization:@""];

    [LoginViewController presentAtViewController:self.frostedViewController needBack:NO requestToHomeIfCancel:NO completion:^{
        [self.frostedViewController hideMenuViewController];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } callBalck:^(BOOL isSuccess, BOOL needToHome) {
        
    }];
    
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"moretableviewcell"];
    
//    if (indexPath.row == 2) {
    
//        [self setVersionLabel:@"1.0" cell:cell];
//    }
   
    cell.textLabel.text = self.array[indexPath.row];
    cell.detailTextLabel.text = @"";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"torating" sender:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    if (indexPath.row == 2) {
//        //update item
////        CustomVersionView *viewVersion = [CustomVersionView sharedInstance];
////        [viewVersion showInView:self.view];
//        
//    }else{
        //test vc
        
        RuleViewController *rule = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
        
        
        switch (indexPath.row) {
            case 0:
                rule.vcTitle = @"关于我们";
                rule.urlString = [NSString stringWithFormat:@"%@about.html",KAboutServerAddr];
                break;
            case 1:
                rule.vcTitle = @"功能介绍";
                rule.urlString = [NSString stringWithFormat:@"%@introduce.html",KAboutServerAddr];
                break;
            case 2:
                rule.vcTitle = @"使用协议";
                rule.urlString = [NSString stringWithFormat:@"%@agreement1.html",KAboutServerAddr];
                break;
                
            default:
                break;
        }
    
        [self.navigationController pushViewController:rule animated:YES];
//    }
}

@end
