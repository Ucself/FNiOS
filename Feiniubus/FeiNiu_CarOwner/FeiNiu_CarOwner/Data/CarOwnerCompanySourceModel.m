//
//  CarOwnerCompanySourceModel.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/4.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerCompanySourceModel.h"
#import <FNCommon/pinyin.h>

@interface CarOwnerCompanySourceModel ()
{
    NSObject *object;
    NSString *pinYin;
}

@property (nonatomic,strong) NSMutableArray *array;

@end

@implementation CarOwnerCompanySourceModel


-(instancetype)initWithData:(NSMutableArray*)array
{
    self = [super init];
    //设置数据
    if (self) {
        _array = array;
        //数据源
        [self changeDataSource];
    }
    
    return self;
}

#pragma mark -- 改变数据
-(void) changeDataSource
{
    //初始化数据
    _returnDic = [[NSMutableDictionary alloc] init];
    //传入的数据包含 id name registerLocation 的字典
    for (int i = 0; i < _array.count; i++) {
        NSString *nameStr = [(NSDictionary *)_array[i] objectForKey:@"name"];
        if (!(nameStr && nameStr.length > 0)) {
            continue;
        }
        NSString *firstLetter = [NSString stringWithFormat:@"%c",pinyinFirstLetter([nameStr characterAtIndex:0])];
        //转换为大写
        firstLetter = [self toUpper:firstLetter];
        //是否包含某个值
        if([_returnDic objectForKey:firstLetter])
        {
            NSMutableArray *tempArray = [_returnDic objectForKey:firstLetter];
            [tempArray addObject:_array[i]];
        }
        else
        {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            [tempArray addObject:_array[i]];
            [_returnDic setObject:tempArray forKey:firstLetter];
        }
    }
}

-(NSString *)toLower:(NSString *)str{
    for (NSInteger i=0; i<str.length; i++) {
        if ([str characterAtIndex:i]>='A'&[str characterAtIndex:i]<='Z') {
            //A  65  a  97
            char  temp=[str characterAtIndex:i]+32;
            NSRange range=NSMakeRange(i, 1);
            str=[str stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"%c",temp]];
        }
    }
    return str;
}

-(NSString *)toUpper:(NSString *)str{
    for (NSInteger i=0; i<str.length; i++) {
        if ([str characterAtIndex:i]>='a'&[str characterAtIndex:i]<='z') {
            //A  65  a  97
            char  temp=[str characterAtIndex:i]-32;
            NSRange range=NSMakeRange(i, 1);
            str=[str stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"%c",temp]];
        }
    }
    return str;
}

@end












