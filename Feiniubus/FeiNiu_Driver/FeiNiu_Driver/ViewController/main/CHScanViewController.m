//
//  CHScanViewController.m
//  CHWaterCleaner
//
//  Created by Nick on 15/5/22.
//  Copyright (c) 2015年 ChangHong. All rights reserved.
//

#import "CHScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ProtocolDriver.h"

@interface CHScanViewController ()<AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>
{
    NSTimer          *timerMoveScanLine;
    BOOL             isScanning;//正在扫描
}
@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UIView *boxView;

@property (strong, nonatomic) CALayer *scanLayer;

@property (nonatomic, strong) void (^finishBlock)(NSString *result);
//捕捉会话
@property (nonatomic, strong) AVCaptureSession *captureSession;
//展示layer
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@end

@implementation CHScanViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _captureSession = nil;
    isScanning = NO;
    //设置tite 名称
    self.navigationItem.title = @"验票";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self readingSet];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)dealloc
{
    _captureSession = nil;
    [_scanLayer removeFromSuperlayer];
    [_videoPreviewLayer removeFromSuperlayer];
    [timerMoveScanLine invalidate];
}

#pragma mark ----
- (void)readingSet {
    NSError *error;
    //1.初始化捕捉设备（AVCaptureDevice），类型为AVMediaTypeVideo
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //2.用captureDevice创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        DBG_MSG(@"%@", [error localizedDescription]);
        return;
    }
    //3.创建媒体数据输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    //4.实例化捕捉会话
    _captureSession = [[AVCaptureSession alloc] init];
    //4.1.将输入流添加到会话
    [_captureSession addInput:input];
    //4.2.将媒体输出流添加到会话中
    [_captureSession addOutput:captureMetadataOutput];
    //5.创建串行队列，并加媒体输出流添加到队列当中
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    //5.1.设置代理
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    //5.2.设置输出媒体数据类型为QRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    //6.实例化预览图层
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    //7.设置预览图层填充方式
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    //8.设置图层的frame
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    //9.将图层添加到预览view的图层上
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    //10.设置扫描范围
//    captureMetadataOutput.rectOfInterest = CGRectMake(0.2f, 0.2f, 0.8f, 0.8f);
    //10.1.扫描框
//    _boxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _viewPreview.bounds.size.width, _viewPreview.bounds.size.height)];
//    _boxView.layer.borderColor = [UIColor greenColor].CGColor;
//    _boxView.layer.borderWidth = 1.0f;
//    [_viewPreview addSubview:_boxView];
    //10.2.扫描线
    _scanLayer = [[CALayer alloc] init];
    _scanLayer.frame = CGRectMake(0, 0, _boxView.bounds.size.width, 1);
    _scanLayer.backgroundColor = [UIColor greenColor].CGColor;
    [_boxView.layer addSublayer:_scanLayer];
    timerMoveScanLine = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(moveScanLayer:) userInfo:nil repeats:YES];
    
    //10.开始扫描
    [self startReading];
    return;
}

- (void)moveScanLayer:(NSTimer *)timer
{
    CGRect frame = _scanLayer.frame;
    if (_boxView.frame.size.height <= _scanLayer.frame.origin.y) {
        frame.origin.y = 0;
        _scanLayer.frame = frame;
    }else{
        frame.origin.y += 5;
        [UIView animateWithDuration:0 animations:^{
            _scanLayer.frame = frame;
        }];
    }
}
//开始扫描
-(void)startReading
{
    isScanning = YES;
    [timerMoveScanLine setFireDate:[NSDate date]];
    [_captureSession startRunning];
}

//暂停扫描
-(void)stopReading:(NSString *) info
{
    isScanning = NO;
    [timerMoveScanLine setFireDate:[NSDate distantFuture]];
    [_captureSession stopRunning];
    DBG_MSG(@"result : %@", info);
    if (self.finishBlock) {
        self.finishBlock(info);
    }
    //验票请求,服务器验票
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:info forKey:@"serialNumber"];
    [requestDic setObject:_driverTaskModel.scheduleId forKey:@"scheduleId"];
    [self startWait];
    [[ProtocolDriver sharedInstance] postInforWithNSDictionary:requestDic urlSuffix:Kurl_carpoolOrderDriverTask requestType:KRequestType_carpoolrderDriverTask];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (!isScanning) {
        return;
    }
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self performSelectorOnMainThread:@selector(stopReading:) withObject:[metadataObj stringValue] waitUntilDone:NO];
        }
    }
}

#pragma mark -- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1001:
        {
            //验票的请求
            if (buttonIndex == 0)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else if (buttonIndex == 1)
            {
                [self startReading];
            }
        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark --- http request handler
/**
 *  请求返回成功
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultParse = (ResultDataModel *)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_carpoolrderDriverTask:
        {
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"" delegate:self cancelButtonTitle:@"验票完成" otherButtonTitles:@"继续验票", nil];
            alerView.tag = 1001;
            if (resultParse.resultCode == 0)
            {
                int resultStatus = [[resultParse.data objectForKey:@"resultStatus"] intValue];
                if (resultStatus == 1)
                {
                    alerView.message = @"验票成功";
                }
                else
                {
                    alerView.message = @"验票失败";
                }
            }
            else
            {
                alerView.message = @"验票失败";
            }
            
            [alerView show];
        }
            break;
            
        default:
            break;
    }
    
}
/**
 *  请求返回失败
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}


@end
