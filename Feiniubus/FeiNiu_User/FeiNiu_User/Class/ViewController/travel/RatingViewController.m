//
//  RatingViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/27.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "RatingViewController.h"
#import "CarTableViewCell.h"
#import "DriverTableViewCell.h"
#import "RatingCellDelegate.h"

@interface RatingViewController () <RatingCellDelegate>

@property(nonatomic, strong) NSMutableArray *array;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation RatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _array = [[NSMutableArray alloc] init];
    [_array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"edit", @"0", @"score", nil]];
    [_array addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"0", @"edit", @"0", @"score", nil]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = _array[indexPath.section];
    if ([[dict objectForKey:@"edit"] intValue] == 0) {
        return 188;               //评价车辆正常高度
    }
    else {
        return 188 + 90;          //编辑高度
    }
    
    //return 290;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _array.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = nil;
    
    if (indexPath.section % 2 == 0) {

        static NSString *cellID = @"ratingCarCell";
        CarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CarTableViewCell" owner:self options:0] firstObject];
            
            cell.delegate = self;
            cell.lagreSating.tag = indexPath.row +100;
        }
        
        NSMutableDictionary *dict = _array[indexPath.row];
        [cell.lagreSating displayRating:[[dict objectForKey:@"score"] floatValue]];
        return cell;
    }
    else {
        static NSString *cellID = @"ratingDriverCell";
        DriverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DriverTableViewCell" owner:self options:0] firstObject];
            
            cell.delegate = self;
            cell.lagreSating.tag = indexPath.row +100;
        }
        
        NSMutableDictionary *dict = _array[indexPath.row];
        [cell.lagreSating displayRating:[[dict objectForKey:@"score"] floatValue]];
        return cell;
    }
    
    
    //cell.textLabel.text = [NSString stringWithFormat:@"第%ld行", indexPath.row];
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark-
-(void)tableViewCell:(UITableViewCell*)cell newRating:(float)newRating
{
    //更新数据
    if ([cell isKindOfClass:[CarTableViewCell class]]) {
        CarTableViewCell *carCell = (CarTableViewCell*)cell;
        int index = (int)carCell.lagreSating.tag - 100;
        
        NSMutableDictionary *dict = _array[index];
        [dict setObject:@"1" forKey:@"edit"];
        [dict setObject:[NSString stringWithFormat:@"%f", newRating] forKey:@"score"];
    }
    else if ([cell isKindOfClass:[DriverTableViewCell class]]) {
        DriverTableViewCell *carCell = (DriverTableViewCell*)cell;
        int index = (int)carCell.lagreSating.tag - 100;
        
        NSMutableDictionary *dict = _array[index];
        [dict setObject:@"1" forKey:@"edit"];
        [dict setObject:[NSString stringWithFormat:@"%f", newRating] forKey:@"score"];
    }
    
    //刷新页面
    [self.tableView reloadData];
}
@end
