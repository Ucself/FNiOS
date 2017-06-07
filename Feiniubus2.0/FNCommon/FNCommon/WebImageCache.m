//
//  ImageCache.m
//  FNCommon
//
//  Created by tianbo on 2017/5/11.
//  Copyright © 2017年 feiniu.com. All rights reserved.
//

#import "WebImageCache.h"
@interface WebImageCache()
{
    
}
@property (nonatomic, strong) NSString *folder;
@end

@implementation WebImageCache

+(WebImageCache*)instance
{
    static WebImageCache *instance = nil;
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        instance = [WebImageCache new];
    });
    
    return instance;
}


-(instancetype)init
{
    self = [super init];
    if (self) {
        self.folder = @"WebImageCache";
    }
    return self;
}

-(void)setFolder:(NSString*)folder
{
    _folder = folder;
}

-(void)saveImage:(NSString*)url name:(NSString*)name success:(void(^)(BOOL success))block
{
//    __weak typeof(self)weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        __strong typeof(self)strongSelf = weakSelf;
//        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData:data];
        NSString *path = [self pathInCacheDirectory:self.folder];
    
        NSString *imageType = @"jpg";
        //从url中获取图片类型
        NSArray *arr = [url componentsSeparatedByString:@"."];
        if (arr) {
            imageType = [arr objectAtIndex:arr.count-1];
        }
    
        BOOL bSave = NO;
        if ([self createDirInCache:self.folder]) {
            bSave = [self saveImageToCacheDir:path image: image imageName:name imageType:imageType];
        }
    
        block(bSave);

//    });
}

-(UIImage*)loadImageWithName:(NSString*)name
{
    NSData *data = [self loadImageData:[self pathInCacheDirectory:self.folder] imageName:name];
    return [UIImage imageWithData:data];
}

//创建缓存文件夹
-(BOOL) createDirInCache:(NSString *)dirName
{
    NSString *imageDir = [self pathInCacheDirectory:dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    BOOL isCreated = NO;
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed) {
        isCreated = YES;
    }
    return isCreated;
}

// 删除图片缓存
- (BOOL) deleteDirInCache:(NSString *)dirName
{
    NSString *imageDir = [self pathInCacheDirectory:dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    bool isDeleted = false;
    if ( isDir == YES && existed == YES )
    {
        isDeleted = [fileManager removeItemAtPath:imageDir error:nil];
    }
    
    return isDeleted;
}

// 图片本地缓存
- (BOOL) saveImageToCacheDir:(NSString *)directoryPath  image:(UIImage *)image imageName:(NSString *)imageName imageType:(NSString *)imageType
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    bool isSaved = false;
    if ( isDir == YES && existed == YES )
    {
        if ([[imageType lowercaseString] isEqualToString:@"png"])
        {
            isSaved = [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:imageName] options:NSAtomicWrite error:nil];
        }
        else if ([[imageType lowercaseString] isEqualToString:@"jpg"] || [[imageType lowercaseString] isEqualToString:@"jpeg"])
        {
            isSaved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:imageName] options:NSAtomicWrite error:nil];
        }
        else
        {
            DBG_MSG(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", imageType);
        }
    }
    return isSaved;
}

// 获取缓存图片
-(NSData*) loadImageData:(NSString *)directoryPath imageName:( NSString *)imageName
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirExisted = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if ( isDir == YES && dirExisted == YES )
    {
        NSString *imagePath = [directoryPath stringByAppendingPathComponent: imageName];
        BOOL fileExisted = [fileManager fileExistsAtPath:imagePath];
        if (!fileExisted) {
            return NULL;
        }
        NSData *imageData = [NSData dataWithContentsOfFile : imagePath];
        return imageData;
    }
    else
    {
        return NULL;
    }
}

-(NSString* )pathInCacheDirectory:(NSString *)fileName
{
    NSString *cachePath = nil;
    static dispatch_once_t once;
    static NSString *stCachePath = nil;
    dispatch_once(&once, ^{
        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        stCachePath = [cachePaths objectAtIndex:0];
    });
    
    cachePath = stCachePath;
    return [cachePath stringByAppendingPathComponent:fileName];
}


@end
