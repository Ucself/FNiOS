//
//  AddressBookHelp.h
//  FeiNiu_User
//
//  Created by CYJ on 16/6/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressBookHelp : NSObject

- (instancetype)initWithAddressDelegate:(id) addressDelegate;

- (void)showAddressBookController;

/**
 * @breif 用于弹出通讯录
 */
@property(nonatomic,assign) id addressDelegate;

@property (copy, nonatomic) void (^clickComplete)(NSString *phoneNumber,NSString *error);

@end
