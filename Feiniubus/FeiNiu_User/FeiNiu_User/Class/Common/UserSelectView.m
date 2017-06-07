//
//  UserSelectView.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/3.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserSelectView.h"

@implementation UserSelectView
- (void)setType:(SelectType)type{
    [super setType:type];
    if (self.type == SelectType_Image) {
        self.labelTitle.text = @"选择头像";
        [self.btn1 setTitle:@"拍照" forState:UIControlStateNormal];
        [self.btn2 setTitle:@"本地图片" forState:UIControlStateNormal];
    }
    else {
        self.labelTitle.text = @"选择性别";
        [self.btn1 setTitle:@"男" forState:UIControlStateNormal];
        [self.btn2 setTitle:@"女" forState:UIControlStateNormal];
    }
}
@end
