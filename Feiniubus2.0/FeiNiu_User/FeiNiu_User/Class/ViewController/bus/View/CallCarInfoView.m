//
//  CallCarInfoView.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CallCarInfoView.h"

@interface CallCarInfoView()
{
     UILabel *infoLab;
     UIView *infoView;
}

@end

@implementation CallCarInfoView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _rangs = [NSMutableArray new];
        
        infoView = [[UIView alloc] init];
        [self addSubview:infoView];
        [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.right.equalTo(0);
            make.height.equalTo(50);
            make.top.equalTo(0);
        }];
        
        UIImageView *backGroundImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bounced"]];
        [infoView addSubview:backGroundImg];
        [backGroundImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(0);
            make.right.equalTo(0);
            make.bottom.equalTo(0);
            make.top.equalTo(0);
        }];
        
        infoLab = [[UILabel alloc] init];
        infoLab.numberOfLines = 1;
        infoLab.font = [UIFont systemFontOfSize:12];
        infoLab.textAlignment = NSTextAlignmentCenter;
        [infoView addSubview:infoLab];
        [infoLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(5);
            make.right.equalTo(infoView.right).offset(-5);
            make.bottom.equalTo(0);
            make.top.equalTo(0);
        }];
    
        
        UIImageView *locationImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mylocation"]];
        [self addSubview:locationImg];
        [locationImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(20);
            make.height.equalTo(34);
            make.centerX.equalTo(self.centerX);
            make.top.equalTo(infoView.bottom).offset(0);
        }];
        
        [self configView];
    }
    return self;
}


- (void)configView
{
    if (_infoString && _infoString.length > 0) {
        
        NSAttributedString *attribute = [NSString hintMainString:_infoString rangs:[_rangs mutableCopy] defaultColor:[UIColor blackColor] changeColor:[UIColor redColor]];
        infoLab.attributedText =  attribute;
        [infoLab sizeToFit];
                
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:infoLab.font,
                                     NSParagraphStyleAttributeName:paragraphStyle.copy};
        CGSize labelSize = [_infoString boundingRectWithSize:CGSizeMake(240, 20)
                                                         options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                      attributes:attributes
                                                         context:nil].size;
        
        
        
//        infoLab.frame = CGRectMake(0, 0, infoView.width.view.fs_width, infoView.width.view.fs_height);
//        self.fs_width = labelSize.width + 20;
//        self.fs_centerX = self.superview.fs_centerX;
        [self layoutIfNeeded];
    }
}

- (void)setRangs:(NSMutableArray *)rangs
{
    _rangs = rangs;
    if (rangs) {
        [self configView];
    }
}

- (void)setInfoString:(NSString *)infoString
{
    _infoString = infoString;
    
    if (!infoString || infoString.length == 0) {
        self.hidden = YES;
    }else{
        self.hidden = NO;
    }

    infoLab.text = infoString;
}

@end
