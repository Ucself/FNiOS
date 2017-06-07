//
//  CachedataPreferences.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/12/11.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CachedataPreferences : NSObject

@property (nonatomic, strong) NSMutableDictionary  *preDict;

-(void)save;

+(CachedataPreferences*)sharedInstance;

//缓存历史目的地
-(void)setHistoryDestination:(NSMutableArray*)infor;
-(NSMutableArray*)getHistoryDestination;

//缓存首页的bannar 的数据
-(void)setBannerInfor:(NSMutableArray*)infor;
-(NSMutableArray*)getBannerInfor;

//缓存订票出发地和目的地
-(void)setOriginDestination:(NSMutableArray*)infor;
-(NSMutableArray*)getOriginDestination;

//缓存选择上下车地点
-(void)setHirstoryPlaceInfor:(NSMutableArray*)infor;
-(NSMutableArray*)getHirstoryPlaceInfor;

//缓存定位数据
-(void)setLocationData:(NSDictionary*)infor;
-(NSDictionary*)getLocationData;

@end
