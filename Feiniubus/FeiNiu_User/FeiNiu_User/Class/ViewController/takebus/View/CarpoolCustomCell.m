//
//  CarpoolCustomCell.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/12/8.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolCustomCell.h"
#import "CustomCollectionViewCell.h"
#import <FNUIView/FNUIView.h>
#import "UIColor+Hex.h"
#import "NSDate+FSExtension.h"

#define CustomGrayColor [UIColor colorWithHex:[@(0xefefef) integerValue]].CGColor
#define CustomColor [UIColor colorWithRed:253/255.0 green:120/255.0 blue:34/255.0 alpha:1]



@interface CarpoolCustomCell ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSString *timingTimerStr;

@end

@implementation CarpoolCustomCell

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        
    }
    
    return self;
}

- (void)layoutSubviews{
    
    //左边线条
    _leftLine = [[UIView alloc] init];
    [_leftLine setBounds:CGRectMake(0, 0, self.frame.size.width/4, 1)];
    [_leftLine setCenter:CGPointMake(self.center.x - _leftLine.frame.size.width - 10, 20)];
    [_leftLine setBackgroundColor:CustomColor];
    [self addSubview:_leftLine];
    
    //右边线条
    _rightLine = [[UIView alloc] init];
    [_rightLine setBounds:CGRectMake(0, 0, self.frame.size.width/4, 1)];
    [_rightLine setCenter:CGPointMake(self.center.x + _rightLine.frame.size.width + 10, 20)];
    [_rightLine setBackgroundColor:CustomColor];
    [self addSubview:_rightLine];
    
    //车站名
    _busStopTitle = [[UILabel alloc] init];
    [_busStopTitle setText:_busStopText];
    [_busStopTitle setBounds:CGRectMake(0, 0, self.frame.size.width/4 + 10, 30)];
    [_busStopTitle setCenter:CGPointMake(self.center.x, 20)];
    [_busStopTitle setTextColor:CustomColor];
    [_busStopTitle setTextAlignment:NSTextAlignmentCenter];
    [_busStopTitle setFont:[UIFont systemFontOfSize:15]];
//    [_busStopTitle.layer setBorderColor:CustomColor.CGColor];
//    [_busStopTitle.layer setBorderWidth:1.0];
//    [_busStopTitle.layer setCornerRadius:5.0];
    [_busStopTitle setAdjustsFontSizeToFitWidth:YES];
    [_busStopTitle setMinimumScaleFactor:0.1];
    [self addSubview:_busStopTitle];
    
    if (_cellType == 3) {
        
        _scrollButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_scrollButton setFrame:CGRectMake(_leftLine.frame.origin.x, 35, self.frame.size.width/3 - 40, 30)];
        [_scrollButton setTitle:@"滚动班" forState:UIControlStateNormal];
        [_scrollButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_scrollButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_scrollButton.layer setCornerRadius:5];
        [_scrollButton.layer setBorderColor:[UIColor colorWithHex:[@(0xefefef) integerValue]].CGColor];
        [_scrollButton.layer setBorderWidth:1];
        
        if (_scrollButtonSelected == YES) {
            [_scrollButton setTitleColor:CustomColor forState:UIControlStateNormal];
            [_scrollButton.layer setBorderColor:CustomColor.CGColor];
        }
        
        [_scrollButton addTarget:self action:@selector(scrollButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_scrollButton];
        
        _trainId   = (NSString *)_scrollDic[@"trainId"];
        _startTime = [(NSString *)_scrollDic[@"startTime"] substringToIndex:5];
        _endTime   = [(NSString *)_scrollDic[@"endTime"]   substringToIndex:5];
    
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        [_timeLabel setText:[NSString stringWithFormat:@"%@-%@有效", _startTime, _endTime]];
        [_timeLabel setCenter:CGPointMake(self.center.x, 50)];
        [_timeLabel setTextAlignment:NSTextAlignmentCenter];
        [_timeLabel setTextColor:[UIColor grayColor]];
        [_timeLabel setFont:[UIFont systemFontOfSize:14]];
        [_timeLabel setAdjustsFontSizeToFitWidth:YES];
        [_timeLabel setMinimumScaleFactor:0.5];
        [self addSubview:_timeLabel];
        
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100,30)];
        [_tipsLabel setCenter:CGPointMake(self.center.x + _timeLabel.frame.size.width/2 + 35, 50)];
        [_tipsLabel setText:[NSString stringWithFormat:@"(%@)", _scrollDic[@"comment"]]];
        [_tipsLabel setTextColor:[UIColor grayColor]];
        [_tipsLabel setTextAlignment:NSTextAlignmentLeft];
        [_tipsLabel setFont:[UIFont systemFontOfSize:14]];
        [_tipsLabel setAdjustsFontSizeToFitWidth:YES];
        [_tipsLabel setMinimumScaleFactor:0.1];
        [self addSubview:_tipsLabel];
        
    }else{
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        int height = 0;
        
        
        
        height = (int)(_timingArr.count - 1)/3 + 1;
        
        if (_timingArr.count == 0) {
            height = 0;
        }
        
//        for (int i = 1; ; i++) {
//            
//            if (_timingArr.count/3.0 <= i) {
//                
//                height = i;
//                break;
//            }
//        }

        _timeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(_leftLine.frame.origin.x, 40,self.frame.size.width * 3/4 + 20,height * 40) collectionViewLayout:flowLayout];
        [_timeCollectionView setScrollEnabled:NO];
        [_timeCollectionView setBackgroundColor:[UIColor clearColor]];
        [_timeCollectionView setDelegate:self];
        [_timeCollectionView setDataSource:self];
        
        [_timeCollectionView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell"
                                                        bundle: [NSBundle mainBundle]]
                                    forCellWithReuseIdentifier:@"collectcell"];
        
        [self addSubview:_timeCollectionView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCellColor:) name:@"changecellcolor" object:nil];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -- function methods

