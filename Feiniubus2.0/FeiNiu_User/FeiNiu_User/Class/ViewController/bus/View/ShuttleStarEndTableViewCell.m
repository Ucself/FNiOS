//
//  ShuttleStarEndTableViewCell.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "ShuttleStarEndTableViewCell.h"

@interface ShuttleStarEndTableViewCell()
{
    __weak IBOutlet UIView *starView;
    __weak IBOutlet UIView *endView;
    
//    NSInteger starTag;
//    NSInteger endTag;
    NSInteger changeTag;
}
@end

@implementation ShuttleStarEndTableViewCell

- (void)awakeFromNib {

    [starView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTapStarAction:)]];
    [endView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTapEndAction:)]];
    
//    starTag = 0;
//    endTag = 1;
    changeTag = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


//交换
- (IBAction)clickChangeAction:(UIButton *)sender
{
    NSString *defaultStarString = _startLab.text;
    NSString *defaultEndString =  _endLab.text;
    
    _startLab.text = defaultEndString;
    _endLab.text   = defaultStarString;
    
    sender.selected = !sender.selected;
    if (sender.selected) {
//        starTag = 1;
//        endTag = 0;
        changeTag = 1;
    }else{
//        starTag = 0;
//        endTag = 1;
        changeTag = 0;
    }
        
//    if (_clickChangeAction) {
//        _clickChangeAction(changeTag);
//    }
}

- (void)clickTapStarAction:(UITapGestureRecognizer *)gesture
{
//    if (_clickStartOrEndAction) {
//        _clickStartOrEndAction(changeTag,_startLab.text,_endLab.text);
//    }
    if (_clickStartAction) {
        _clickStartAction(changeTag,_startLab.text);
    }
}

- (void)clickTapEndAction:(UITapGestureRecognizer *)gesture
{
//    if (_clickStartOrEndAction) {
//        _clickStartOrEndAction(changeTag,_startLab.text,_endLab.text);
//    }
    if (_clickEndAction) {
        _clickEndAction(changeTag,_endLab.text);
    }
}



@end
