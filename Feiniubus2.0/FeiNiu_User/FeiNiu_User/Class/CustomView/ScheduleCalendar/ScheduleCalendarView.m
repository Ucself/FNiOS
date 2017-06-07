//
//  ScheduleCalendarView.m
//  FeiNiu_User
//
//  Created by tianbo on 16/5/26.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "ScheduleCalendarView.h"
#import "CalendarUtils.h"
#import "CalendarCollectionViewCell.h"
#import "CalendarHeaderView.h"
#import "FeiNiu_User-Swift.h"

#import "String+Price.h"

@interface ScheduleCalendarView () <UICollectionViewDataSource,UICollectionViewDelegate>


//日历控件
@property (nonatomic,strong)UICollectionView * collcetionView;


//日历控件天数
@property (nonatomic,strong)NSMutableArray * daysArray;

//时间
@property (nonatomic,strong)NSDate * today ;

@end

@implementation ScheduleCalendarView

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
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initMonthDays];
        [self initCollcetionView];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initMonthDays];
        [self initCollcetionView];

    }
    return self;
}

-(void)initCollcetionView
{
    CalendarHeaderView *head = [[CalendarHeaderView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 24)];
    [self addSubview:head];

    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init] ;
    //设置collectionView的滑动方向
    //UICollectionViewScrollDirectionVertical 垂直滑动   默认滑动方向
    //UICollectionViewScrollDirectionHorizontal 水平滑动
    //    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //在垂直方向  设置的是cell上下之间的最小间距 在水平方向  设置的是cell左右之间的最小间距
    flowLayout.minimumLineSpacing = 0 ;
    //在垂直方向  设置的是cell左右之间的最小间距 在水平方向  设置的是cell上下之间的最小间距
    flowLayout.minimumInteritemSpacing = 0 ;
    //设置collectionViewCell的大小
    
    flowLayout.itemSize = CGSizeMake(ScreenWidth/7, 44);
    flowLayout.headerReferenceSize = CGSizeMake(ScreenWidth, 0) ;
    flowLayout.footerReferenceSize = CGSizeMake(ScreenWidth, 1) ;

    _collcetionView  =[[ UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collcetionView.allowsMultipleSelection = YES;
    _collcetionView.scrollEnabled = NO;
    _collcetionView.backgroundColor = [UIColor clearColor];
    _collcetionView.delegate = self ;
    _collcetionView.dataSource =self ;
    [_collcetionView registerClass:[CalendarCollectionViewCell class] forCellWithReuseIdentifier:@"collectionViewCell"] ;
    [self addSubview:_collcetionView];
    
    [_collcetionView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(head.bottom);
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        make.bottom.equalTo(self.bottom);
    }];
    
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectZero];
    line2.backgroundColor = UIColorFromRGB(0xe6e6e6);
    [self addSubview:line2];
    [line2 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left);
        make.right.equalTo(self.right);
        make.bottom.equalTo(self.bottom);
        make.height.equalTo(.5);
    }];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self showSaleDay];
}

#pragma mark -
-(void)setArTickets:(NSArray *)arTickets
{
    _arTickets = arTickets;
    
    //将车票信息加入数据源
    for (NSMutableDictionary *dict in self.daysArray) {
        if (![dict isKindOfClass:[NSMutableDictionary class]]) {
            continue;
        }
        
        for (TicketInfo *ticket in arTickets) {
            NSDate *date = [DateUtils stringToDate:ticket.date];
            if ([DateUtils isSameDay:date date2:dict[@"date"]] ) {
                [dict setObject:ticket forKey:@"ticket"];
                break;
            }
        }
        
    }
    [self.collcetionView reloadData];
    
    [self showSaleDay];
}

-(NSArray*) getSelectDays
{
    NSMutableArray *days = [NSMutableArray arrayWithCapacity:0];
    NSArray *indexPaths = [self.collcetionView indexPathsForSelectedItems];
    
    for (NSIndexPath *indexPath in indexPaths) {
        NSDictionary *dict = [_daysArray objectAtIndex:indexPath.row];
        if (dict[@"ticket"]) {
            TicketInfo *ticket = dict[@"ticket"];
            [days addObject:ticket.date];
        }
    }
    
    [days sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDate *d1 = [DateUtils dateFromString:obj1 format:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *d2 = [DateUtils dateFromString:obj2 format:@"yyyy-MM-dd HH:mm:ss"];
        
        return [d1 compare:d2];
    }];

    return days;
}

