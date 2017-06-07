//
//  DriverScanPassengerViewController.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/9/15.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DriverScanPassengerViewController.h"
#import "ProtocolDriver.h"
#import <AVFoundation/AVFoundation.h>

@interface DriverScanPassengerViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UIView *cameraView;


//扫码使用的属性
@property (strong, nonatomic) AVCaptureDevice            *defaultDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *defaultDeviceInput;
@property (strong, nonatomic) AVCaptureDevice            *frontDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *frontDeviceInput;
@property (strong, nonatomic) AVCaptureMetadataOutput    *metadataOutput;
@property (strong, nonatomic) AVCaptureSession           *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (copy, nonatomic) void (^completionBlock) (NSString *);

@end

@implementation DriverScanPassengerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(void)initInterface
{
    self.navigationItem.title = @"验票";
    
    //设置扫码框
    _boxView.layer.borderWidth = 1.f;
    _boxView.layer.borderColor = [UIColor whiteColor].CGColor;
    //设置扫描线条
    float width = 180.f;
    float height = 1.f;
    float x = (deviceWidth - width)/2.f;
    float y = (deviceHeight - width)/2.f;
    //起始位置
    _lineView.frame = CGRectMake(x, deviceHeight-y, width, height);
    [UIView animateWithDuration:2.5 delay:0.0 options:UIViewAnimationOptionRepeat animations:^{
        
        _lineView.frame = CGRectMake(x,y, width, height);
        
    } completion:nil];
    
}

//加载组建
-(void) initWithComponents
{
    [self setupAVComponents];
    [self configureDefaultComponents];
    
    [_cameraView.layer insertSublayer:self.previewLayer atIndex:0];
}

#pragma mark ---

- (void)setupAVComponents
{
    self.defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (_defaultDevice) {
        self.defaultDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_defaultDevice error:nil];
        self.metadataOutput     = [[AVCaptureMetadataOutput alloc] init];
        self.session            = [[AVCaptureSession alloc] init];
        self.previewLayer       = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        
        for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if (device.position == AVCaptureDevicePositionFront) {
                self.frontDevice = device;
            }
        }
        
        if (_frontDevice) {
            self.frontDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontDevice error:nil];
        }
    }
}

- (void)configureDefaultComponents
{
    [_session addOutput:_metadataOutput];
    
    if (_defaultDeviceInput) {
        [_session addInput:_defaultDeviceInput];
    }
    
    [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if ([[_metadataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
        [_metadataOutput setMetadataObjectTypes:@[ AVMetadataObjectTypeQRCode ]];
    }
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_previewLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
//    if ([_previewLayer.connection isVideoOrientationSupported]) {
//        _previewLayer.connection.videoOrientation = [[self class] videoOrientationFromInterfaceOrientation:self.interfaceOrientation];
//    }
}


- (void)startScanning;
{
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

- (void)stopScanning;
{
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}

#pragma mark --- AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for(AVMetadataObject *current in metadataObjects) {
        if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]
            && [current.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
            
            if (_completionBlock) {
                _completionBlock(scannedResult);
            }
            
//            if (_delegate && [_delegate respondsToSelector:@selector(reader:didScanResult:)]) {
//                [_delegate reader:self didScanResult:scannedResult];
//            }
            
            break;
        }
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
                NSString *resultStatus = [resultParse.data objectForKey:@"resultStatus"];
                if ([resultStatus isEqualToString:@"1"])
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















