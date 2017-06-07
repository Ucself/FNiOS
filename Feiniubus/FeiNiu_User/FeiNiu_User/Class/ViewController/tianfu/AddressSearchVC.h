//
//  AddressSearchVC.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/26.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FNUIView/BaseUIViewController.h>
//#import <FNMap/FNLocation.h>
#import "UserBaseUIViewController.h"


@protocol AddressSearchDelegate <NSObject>

//- (void)searchLocation:(FNLocation *)location;

@end



@interface AddressSearchVC : UserBaseUIViewController


@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSString* cityID;

@property (nonatomic,weak) id<AddressSearchDelegate>myDelegate;
@end