-(NSArray*)getSelectItems
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
    NSArray *indexPaths = [self.collcetionView indexPathsForSelectedItems];
    
    for (NSIndexPath *indexPath in indexPaths) {
        NSDictionary *dict = [_daysArray objectAtIndex:indexPath.row];
        if (dict[@"ticket"]) {
            [items addObject:dict[@"ticket"]];
        }
    }
    
    return items;
}

#pragma mark - 初始化当前时间
-(void)showSaleDay
{
//    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//    
//    NSString * date = [formatter stringFromDate:[NSDate date]];

    
    if (!self.arTickets || self.arTickets.count == 0) {
        return;
    }
    
    TicketInfo *ticket = self.arTickets[0];
    NSDate *firstDay  = [DateUtils stringToDate:ticket.date];
    
    for (int i=0; i<self.daysArray.count; i++) {
        if ([self.daysArray[i] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = self.daysArray[i];
            NSDate *date = dict[@"date"];
            if ([DateUtils isSameDay:firstDay date2:date]) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.collcetionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                
                break;
            }
        }
        
    }
}

#pragma mark - 计算选定月份天数
-(void)initMonthDays
{
//    [CalendarUtils lastMonthDays];
//    [CalendarUtils firstWeekdayInLastMonth];
    _daysArray = [NSMutableArray array];
    
    //SLog(@"%@",self.today);
    
    //上个月
    NSInteger days = [CalendarUtils lastMonthDays];//[CalendarUtils totaldaysInThisMonth:[NSDate date] with:_date];
    NSInteger week  = [CalendarUtils firstWeekdayInLastMonth];//[CalendarUtils firstWeekdayInThisMonth:[NSDate date] with:_date];

//    NSInteger weeks;
//    if ((days + week) % 7 > 0)
//    {
//        weeks = (days + week)/7 + 1 ;
//    }
//    else
//    {
//        weeks = (days + week)/7 ;
//    }
    
    NSDate *date = [CalendarUtils firstDayInLastMonth];

    for (int i  = 0; i < (days + week); i ++)
    {
        if ( i - week < 0)
        {
            [_daysArray addObject:@" "];
        }
        else
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"date": date,
                                          @"index": [NSString stringWithFormat:@"%ld",i+1-week]}];
            [_daysArray addObject:dict];
            date = [NSDate dateWithTimeInterval:24*60*60 sinceDate:date];
            
        }
        
        
        //NSLog(@"%@",_daysArray[i]);
        
    }
    
    //这个月
    days = [CalendarUtils totaldaysInThisMonth:[NSDate date] with:nil];
    for (int i  = 0; i < days; i ++)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"date": date,
                                      @"index": [NSString stringWithFormat:@"%d",i+1]}];
        [_daysArray addObject:dict];
        date = [NSDate dateWithTimeInterval:24*60*60 sinceDate:date];
    }
    
    
    //下个月
    days = [CalendarUtils nextMonthDays];
    for (int i  = 0; i < days; i ++)
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"date": date,
                                      @"index": [NSString stringWithFormat:@"%d",i+1]}];
        [_daysArray addObject:dict];
        date = [NSDate dateWithTimeInterval:24*60*60 sinceDate:date];
    }
    
    [_collcetionView reloadData];
    
    
    //NSLog(@"这个月有%ld天 , 第一天是%ld",days,week);
    
     
}


