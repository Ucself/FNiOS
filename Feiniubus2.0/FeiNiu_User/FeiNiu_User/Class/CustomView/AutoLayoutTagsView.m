//
//  TagView.m
//  FeiNiu_User
//
//  Created by tianbo on 16/6/1.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "AutoLayoutTagsView.h"
#import <FNCommon/NSString+CalculateSize.h>



#if TARGET_INTERFACE_BUILDER
@implementation AutoLayoutTagsView(IBExtension)
-(void)setEnabled:(BOOL)enabled
{
    self.isEnabled = enabled;
}
@end
#endif

@interface AutoLayoutTagsView()

@property (nonatomic,copy) NSMutableArray *items;
@property (nonatomic,copy) NSMutableDictionary *itemsDic;

@end

@implementation AutoLayoutTagsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)init
{
    self = [super init];
    if (self) { }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

-(void)addItems:(NSArray*)items
{
    //数据源
    _items = items.mutableCopy;
    int top = 0;
    int left = 5;
    UIView *previous = nil;
    for (int i=0; i<items.count; i++) {
        //数据源
        NSDictionary *dataSourceDic = items[i];
        NSString *text = dataSourceDic[@AutoLayoutTagsViewKeyName];
        BOOL isSelected = dataSourceDic[@AutoLayoutTagsViewKeySelected];
        //设置图片
        UIImage *image = isSelected ? [UIImage imageNamed:@"icon_round_pressed"] : [UIImage imageNamed:@"icon_round"];
        
        int width = [text widthWithFont:[UIFont systemFontOfSize:14] constrainedToHeight:25] + 15 + 20;
        //添加选中和未选中按钮
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = 1001; // 标示tag方便后面查找
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 2000; //设置tag 方便点击查找
        [btn addSubview:imageView];
        [imageView makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(22);
            make.height.equalTo(22);
            make.centerY.equalTo(btn);
            make.right.equalTo(btn);
        }];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:text forState:UIControlStateNormal];
        //左对齐
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0); //左边10个像素
        
        [btn setTitleColor:UITextColor_Black forState:UIControlStateNormal];
        [btn setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];

        btn.layer.cornerRadius = 12.5;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = UIColorFromRGB(0xBBBBBF).CGColor;
        
        if (previous) {
            int scope = self.frame.size.width - previous.frame.origin.x - previous.frame.size.width - 10;
            if (scope > width) {
                left = previous.frame.origin.x + previous.frame.size.width +5;
            }
            else {
                previous = nil;
                left = 5;
                top += 30;
            }
        }
        
        btn.frame = CGRectMake(left, top, width, 25);
        
        [self addSubview:btn];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        previous = btn;
    }
}

-(int)addItemsDictionary:(NSDictionary*)items{
    //数据源
    _itemsDic = items.mutableCopy;
    int top = 0;
    int left = 5;
    int lineRet = 1;
    if (_itemsDic.count == 0) {
        lineRet = 0;
    }
    UIView *previous = nil;
    for (NSString *item in _itemsDic.allKeys) {
        //数据源
        NSString *text = item;
        bool isSelected = [_itemsDic[text] boolValue];
        //设置图片
        UIImage *image = isSelected ? [UIImage imageNamed:@"icon_round_pressed"] : [UIImage imageNamed:@"icon_round"];
        
        int width = [text widthWithFont:[UIFont systemFontOfSize:14] constrainedToHeight:25] + 15 + 20;
        //添加选中和未选中按钮
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = 1001; // 标示tag方便后面查找
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.selected = isSelected;   //设置按钮选中状态
        btn.tag = 2000; //设置tag 方便点击查找
        [btn addSubview:imageView];
        [imageView makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(22);
            make.height.equalTo(22);
            make.centerY.equalTo(btn);
            make.right.equalTo(btn).offset(-3);
        }];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitle:text forState:UIControlStateNormal];
        //左对齐
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0); //左边10个像素
        
        [btn setTitleColor:UITextColor_Black forState:UIControlStateNormal];
        [btn setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        
        btn.layer.cornerRadius = 12.5;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = UIColorFromRGB(0xBBBBBF).CGColor;
        
        if (previous) {
            int scope = self.frame.size.width - previous.frame.origin.x - previous.frame.size.width - 10;
            if (scope > width) {
                left = previous.frame.origin.x + previous.frame.size.width +5;
            }
            else {
                previous = nil;
                left = 5;
                top += 34;
                lineRet++;
            }
        }
        
        btn.frame = CGRectMake(left, top, width, 25);
        
        [self addSubview:btn];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        previous = btn;
    }
    
    return lineRet;
}

-(void)removeAll
{
    for (UIView *view in self.subviews) {
        if (view) {
            [view removeFromSuperview];
        }
    }
}

-(void)setIsEnabled:(BOOL)isEnabled
{
    _isEnabled = isEnabled;
}

- (UIImage*)imageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
    
}


-(void)btnClick:(id)sender
{
    if (!_isEnabled) {
        return;
    }
    //改变界面样式
    UIButton *btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    UIImageView *imageView = [btn viewWithTag:1001];
    imageView.image = btn.selected ? [UIImage imageNamed:@"icon_round_pressed"]:[UIImage imageNamed:@"icon_round"];
    //更新数据源
    int selectIndex = (int)btn.tag - 2000;
    //传入数组的数据源
    if (_items != nil) {
        NSMutableDictionary *tempDic = _items[selectIndex];
        [tempDic setObject:@(btn.selected) forKey:@AutoLayoutTagsViewKeySelected];
        _items[selectIndex] = tempDic;
        if (self.selectChangeAction) {
            self.selectChangeAction(_items);
        }
    }
    //传入的字典数据源
    if (_itemsDic != nil){
        NSString *key = btn.currentTitle;
        _itemsDic[key] = @(btn.selected);
        if (self.selectChangeActionDic) {
            self.selectChangeActionDic(_itemsDic);
        }
    }
    
}
@end



