//
//  CarpoolCustomCell.h
//  FeiNiu_User
//
//  Created by iamdzz on 15/12/8.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CarpoolCustomDelegate <NSObject>

- (void)CarpoolCustomCellCallBack:(NSString *)pathId
                          trainId:(NSString *)trainId
                        startTime:(NSString *)startTime
                          endTime:(NSString *)endTime
                         cellType:(int)type
                          timeStr:(NSString *)timeStr
                        cellState:(int)cellState
                        indexPath:(NSIndexPath *)indexPath
                  collectionIndex:(NSIndexPath *)collectionIndexPath
                   buttonSelected:(BOOL)buttonSelected
                     cellSelected:(BOOL)cellSelected;

@end

@interface CarpoolCustomCell : UITableViewCell

@property (nonatomic, strong) UIView     *leftLine;
@property (nonatomic, strong) UIView     *rightLine;
@property (nonatomic, strong) UILabel    *busStopTitle;
@property (nonatomic, strong) UIButton   *scrollButton;
@property (nonatomic, strong) UILabel    *timeLabel;
@property (nonatomic, strong) UILabel    *tipsLabel;
@property (nonatomic, strong) NSDictionary *scrollDic;
@property (nonatomic, strong) NSArray      *timingArr;
@property (nonatomic, strong) NSString   *busStopText;
@property (nonatomic, strong) UICollectionView *timeCollectionView;
@property (nonatomic) int cellType;
@property (nonatomic, assign) id<CarpoolCustomDelegate>myDelegate;

@property (nonatomic, strong) NSString *pathId;
@property (nonatomic, strong) NSString *trainId;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;

@property (nonatomic, assign) int cellState;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSIndexPath *collectionViewIndexPath;
@property (nonatomic, assign) int  indexRow;
@property (nonatomic, assign) BOOL cellIsSelected;
@property (nonatomic, assign) BOOL scrollButtonSelected;
@property (nonatomic, assign) BOOL sameDay;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
