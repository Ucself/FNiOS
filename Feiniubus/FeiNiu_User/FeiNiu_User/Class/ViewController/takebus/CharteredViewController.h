
//  CharteredViewController.h
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/7/31.
//  Copyright (c) 2015年 feiniubus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseUIViewController.h"
#import "CharterOrderPrice.h"


typedef NS_ENUM(NSInteger, CharterSubmitCellType) {
    CharterSubmitCellTypeStartPlace,
    CharterSubmitCellTypeEndPlace,
    CharterSubmitCellTypeCoverPlace,
    CharterSubmitCellTypeStartTime,
    CharterSubmitCellTypeEndTime,
    CharterSubmitCellTypeBaoChiZhu,
    CharterSubmitCellTypeAddBus,
    CharterSubmitCellTypeRemoveBus,
};

@interface CharteredViewController : UserBaseUIViewController{
    NSMutableArray *_tableData;
}
@property (strong,nonatomic) CharterOrderPrice *charterOrder;
@property (strong, nonatomic) NSIndexPath *rowPath;

- (NSInteger)orderType;
- (NSMutableArray<NSMutableArray *> *)tableData;
- (NSDictionary *)rowDataByType:(CharterSubmitCellType)type;

@end
