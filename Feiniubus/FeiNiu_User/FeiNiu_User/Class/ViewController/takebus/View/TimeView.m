//
//  TimeView.m
//  FeiNiu_User
//
//  Created by iamdzz on 15/10/19.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "TimeView.h"
#import <FNUIView/FNUIView.h>

@interface TimeView ()


@end

@implementation TimeView

+ (instancetype)sharedInstance{
    
    TimeView *view = [[[NSBundle mainBundle] loadNibNamed:@"TimeView" owner:self options:nil] firstObject];

    return view;
}


- (void)layoutSubviews{
    
    [self initButton];
}


- (void)awakeFromNib{
    
    
}

#pragma mark -- init interface property

- (void)initButton{
    
    int y = 0;
    
    for (int i = 0; i < 5; i++) {
        
//        NSString *time = [_timeDataSource[i][@"time"] substringToIndex:5];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button setTag:i];
        [button.layer setBorderColor:[UIColor grayColor].CGColor];
        [button.layer setBorderWidth:1];
        [button.layer setCornerRadius:5];
        [button setTitle:@"hello" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(timeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        if (i == 3) {
            
            [button makeConstraints:^(MASConstraintMaker *make) {
                
                make.leading.equalTo(50 + (i-3) * 80);
                make.width.equalTo(70);
                make.top.equalTo(self.timeLabel.height + 100);
                make.height.equalTo(30);
            }];
            
        }else{
           
            [button makeConstraints:^(MASConstraintMaker *make) {
                
                make.leading.equalTo(50 + i * 80);
                make.width.equalTo(70);
                make.top.equalTo(self.timeLabel.height + 50 );
                make.height.equalTo(30);
            }];
        }
    }
}



- (void)initCollectionView{
    
    [_timeCollectionView setDelegate:self];
    [_timeCollectionView setDataSource:self];

}

#pragma mark -- Button Event

- (void)timeButtonPressed:(UIButton *)sender{

    sender.selected = !sender.selected;
    
    sender.selected ? [sender.layer setBorderColor:[UIColor greenColor].CGColor] : [sender.layer setBorderColor:[UIColor grayColor].CGColor];

}

- (IBAction)OKButtonPressed:(id)sender {
    

}

- (IBAction)cancelButtonPressed:(id)sender {
    
}


#pragma mark -- collectionview delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark -- collectionview datasouce

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [_timeDataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * cellId = @"collectionviewid";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    if (!cell) {
        
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    }
    
    [cell setBackgroundColor:[UIColor redColor]];
    
    return cell;
}


#pragma mark -- collectionview flowlayout


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    
    return CGSizeMake(5, 5);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    return nil;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