#pragma mark ---UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%ld",_daysArray.count);
    return _daysArray.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    CalendarCollectionViewCell * cell = [_collcetionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell" forIndexPath:indexPath];

    if (cell == nil)
    {
        cell = [[CalendarCollectionViewCell alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth/7, 44)];
        
    }

    if ([[_daysArray objectAtIndex:indexPath.row] isKindOfClass:[NSMutableDictionary class]]) {
        NSDictionary *dict = [_daysArray objectAtIndex:indexPath.row];
        cell.dateLabel.text = dict[@"index"];
        
        
        if (self.arTickets) {
            if (dict[@"ticket"]) {
                cell.detailLable.hidden = NO;
                cell.dateLabel.textColor = UITextColor_Black;
                
                TicketInfo *ticket = dict[@"ticket"];
                if ([ticket.ticket_state isEqualToString:@"CanBuy"]) {
                    cell.detailLable.hidden = NO;
                    cell.detailLable.backgroundColor = UIColor_DefOrange;
                    cell.detailLable.textColor = [UIColor whiteColor];
                    //设置价格
                    if (ticket.activity_price > 0) {
                        //有活动价
                        cell.detailLable.text = [NSString calculatePrice:ticket.activity_price];
                    }
                    else{
                        //原价
                        cell.detailLable.text = [NSString calculatePrice:ticket.price];
                    }
                    
                    if (cell.detailLable.text.length >= 4) {
                        cell.detailLable.font = [UIFont systemFontOfSize:9];
                    }
                    else {
                        cell.detailLable.font = [UIFont systemFontOfSize:12];
                    }
                }
                else if ([ticket.ticket_state isEqualToString:@"Bought"]) {
                    cell.detailLable.hidden = NO;
                    cell.detailLable.backgroundColor = UITextColor_DarkGray;
                    cell.detailLable.textColor = [UIColor whiteColor];
                    cell.detailLable.text = @"已买";
                    cell.detailLable.font = [UIFont systemFontOfSize:11];
                }
                else if ([ticket.ticket_state isEqualToString:@"SoldOut"]) {
                    cell.detailLable.hidden = NO;
                    cell.detailLable.backgroundColor = UIColorFromRGB(0xd0d0d4);
                    cell.detailLable.textColor = [UIColor whiteColor];
                    cell.detailLable.text = @"售罄";
                    cell.detailLable.font = [UIFont systemFontOfSize:11];
                }
                else if ([ticket.ticket_state isEqualToString:@"NoSale"]) {
                    cell.detailLable.hidden = YES;
                    cell.detailLable.font = [UIFont systemFontOfSize:11];
                }
                else if ([ticket.ticket_state isEqualToString:@"Conflict"]) {
                    cell.detailLable.hidden = NO;
                    cell.detailLable.backgroundColor = UITextColor_DarkGray;
                    cell.detailLable.textColor = [UIColor whiteColor];
                    cell.detailLable.text = @"冲突";
                    cell.detailLable.font = [UIFont systemFontOfSize:11];
                }
                
                
            }
            else {
                cell.detailLable.hidden = YES;
                cell.dateLabel.textColor = UITextColor_LightGray;
            }
            

        }
        
    }
    else {
        cell.dateLabel.text = @"";
    }

    return cell ;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_daysArray objectAtIndex:indexPath.row];
    if (dict[@"ticket"]) {
        TicketInfo *ticket = dict[@"ticket"];
        if ([ticket.ticket_state isEqualToString:@"CanBuy"]) {
            return YES;
        }
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarCollectionViewCell * cell = (CalendarCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];

    //[cell setNeedsLayout];
    cell.selectView.hidden = NO;
    cell.dateLabel.textColor = [UIColor whiteColor];
    cell.detailLable.backgroundColor = [UIColor whiteColor];
    cell.detailLable.textColor = UIColor_DefOrange;
    
    if ([self.delegate respondsToSelector:@selector(calendarViewSelectItems:)]) {
        [self.delegate calendarViewSelectItems:[self getSelectItems]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarCollectionViewCell * cell = (CalendarCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    //[cell setNeedsLayout];
    cell.selectView.hidden = YES;
    cell.dateLabel.textColor = [UIColor darkTextColor];
    cell.detailLable.backgroundColor = UIColor_DefOrange;
    cell.detailLable.textColor = [UIColor whiteColor];
    
    if ([self.delegate respondsToSelector:@selector(calendarViewSelectItems:)]) {
        [self.delegate calendarViewSelectItems:[self getSelectItems]];
    }
}


@end
