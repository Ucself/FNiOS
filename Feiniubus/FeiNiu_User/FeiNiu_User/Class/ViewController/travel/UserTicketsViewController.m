//
//  UserTicketsViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/5.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "UserTicketsViewController.h"

#define TicketItemIdentifier @"TicketItemIdentifier"

@interface TicketCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ivBackground;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *ivQR;
@property (weak, nonatomic) IBOutlet UIImageView *ivUsedIcon;
@property (weak, nonatomic) IBOutlet UILabel *lbTicketNumber;

@end
@implementation TicketCell



@end

#pragma mark - CoverFlow
@interface CoverFlowLayout : UICollectionViewFlowLayout
@end
@implementation CoverFlowLayout


#define ACTIVE_DISTANCE 200
#define ZOOM_FACTOR 0.3

-(id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

- (void)setup{
    self.itemSize = CGSizeMake(200, 200);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset = UIEdgeInsetsMake(200, 0.0, 200, 0.0);
    self.minimumLineSpacing = 0.0;
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray* array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes* attributes in array) {
        
        CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
        
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            
            CGFloat normalizedDistance = ABS(distance) / self.collectionView.frame.size.width;

            CGFloat scale = 1 - normalizedDistance * 0.3;
            attributes.transform3D = CATransform3DMakeScale(scale, scale, 1);
            attributes.zIndex = 1;
            
        }
    }
    return array;
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}


@end
#pragma mark - 
@interface UserTicketsViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *ivEmpty;

@end

@implementation UserTicketsViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"UserTicketsViewController"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的车票";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)actionClose:(UIButton *)sender {
    [self hide];
}

#pragma mark - Public
- (void)setTickets:(NSArray<BusTicket *> *)tickets{
    self.ivEmpty.hidden = tickets.count != 0;
   _tickets = [tickets sortedArrayUsingComparator:^NSComparisonResult(BusTicket * _Nonnull obj1, BusTicket * _Nonnull obj2) {
        if (obj1.state <= TicketStateValid && obj2.state <= TicketStateValid) {
            return NSOrderedSame;
        }else if (obj1.state == TicketStateValid){
            return NSOrderedAscending;
        }else if (obj2.state == TicketStateValid){
            return NSOrderedDescending;
        }else if (obj1.state == TicketStateUsed && obj2.state == TicketStateUsed){
            return NSOrderedSame;
        }else if (obj1.state == TicketStateUsed){
            return NSOrderedAscending;
        }else if (obj2.state == TicketStateUsed){
            return NSOrderedDescending;
        }else{
            return NSOrderedSame;
        }
    }];
}
- (void)showInViewController:(UIViewController *)vc{
    [vc addChildViewController:self];
    [vc.view addSubview:self.view];
    [self enableBlur:YES];
    self.view.frame = CGRectOffset(vc.view.bounds, 0, vc.view.frame.size.height);
    self.view.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = vc.view.bounds;
    }];
}

- (void)hide{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectOffset(self.view.bounds, 0, self.view.frame.size.height);
    }completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - PrivateMethods
- (CGSize)collectionViewCellSize:(UICollectionView *)collectionView{
    UIImage *image = [UIImage imageNamed:@"tickets_bgd"];
    CGSize size = image.size;
    CGFloat minScale = 220 / 320.f;
    
    if (size.width / collectionView.frame.size.width >= minScale) {
        size.width = collectionView.frame.size.width * minScale;
        size.height = size.width * (image.size.height / image.size.width);
    }
    return size;
}

-(void) blurBuildBlurAndVibrancyViews NS_AVAILABLE_IOS(8_0){
    UIView *view;
    @try {
        UIBlurEffectStyle style = UIBlurEffectStyleDark;
        
        // use UIVisualEffectView
        view = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
        
    }
    @catch (NSException *exception) {
        view = [[UIView alloc]initWithFrame:CGRectZero];
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    }
    @finally {
        if (view == nil) {
            view = [[UIView alloc]initWithFrame:CGRectZero];
            view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        }
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        view.frame = self.view.bounds;
        view.tag = 0x201;
        [self.view insertSubview:view atIndex:0];
    }
    
//    view.contentView.backgroundColor = [UIColor clearColor];
}

-(void)enableBlur:(BOOL) enable{
#ifdef __IPHONE_8_0

    if(enable) {
        UIVisualEffectView* view = (UIVisualEffectView*)[self.view viewWithTag:0x201];
        if(!view) {
            [self blurBuildBlurAndVibrancyViews];
        }
        //        view.barTintColor = [self.blurTintColor colorWithAlphaComponent:0.4f];
    } else {
        UIView* view = [self.view viewWithTag:0x201];
        if (view) {
            [view removeFromSuperview];
        }
    }
#endif
    
}
#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.tickets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TicketCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TicketItemIdentifier forIndexPath:indexPath];
    BusTicket *ticket = self.tickets[indexPath.row];
    cell.lblTitle.text = @"二维码车票";
    cell.lbTicketNumber.text = ticket.serialNumber;

    // 初始状态
    cell.ivUsedIcon.hidden = NO;
    cell.ivUsedIcon.alpha = 1;
    cell.ivQR.alpha = 1;
    cell.lblTitle.alpha = 1;
    
    if (ticket.state <= TicketStateValid) {
        cell.ivUsedIcon.image = [UIImage imageNamed:@"ticket_not_get"];
    }else if (ticket.state == TicketStateUsed){
        cell.ivUsedIcon.image = [UIImage imageNamed:@"ticket_get"];
        cell.ivQR.alpha = 0.5;
        cell.ivUsedIcon.alpha = 0.5;
        cell.lblTitle.alpha = 0.5;
    }else{
        cell.ivUsedIcon.image = [UIImage imageNamed:@"ticket_refund"];
        cell.ivQR.alpha = 0.5;
        cell.ivUsedIcon.alpha = 0.5;
        cell.lblTitle.alpha = 0.5;
    }
    [ticket qrImageStartBlock:^{
        
    } complete:^(UIImage *qrImage) {
        cell.ivQR.image = ticket.qrImage;
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self collectionViewCellSize:collectionView];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    CGFloat marginSide = (collectionView.frame.size.width - [self collectionViewCellSize:collectionView].width) / 2;
    return UIEdgeInsetsMake(0, marginSide, 0, marginSide );
}
//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    float pageWidth = [self collectionViewCellSize:(UICollectionView *)scrollView].width + 10;
//    
//    float currentOffset = scrollView.contentOffset.x;
//    float targetOffset = targetContentOffset->x;
//    float newTargetOffset = 0;
//    
//    if (targetOffset > currentOffset)
//        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth;
//    else
//        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth;
//    
//    if (newTargetOffset < 0)
//        newTargetOffset = 0;
//    else if (newTargetOffset > scrollView.contentSize.width)
//        newTargetOffset = scrollView.contentSize.width;
//    
//    targetContentOffset->x = currentOffset;
//    [scrollView setContentOffset:CGPointMake(newTargetOffset, 0) animated:YES];
//}
@end
