//
//  User.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "User.h"

@implementation User

-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        // [self parseDictionary:dictionary];
        if ([dictionary isKindOfClass:[NSNull class]] || !dictionary) {
            return self;
        }
        self.Id = dictionary[@"id"];
        self.phone = dictionary[@"phone"];
        self.name = dictionary[@"name"];
        self.nickName = dictionary[@"nickName"];
        self.gender = dictionary[@"gender"];
        self.userType = dictionary[@"userType"];
        self.avatar = dictionary[@"avatar"];
        self.accumulateMileage = dictionary[@"accumulateMileage"];
        self.birthday = dictionary[@"birthday"];
        self.email = dictionary[@"email"];
        self.token = dictionary[@"token"];
        self.couponsAmount = dictionary[@"couponsAmount"];
        self.phoneType = dictionary[@"phoneType"];
        self.registrationId = dictionary[@"registrationId"];

    }
 
    return self;
}

//对象序列化方法
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.Id forKey:@"Id"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.nickName forKey:@"nickName"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.userType forKey:@"userType"];
    [aCoder encodeObject:self.accumulateMileage forKey:@"accumulateMileage"];
    [aCoder encodeObject:self.token forKey:@"token"];

    [aCoder encodeObject:self.birthday forKey:@"birthday"];
    [aCoder encodeObject:self.couponsAmount forKey:@"couponsAmount"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.phoneType forKey:@"phoneType"];
    [aCoder encodeObject:self.registrationId forKey:@"registrationId"];

}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.Id = [aDecoder decodeObjectForKey:@"Id"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        
        self.nickName = [aDecoder decodeObjectForKey:@"nickName"];
        self.userType = [aDecoder decodeObjectForKey:@"userType"];
        self.accumulateMileage = [aDecoder decodeObjectForKey:@"accumulateMileage"];
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.couponsAmount = [aDecoder decodeObjectForKey:@"couponsAmount"];
        self.phoneType = [aDecoder decodeObjectForKey:@"phoneType"];
        self.registrationId = [aDecoder decodeObjectForKey:@"registrationId"];

    }
    return  self;
}

@end