- (int)stringFromInt:(NSString *)timer{
    
    NSString *hourString = [timer substringToIndex:2];
    NSString *miniString = [timer substringFromIndex:3];
    
    int totalTime = [hourString intValue] * 60 + [miniString intValue];//总分钟数
    
    return totalTime;
}

- (void)runningDelegateMethod{
    
    if ([self.myDelegate respondsToSelector:@selector(CarpoolCustomCellCallBack:trainId:startTime:endTime:cellType:timeStr:cellState:indexPath:collectionIndex:buttonSelected:cellSelected:)]) {
        
        [self.myDelegate CarpoolCustomCellCallBack:_pathId
                                           trainId:_trainId
                                         startTime:_startTime
                                           endTime:_endTime
                                          cellType:_cellType
                                           timeStr:_timingTimerStr
                                         cellState:_cellState
                                         indexPath:_indexPath
                                   collectionIndex:_collectionViewIndexPath
                                    buttonSelected:_scrollButtonSelected
                                      cellSelected:_cellIsSelected];
    }
    
//    [self deinitView];
}

#pragma mark -- tips

- (void)popPromptView:(NSString *)text{

    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:self.superview];
    [self.superview addSubview:hud];
    [hud show:YES];
    [hud setDetailsLabelText:text];
    [hud setMode:MBProgressHUDModeText];
    [hud hide:YES afterDelay:2];
    if (hud.hidden == YES) {
        [hud removeFromSuperview];
    }
}

#pragma mark -- button event

- (void)changeCellColor:(NSNotification *)notification{
    
    if (_indexPath == notification.object[@"index"]) {
        
        CustomCollectionViewCell *cell1 = (CustomCollectionViewCell *)[_timeCollectionView cellForItemAtIndexPath:_collectionViewIndexPath];
        
        if (cell1) {
            
            [cell1.timeLabel setTextColor:CustomColor];
            [cell1.layer setBorderColor:CustomColor.CGColor];
            [cell1.layer setBorderWidth:1.0];
        }
    }
}

