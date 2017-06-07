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

@end
