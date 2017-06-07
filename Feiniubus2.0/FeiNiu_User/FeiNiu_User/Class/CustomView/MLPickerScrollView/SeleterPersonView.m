//
//  SeleterPersonView.m
//  MLPickerScrollView
//
//  Created by CYJ on 16/3/24.
//  Copyright © 2016年 MelodyLuo. All rights reserved.
//

#import "SeleterPersonView.h"
#import "MLPickerScrollView.h"
#import "MLPersonItem.h"
#import "MLPersonModel.h"

#define kItemW 30
#define kItemH 68

@interface SeleterPersonView()<MLPickerScrollViewDataSource,MLPickerScrollViewDelegate>
{
    __weak IBOutlet UIView *seleterView;
    __weak IBOutlet NSLayoutConstraint *mainViewBottom;

    
    MLPickerScrollView *_pickerScollView;
    NSMutableArray *data;
    UIButton *sureButton;
}
@end

@implementation SeleterPersonView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:@"SeleterPersonView" owner:self options:nil][0];
        self.frame = CGRectMake(0, 0, ScreenW, ScreenH);
        self.backgroundColor = UITranslucentBKColor;

    // 1.数据源
    data = [NSMutableArray array];
    
    //生成选择数据
    NSMutableArray *titleArray = [NSMutableArray new];
    for (int i = 1; i <= 9; i++) {
        [titleArray addObject:[NSString stringWithFormat:@"%d人",i]];
    }
        
    for (int i = 0; i < titleArray.count; i++) {
        MLPersonModel *model = [[MLPersonModel alloc] init];
        model.dicountTitle = [titleArray objectAtIndex:i];
        [data addObject:model];
    }

    // 2.初始化
    _pickerScollView = [[MLPickerScrollView alloc] initWithFrame:CGRectMake(0, 0,seleterView.frame.size.width,seleterView.frame.size.height)];
    _pickerScollView.backgroundColor = [UIColor whiteColor];
    _pickerScollView.itemWidth = self.frame.size.width / 5;
    _pickerScollView.itemHeight = kItemH;
    _pickerScollView.firstItemX = (self.frame.size.width - _pickerScollView.itemWidth) * 0.5;
    _pickerScollView.dataSource = self;
    _pickerScollView.delegate = self;
    [seleterView addSubview:_pickerScollView];

    // 3.刷新数据
    [_pickerScollView reloadData];

    // 4.滚动到对应折扣
//    self.discount = (NSInteger)arc4random()%10;
//    if (self.discount) {
//        NSInteger number;
////        for (int i = 0; i < data.count; i++) {
////            MLDemoModel *model = [data objectAtIndex:i];
////            if (model.dicountIndex == self.discount) {
////                number = i;
////            }
////        }
//         _pickerScollView.seletedIndex = number;
//        [_pickerScollView scollToSelectdIndex:number];
//    }
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        mainViewBottom.constant = 0;
        [view layoutIfNeeded];
    }];
}

#pragma mark - dataSource
- (NSInteger)numberOfItemAtPickerScrollView:(MLPickerScrollView *)pickerScrollView
{
    return data.count;
}

- (MLPickerItem *)pickerScrollView:(MLPickerScrollView *)pickerScrollView itemAtIndex:(NSInteger)index
{
    // creat
    MLPersonItem *item = [[MLPersonItem alloc] initWithFrame:CGRectMake(0, 0, pickerScrollView.itemWidth, pickerScrollView.itemHeight)];
    
    // assignment
    MLPersonModel *model = [data objectAtIndex:index];
    model.dicountIndex = index;
    item.title = model.dicountTitle;
    [item setGrayTitle];
    
    // tap
    item.PickerItemSelectBlock = ^(NSInteger d){
        [_pickerScollView scollToSelectdIndex:d];
    };
    
    return item;
}

#pragma mark - delegate
- (void)itemForIndexChange:(MLPickerItem *)item
{
    [item changeSizeOfItem];
}

- (void)itemForIndexBack:(MLPickerItem *)item
{
    [item backSizeOfItem];
}



- (IBAction)cancleAction:(UIButton *)sender
{
    [UIView animateWithDuration:0.4 animations:^{
        mainViewBottom.constant = - self.frame.size.height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)clickCompleteAction:(UIButton *)sender
{
    if (_clickSeleterPersonCount) {
        _clickSeleterPersonCount(_pickerScollView.seletedIndex + 1);    //下标从0开始
        [self cancleAction:nil];
    }
}

@end
