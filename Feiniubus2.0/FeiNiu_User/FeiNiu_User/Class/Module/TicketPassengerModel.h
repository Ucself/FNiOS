//
//  ticketPassengerModel.h
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <FNDataModule/FNDataModule.h>

@interface TicketPassengerModel : BaseModel

@property(nonatomic,strong) NSString *id;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,assign) int type;               //1普通票 3半票
@property(nonatomic,strong) NSString *idCard;
@property(nonatomic,strong) NSString *phone;

@end
