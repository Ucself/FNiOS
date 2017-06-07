//
//  TravelListViewController.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/29.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserBaseUIViewController.h"

@interface TravelListViewController : UserBaseUIViewController{
    NSInteger   _page;
    NSInteger   _pageSize;
    NSIndexPath *_selectedIndexPath;
}
@property (nonatomic, strong) NSMutableArray *dataList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *selectDict;

@property (nonatomic, assign) BOOL        isRefresh;


- (void)refresh;
- (void)updateSelectedRowWithItem:(id)item;

- (void)requestTravelList;
- (void)requestSelectedItem;

//edit mode
- (void)setEditMode:(BOOL)edit;
- (void)deleteAction;
- (void)deleteSelectItems;

// Override Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end
