//
//  AddContactPeopleViewController.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "UserBaseUIViewController.h"
#import "TicketPassengerModel.h"

typedef NS_ENUM(int , AddPeopleTypeEnum) {
    addPeopleFromOrderTypeEnum,
    addPeopleFromListTypeEnum,
};

@protocol AddContactPeopleViewControllerDelegate <NSObject>

-(void)addContactPeopleSuccess:(TicketPassengerModel*)ticketPassengerModel;

@end
@interface AddContactPeopleViewController : UserBaseUIViewController

@property(nonatomic,assign) id<AddContactPeopleViewControllerDelegate> delegate;
@property(nonatomic,assign) AddPeopleTypeEnum addPeopleTypeEnum;

@end
