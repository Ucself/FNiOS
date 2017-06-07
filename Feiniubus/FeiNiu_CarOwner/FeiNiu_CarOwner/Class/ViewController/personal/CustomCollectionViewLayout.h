//
//  CustomCollectionViewLayout.h
//  2015-03-12-CustomUICollectionViewLayout
//


#import <UIKit/UIKit.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@class CustomCollectionViewLayout;

@protocol CustomCollectionViewLayoutDelegate <NSObject>

@required
- (CGSize)collectionView:(UICollectionView *)collectionView collectionViewLayout:(CustomCollectionViewLayout *)collectionViewLayout sizeOfItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CustomCollectionViewLayout : UICollectionViewLayout

@property (assign, nonatomic) id<CustomCollectionViewLayoutDelegate> layoutDelegate;

@end