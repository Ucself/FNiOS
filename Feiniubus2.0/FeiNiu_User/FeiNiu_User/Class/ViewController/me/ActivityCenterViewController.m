//
//  ActivityCenterViewController.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 2017/3/21.
//  Copyright © 2017年 tianbo. All rights reserved.
//

#import "ActivityCenterViewController.h"

@interface ActivityTableViewCell()


@end
@implementation ActivityTableViewCell

-(CGFloat)getCellHeight {
    CGFloat imageHeight = (deviceWidth - 24.0) * 300.0/700.0;
    CGFloat cellHeight = imageHeight + 122;
    return cellHeight;
}

@end

@interface ActivityCenterViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation ActivityCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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


#pragma mark -  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityTableViewCell"];

    
    return cell;
}

#pragma mark -  UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageHeight = (deviceWidth - 24.0) * 300.0/700.0;
    CGFloat cellHeight = imageHeight + 122;
    return cellHeight;
}
@end
