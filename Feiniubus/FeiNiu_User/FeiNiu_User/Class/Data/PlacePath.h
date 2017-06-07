//
//  PlacePath.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/9/17.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlacePath : NSObject
@property (nonatomic,assign)unsigned int pathType;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *adCode;
@property (nonatomic,assign)unsigned int sequence;
@property (nonatomic,copy)NSString *location;
@end
