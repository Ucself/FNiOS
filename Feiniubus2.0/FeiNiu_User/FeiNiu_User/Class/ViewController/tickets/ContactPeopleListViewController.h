//
//  ContactPeopleListViewController.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "UserBaseUIViewController.h"
#import "TicketPassengerModel.h"

#define selectPeopleNotification   @"selectPeopleNotification"


@protocol ContactPeopleListViewControllerDelegate <NSObject>

-(void)okClickReturnInfor:(NSMutableArray*)ticketPassengerModelArray selectTicketPassenger:(NSMutableArray*)selectTicketPassenger;

@end

@interface ContactPeopleListViewController : UserBaseUIViewController


@property (nonatomic,strong) NSMutableArray *mainDatasource;
@property (nonatomic,strong) NSMutableArray *selectDatasource;
@property(assign,nonatomic) id<ContactPeopleListViewControllerDelegate> delegate;

@end
