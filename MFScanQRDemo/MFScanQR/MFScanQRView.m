//
//  MFScanQRView.m
//  MFScanQRDemo
//
//  Created by MF on 16/5/10.
//  Copyright © 2016年 MF. All rights reserved.
//

#import "MFScanQRView.h"
@interface MFScanQRView ()<AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic)AVCaptureVideoPreviewLayer * avLayer ;
@property (strong, nonatomic)AVCaptureSession *session;
@property (strong, nonatomic)AVCaptureMetadataOutput * output;
@property (strong, nonatomic)CAShapeLayer *mask;
@property (strong, nonatomic)MFScanInterestView *scanInterestView;
@property(strong, nonatomic)MFMetadataCallback metadataCallback;
@property(strong, nonatomic)MFAVStatusDeniedCallback statusDeniedCallback;
@end

@implementation MFScanQRView
+ (instancetype)scanQRViewWithFrame:(CGRect)frame withMetadataCallback:(MFMetadataCallback)metadataCallback withAVStatusDeniedCallback:(MFAVStatusDeniedCallback)statusDeniedCallback{
    MFScanQRView *view =[[MFScanQRView alloc] init];
    
    [view setupWithFrame:frame withMetadataCallback:metadataCallback withAVStatusDeniedCallback:statusDeniedCallback];
    
    return view;
}

- (void)setupWithFrame:(CGRect)frame withMetadataCallback:(MFMetadataCallback)metadataCallback withAVStatusDeniedCallback:(MFAVStatusDeniedCallback)statusDeniedCallback{
    
    self.frame =frame;
    
    [self setupWithMetadataCallback:metadataCallback withAVStatusDeniedCallback:statusDeniedCallback];
}

- (void)setupWithMetadataCallback:(MFMetadataCallback)metadataCallback withAVStatusDeniedCallback:(MFAVStatusDeniedCallback)statusDeniedCallback{
    
    self.metadataCallback =metadataCallback;
    
    self.statusDeniedCallback =statusDeniedCallback;
    [self setupAV];
    
    [self addObserver:self forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (![NSStringFromCGRect(_avLayer.frame) isEqualToString:NSStringFromCGRect(self.bounds)]&& self.translatesAutoresizingMaskIntoConstraints) {
        _avLayer.frame =self.bounds;
        [self updateOutputInterest];

    }
}
- (void)updateConstraints{
    [self updateOutputInterest];
    [super updateConstraints];
}
- (void)setupAV{
[self avStatusCallback:^(BOOL b) {
    if (b) {
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        _output = [[AVCaptureMetadataOutput alloc]init];
        
        //dispatch_get_main_queue()
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_global_queue(0, 0)];
        
        _session = [[AVCaptureSession alloc]init];
        
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        
        [_session addInput:input];
        
        [_session addOutput:_output];
        
        _output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        _avLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
        
        _avLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
        
        _avLayer.frame=self.layer.bounds;
        
        [self.layer addSublayer:_avLayer];
        
        _mask = [CAShapeLayer layer];
        [_mask setFillRule:kCAFillRuleEvenOdd];
        [_mask setFillColor:[[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.2f] CGColor]];
        [_avLayer addSublayer:_mask];
        
        
        [self updateOutputInterest];
        
        
    }
}];
   
    
   
}


- (void)updateOutputInterest{
    if (_scanInterestView ==nil) {
        _scanInterestView =[MFScanInterestView scanInterestView];
        _scanInterestView.translatesAutoresizingMaskIntoConstraints =NO;
        
        [self addSubview:_scanInterestView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanInterestView attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterX) multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanInterestView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterY) multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanInterestView attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeWidth) multiplier:0 constant:MIN(self.frame.size.width, self.frame.size.height)*0.6]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanInterestView attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeHeight) multiplier:0 constant:MIN(self.frame.size.width, self.frame.size.height)*0.6]];

    }
    
    CGRect rect =CGRectMake( 60, (self.bounds.size.height-self.frame.size.width -120 )/2, self.frame.size.width -120, self.frame.size.width -120);
    
    CGRect layerRect = [_avLayer metadataOutputRectOfInterestForRect:rect];
    
    _output.rectOfInterest =layerRect;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:_avLayer.bounds];
    
    UIBezierPath *cutoutPath;
    
    cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    
    [maskPath appendPath:cutoutPath];
    
    // Set the new path
    _mask.path = maskPath.CGPath;
    
}
- (void)startRunning{
    [_session startRunning];
}

