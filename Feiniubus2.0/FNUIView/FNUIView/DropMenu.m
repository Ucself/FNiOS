//
//  DropMenu.m
//  FNUIView
//
//  Created by 易达飞牛 on 15/8/17.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DropMenu.h"
#import <QuartzCore/QuartzCore.h>


#define KItemHeight     35

@interface DropMenu () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    int oriHeight;
    int menuHeight;
    BOOL showMenu;
}

@property(nonatomic, assign) UIView *parentView;

@property(nonatomic, strong) UIView *backgoundView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) UIImageView *img;

@property(nonatomic, strong) NSArray *items;
@end

@implementation DropMenu

-(instancetype)initWithItems:(NSArray*)items parentView:(UIView*)parentView
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        //self.backgroundColor = [UIColor clearColor];
        
        self.parentView = parentView;
        
        self.items = [NSArray arrayWithArray:items];
        menuHeight = (int)items.count * KItemHeight;
        oriHeight = 30;
        //self.clipsToBounds = YES;
        [self initUI];
    }
    
    return self;
}

-(void)initUI
{
    _label = [[UILabel alloc] init];
    _label.textColor = [UIColor darkGrayColor];
    _label.font = [UIFont systemFontOfSize:15];
    _label.text = @"测试";
    [self addSubview:_label];
    
    _img = [[UIImageView alloc] initWithFrame:CGRectZero];
    _img.backgroundColor = [UIColor grayColor];
    [self addSubview:_img];
    

    _backgoundView = [[UIView alloc] initWithFrame:CGRectZero];
    _backgoundView.backgroundColor = [UIColor clearColor];
    [self.parentView addSubview:_backgoundView];
    
    UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackGround:)];
    gesture.delegate = self;
    [_backgoundView addGestureRecognizer:gesture];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_backgoundView addSubview:_tableView];
    
    //将图层的边框设置为圆脚
    _tableView.layer.cornerRadius = 5;
    _tableView.layer.masksToBounds = YES;
    //给图层添加一个有色边框
    _tableView.layer.borderWidth = 0.6;
    _tableView.layer.borderColor = [UIColorFromRGB(0xcdcdcd) CGColor];
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0.6;
    self.layer.borderColor = [UIColorFromRGB(0xcdcdcd) CGColor];

}

-(void)layoutSubviews
{
    CGRect rt = self.bounds;
    rt.origin.x = 10;
    rt.size.width = self.bounds.size.width - 10;
    _label.frame = rt;
    
    _img.frame = CGRectMake(self.bounds.size.width-20, 5, 20, 20);
    
    //转换坐标
    rt = [self.superview convertRect:self.frame toView:self.parentView];
    _backgoundView.frame = rt;
    
}

#pragma mark-
-(void)setText:(NSString*)text
{
    self.label.text = text;
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // 输出点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

- (void)tapBackGround:(UITapGestureRecognizer *)paramSender
{
    showMenu = !showMenu;
    if (showMenu) {
        [self.parentView bringSubviewToFront:_backgoundView];
        self.backgoundView.frame = self.parentView.bounds;
        
        //初始menu位置
        CGRect rt = [self.superview convertRect:self.frame toView:self.parentView];;
        rt.origin.y += rt.size.height+5;
        rt.size.height = 0;
        _tableView.frame = rt;
        
        //显示menu
        rt.size.height = self.items.count * KItemHeight;
        [UIView animateWithDuration:0.3 animations:^{
            self.tableView.frame = rt;
        }];
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect temp = _tableView.frame;
            temp.size.height = 0;
            _tableView.frame = temp;
        } completion:^(BOOL finished) {
            CGRect rt = [self.superview convertRect:self.frame toView:self.parentView];
            self.backgoundView.frame = rt;
        }];
    }
}

#pragma mark-
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ident = @"dropmenucellident";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
    }
    
    cell.textLabel.text = self.items[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self tapBackGround:nil];
     
    if ([self.delegate respondsToSelector:@selector(dropMenu:selectedIndex:)]) {
        [self.delegate dropMenu:self selectedIndex:(int)(indexPath.row)];
    }
}

@end