- (void)scrollButtonClick:(UIButton *)sender{
    
    _scrollButtonSelected = YES;
    _cellIsSelected       = NO;
    
    [sender setTitleColor:CustomColor forState:UIControlStateNormal];
    [sender.layer setBorderColor:CustomColor.CGColor];
    
    [self runningDelegateMethod];
}

#pragma mark -- UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
        return 1;
}
    
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [_timingArr count];
}
    
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    _timingTimerStr = [_timingArr[indexPath.row][@"time"] substringToIndex:5];
    
    static NSString *cellId = @"collectcell";

    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    [cell.timeLabel setText:[_timingArr[indexPath.row][@"time"] substringToIndex:5]];
    
    [cell setCellState:[_timingArr[indexPath.row][@"state"] intValue]];
    
    [cell.layer setMasksToBounds:YES];
    [cell.layer setCornerRadius:5];
    [cell.layer setBorderWidth:1];
    [cell.layer setBorderColor:[UIColor colorWithHex:[@(0xefefef) integerValue]].CGColor];
    
    if (_collectionViewIndexPath == indexPath && _cellIsSelected) {
        
        [cell.timeLabel setTextColor:CustomColor];
        [cell.layer setBorderColor:CustomColor.CGColor];
        [cell.layer setBorderWidth:1.0];
        
        return cell;
    }
    
    return cell;
}

#pragma mark -- UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake((collectionView.frame.size.width-20)/3, 30);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _scrollButtonSelected = NO;
    _cellIsSelected       = YES;
    
    CustomCollectionViewCell *cell1 = (CustomCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (_sameDay) {
        
        NSString *timeString = [NSDate formatDate:[NSDate date] format:@"HH.ss"];
        
        int timeValue = [self stringFromInt:timeString];
        int cellTimeValue = [self stringFromInt:cell1.timeLabel.text];
        //
        if (cellTimeValue - timeValue <= 60 && cellTimeValue - timeValue > 0) {
            
            [self popPromptView:@"该班次需要提前60分钟预订"];
            return;
        }
        
    }
    
    
    _cellState = cell1.cellState;

    if (cell1 == nil) {
        return;
    }
    
    if (_cellState != 1) {
        
        cell1.timeLabel.textColor = [UIColor grayColor];
        [cell1.layer setBorderColor:CustomGrayColor];
        [cell1.layer setBorderWidth:1];

        [self popPromptView:@"该班次车票已售完, 或者该班次需要提前60分钟预订"];

        return;
    }

    //选中不同的cell
    if (_collectionViewIndexPath != indexPath) {
        
        CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[collectionView cellForItemAtIndexPath:_collectionViewIndexPath];

        if (cell == nil) {
            cell = (CustomCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
        }

        cell.timeLabel.textColor = [UIColor grayColor];
        [cell.layer setBorderColor:CustomGrayColor];
        [cell.layer setBorderWidth:1];

        CustomCollectionViewCell *cellNew = (CustomCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

        cellNew.timeLabel.textColor = CustomColor;

        [cellNew.layer setBorderColor:CustomColor.CGColor];
        [cellNew.layer setBorderWidth:1];
        
        _collectionViewIndexPath = indexPath;
        
        @try {
            _timingTimerStr = cell1.timeLabel.text;
            _trainId = (NSString *)_timingArr[indexPath.row][@"id"];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
        
    }else{
        //选中的是已选中的cell
        @try {
            _timingTimerStr = cell1.timeLabel.text;
            _trainId = (NSString *)_timingArr[_collectionViewIndexPath.row][@"id"];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
    
    [self runningDelegateMethod];

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
//    
//    return 0;
//}

//- layoutAttributesForElementsInRect



@end
