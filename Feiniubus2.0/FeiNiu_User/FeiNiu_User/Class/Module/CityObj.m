//
//  CityObj.m
//  FeiNiu_User
//
//  Created by tianbo on 2016/11/9.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CityObj.h"


//MARK:  CityObj
@implementation CityObj

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.adcode = [aDecoder decodeObjectForKey:@"adcode"];
        self.city_name = [aDecoder decodeObjectForKey:@"city_name"];
        self.company_name = [aDecoder decodeObjectForKey:@"company_name"];
        self.disabled = [aDecoder decodeObjectForKey:@"disabled"];
        self.province_code = [aDecoder decodeObjectForKey:@"province_code"];
        self.province_name = [aDecoder decodeObjectForKey:@"province_name"];
        self.site_level = [[aDecoder decodeObjectForKey:@"site_level"] intValue];
        self.tag = [[aDecoder decodeObjectForKey:@"tag"] intValue];
        self.central_latitude = [[aDecoder decodeObjectForKey:@"central_latitude"] doubleValue];
        self.central_longitude = [[aDecoder decodeObjectForKey:@"central_longitude"] doubleValue];
    }
    return  self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.adcode forKey:@"adcode"];
    [aCoder encodeObject:self.city_name forKey:@"city_name"];
    [aCoder encodeObject:self.company_name forKey:@"company_name"];
    [aCoder encodeObject:self.disabled forKey:@"disabled"];
    [aCoder encodeObject:self.province_code forKey:@"province_code"];
    [aCoder encodeObject:self.province_name forKey:@"province_name"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.site_level] forKey:@"site_level"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.tag] forKey:@"tag"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.central_latitude] forKey:@"central_latitude"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.central_longitude] forKey:@"central_longitude"];
}


@end

//MARK: - StationObj
@implementation StationObj
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.station_id = [aDecoder decodeObjectForKey:@"station_id"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.longitude = [[aDecoder decodeObjectForKey:@"longitude"] doubleValue];
        self.latitude = [[aDecoder decodeObjectForKey:@"latitude"] doubleValue];
        self.type = [[aDecoder decodeObjectForKey:@"type"] intValue];
    }
    return  self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.station_id forKey:@"station_id"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.longitude] forKey:@"longitude"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.latitude] forKey:@"latitude"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.type] forKey:@"type"];
}

@end


//MARK: - FenceObj
@implementation FenceObj

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.business_module = [aDecoder decodeObjectForKey:@"business_module"];
        self.adcode = [aDecoder decodeObjectForKey:@"adcode"];
        self.priority = [[aDecoder decodeObjectForKey:@"priority"] intValue];
        self.disabled = [[aDecoder decodeObjectForKey:@"disabled"] boolValue];
        self.coordinates = [aDecoder decodeObjectForKey:@"coordinates"];
        
    }
    return  self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.business_module forKey:@"business_module"];
    [aCoder encodeObject:self.adcode forKey:@"adcode"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.priority] forKey:@"priority"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.disabled] forKey:@"disabled"];
    [aCoder encodeObject:self.coordinates forKey:@"coordinates"];
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"coordinates": [CoordinateObj class]};
}

@end

//MARK: - CoordinateObj
@implementation CoordinateObj

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.longitude = [[aDecoder decodeObjectForKey:@"longitude"] doubleValue];
        self.latitude = [[aDecoder decodeObjectForKey:@"latitude"] doubleValue];
        self.sort= [[aDecoder decodeObjectForKey:@"sort"] intValue];
    }
    return  self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithDouble:self.longitude] forKey:@"longitude"];
    [aCoder encodeObject:[NSNumber numberWithDouble:self.latitude] forKey:@"latitude"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.sort] forKey:@"sort"];
}

@end