- (void)stopRunning{
    [_session stopRunning];

}
- (void)avStatusCallback:(void(^)(BOOL b))callback{

    if(__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0) {
        
        NSString *mediaType = AVMediaTypeVideo;
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];

        if(authStatus ==AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){

            if (self.statusDeniedCallback) {
                self.statusDeniedCallback();

            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。"
                                                               delegate:nil
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            // The user has explicitly denied permission for media capture.
            callback(NO);
            return;
        }
        else if(authStatus == AVAuthorizationStatusAuthorized){
            callback(YES);
            
        }else if(authStatus == AVAuthorizationStatusNotDetermined){
            // Explicit user permission is required for media capture, but the user has not yet granted or denied such permission.
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                if(granted){
                    callback(YES);

                    //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                    NSLog(@"Granted access to %@", mediaType);
                }
                else {
                    callback(NO);

                    NSLog(@"Not granted access to %@", mediaType);
                }
                
            }];
        }else {
            callback(NO);

            NSLog(@"Unknown authorization status");
        }  
    }
    
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
//    if (metadataObjects.count>0) {
//        //[session stopRunning];
//        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
//        //输出扫描字符串
//        NSLog(@"%@",metadataObject.stringValue);
//    }
    if (self.metadataCallback) {
        self.metadataCallback(captureOutput, metadataObjects, connection);
    }
}


- (void)dealloc{
    [self removeObserver:self forKeyPath:@"frame" context:nil];
}



@end


#pragma mark MFScanInterestView

@interface MFScanInterestView ()

@end

@implementation MFScanInterestView
+ (instancetype)scanInterestView{
    MFScanInterestView *view =[[MFScanInterestView alloc] init];
    [view setup];
    return view;
}

- (void)setup{
    self.backgroundColor =[UIColor clearColor];
    NSBundle *bundle = [NSBundle bundleForClass:self.class];

    NSURL *url = [bundle URLForResource:@"MFScanQR" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    NSString *path = [imageBundle pathForResource:@"ScanQR1_16x16_" ofType:@"png"];
    
    UIImageView *imageViewQR1 =[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
    imageViewQR1.translatesAutoresizingMaskIntoConstraints =NO;
    [self addSubview:imageViewQR1];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR1 attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeLeft) multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR1 attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeTop) multiplier:1 constant:0]];
    
    path = [imageBundle pathForResource:@"ScanQR2_16x16_" ofType:@"png"];

    UIImageView *imageViewQR2 =[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
    imageViewQR2.translatesAutoresizingMaskIntoConstraints =NO;
    [self addSubview:imageViewQR2];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR2 attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeRight) multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR2 attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeTop) multiplier:1 constant:0]];
    
    path = [imageBundle pathForResource:@"ScanQR3_16x16_" ofType:@"png"];

    UIImageView *imageViewQR3 =[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
    imageViewQR3.translatesAutoresizingMaskIntoConstraints =NO;
    [self addSubview:imageViewQR3];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR3 attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeLeft) multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR3 attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeBottom) multiplier:1 constant:0]];
    
    path = [imageBundle pathForResource:@"ScanQR4_16x16_" ofType:@"png"];

    UIImageView *imageViewQR4 =[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
    imageViewQR4.translatesAutoresizingMaskIntoConstraints =NO;
    [self addSubview:imageViewQR4];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR4 attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeRight) multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR4 attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeBottom) multiplier:1 constant:0]];
    
}

@end


