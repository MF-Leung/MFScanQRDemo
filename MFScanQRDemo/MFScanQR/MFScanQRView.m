//
//  MFScanQRView.m
//  MFScanQRDemo
//
//  Created by MF on 16/5/10.
//  Copyright © 2016年 MF. All rights reserved.
//

#import "MFScanQRView.h"
@interface MFScanQRView ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

@property (strong, nonatomic)AVCaptureVideoPreviewLayer * avLayer;

@property (strong, nonatomic)AVCaptureSession *session;

@property (strong, nonatomic)AVCaptureMetadataOutput * output;

@property (strong, nonatomic)CAShapeLayer *mask;

@property (strong, nonatomic)MFScanInterestView *scanInterestView;

@property (strong, nonatomic)MFScanIndicatorView *scanIndicatorView;


@property (strong, nonatomic)MFMetadataCallback metadataCallback;

@property (strong, nonatomic)MFAVStatusDeniedCallback statusDeniedCallback;

@property (nonatomic)BOOL isScanCodeFinish;

@end

@implementation MFScanQRView
+ (instancetype)scanQRViewWithFrame:(CGRect)frame withMetadataCallback:(MFMetadataCallback)metadataCallback withAVStatusDeniedCallback:(MFAVStatusDeniedCallback)statusDeniedCallback{
    
    MFScanQRView *view =[[MFScanQRView alloc] init];
  
    view.backgroundColor =[UIColor blackColor];
    
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
    
    [self addObserver:self forKeyPath:@"bounds" options:(NSKeyValueObservingOptionNew) context:nil];
    
    [self addObserver:self forKeyPath:@"frame" options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    if (self.translatesAutoresizingMaskIntoConstraints ) {
        _avLayer.frame =self.bounds;
    }
        [self updateOutputInterest];

   
}

+(Class)layerClass{
    return [AVCaptureVideoPreviewLayer class];
}
//- (void)updateConstraints{
//    [super updateConstraints];
//    [self updateOutputInterest];
//
//}

- (void)setupAV{
[self avStatusCallback:^(BOOL b) {
    if (b) {
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        _output = [[AVCaptureMetadataOutput alloc]init];
        
        //dispatch_get_main_queue()
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        _session = [[AVCaptureSession alloc]init];
        
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        
        [_session addInput:input];
        
        [_session addOutput:_output];
        
        _output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        //_avLayer =[[AVCaptureVideoPreviewLayer alloc] init];
        _avLayer =self.layer;
        
        
        [_avLayer setSession:_session];
        
        _avLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
        
        //_avLayer.frame=self.layer.bounds;
        
        //[self.layer addSublayer:_avLayer];
        
        _mask = [CAShapeLayer layer];
        [_mask setFillRule:kCAFillRuleEvenOdd];
        [_mask setFillColor:[[UIColor colorWithHue:0.0f saturation:0.0f brightness:0.0f alpha:0.6f] CGColor]];
        [_avLayer addSublayer:_mask];
        
        
        [self updateOutputInterest];
        
        [self setupIndicatorView];
    }
}];
   
    
   
}

- (void)setupIndicatorView{
    _scanIndicatorView =[MFScanIndicatorView scanIndicatorView];
    
    _scanIndicatorView.translatesAutoresizingMaskIntoConstraints =NO;
    
    [self addSubview:_scanIndicatorView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanIndicatorView attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeTop) multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanIndicatorView attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeBottom) multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanIndicatorView attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeLeft) multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanIndicatorView attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeRight) multiplier:1 constant:0]];
    
    [_scanIndicatorView dismiss];
}

- (void)updateOutputInterest{
    CGFloat width =MIN(self.bounds.size.width, self.bounds.size.height)*0.7;
    if (_scanInterestView ==nil) {
        _scanInterestView =[MFScanInterestView scanInterestView];
        _scanInterestView.translatesAutoresizingMaskIntoConstraints =NO;
        
        [self addSubview:_scanInterestView];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanInterestView attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterX) multiplier:1 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_scanInterestView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterY) multiplier:1 constant:0]];
        
        _scanInterestView.widthLayout =[NSLayoutConstraint constraintWithItem:_scanInterestView attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeWidth) multiplier:0 constant:width];
        [self addConstraint:_scanInterestView.widthLayout];
        
        _scanInterestView.heightLayout =[NSLayoutConstraint constraintWithItem:_scanInterestView attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeHeight) multiplier:0 constant:width];
        [self addConstraint:_scanInterestView.heightLayout];

    }else{
        
    NSLayoutConstraint * interestViewWidth = _scanInterestView.widthLayout;
    
    NSLayoutConstraint * interestViewHeight = _scanInterestView.heightLayout;
        
        interestViewWidth.constant =interestViewHeight.constant =width;
        
    }
    
    CGRect rect =CGRectMake( (self.bounds.size.width -width)/2.f, (self.bounds.size.height-width)/2.f, width, width);
    
   // CGRect layerRect = [_avLayer metadataOutputRectOfInterestForRect:rect];
    
    _output.rectOfInterest =CGRectMake(0.1, 0.1, 0.8, 0.8);
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, MAX(self.bounds.size.width, self.bounds.size.height), MAX(self.bounds.size.width, self.bounds.size.height))];
    
    UIBezierPath *cutoutPath;
    
    cutoutPath = [UIBezierPath bezierPathWithRect:rect];
    
    [maskPath appendPath:cutoutPath];
    
    // Set the new path
    _mask.path = maskPath.CGPath;
    
}
- (void)startRunning{
    [_session startRunning];
    [self scanCodeBegin];
}

- (void)stopRunning{
    [_session stopRunning];
    [self scanCodeEnd];
}

- (void)scanCodeBegin{
    _isScanCodeFinish =NO;

}

- (void)scanCodeEnd{
    _isScanCodeFinish =YES;
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
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:@"去设置",nil];
                [alert show];
            }

            callback(NO);
            return;
        }
        else if(authStatus == AVAuthorizationStatusAuthorized){
            callback(YES);
            
        }else if(authStatus == AVAuthorizationStatusNotDetermined){

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

static SystemSoundID shake_sound_male_id = 0;

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    /*
    
    */
    if (self.isScanCodeFinish) {
        return;
    }else{
       
        
        self.isScanCodeFinish =YES;
        
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        
        NSURL *url = [bundle URLForResource:@"MFScanQR" withExtension:@"bundle"];
        
        NSBundle *audioBundle = [NSBundle bundleWithURL:url];
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[audioBundle pathForResource:@"qrcode_found" ofType:@"wav"]],&shake_sound_male_id);
        
        AudioServicesPlaySystemSound(shake_sound_male_id);
    }
    
    AudioServicesPlaySystemSound(shake_sound_male_id);
    
    if (metadataObjects.count>0) {
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];

    [_scanIndicatorView show];
        
    [_scanInterestView stopLineAnimate];
   
    [self performSelector:@selector(callback:) withObject:metadataObject.stringValue afterDelay:1];
   }

}

- (void)callback:(NSString*)metadata{
    BOOL isRight =NO;
    if (self.metadataCallback) {
        isRight =self.metadataCallback(metadata);
    }
    
    if(isRight ==NO){
        [self scanCodeBegin];
        
    }else{
        
        //默认扫描成功后不再进入扫码回调,如需需要连续扫描,请自行调用scanCodeBegin方法
       // [self performSelector:@selector(scanCodeBegin) withObject:nil afterDelay:1];
    }
    
    [_scanIndicatorView dismiss];
    [_scanInterestView startLineAnimate];

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
- (void)dealloc{
    [self stopRunning];
    
    [_scanInterestView stopLineAnimate];
    
    [self removeObserver:self forKeyPath:@"frame" context:nil];

    [self removeObserver:self forKeyPath:@"bounds" context:nil];

}



@end


#pragma mark MFScanInterestView

@interface MFScanInterestView ()
@property (strong, nonatomic)NSLayoutConstraint *lineY;
@property (strong, nonatomic)UIImageView *line;
@end

@implementation MFScanInterestView
+ (instancetype)scanInterestView{
    MFScanInterestView *view =[[MFScanInterestView alloc] init];
    
    [view setup];
    
    [view addObserver:view forKeyPath:@"bounds" options:(NSKeyValueObservingOptionNew) context:nil];


    
    return view;

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    
    if ([_line.layer animationForKey:@"animation"]) {
        [_line.layer removeAllAnimations];
    }
    [self startLineAnimate];
}


- (void)setup{
    self.layer.borderColor =[UIColor whiteColor].CGColor;
    
    self.layer.borderWidth =0.3;
    
    self.backgroundColor =[UIColor clearColor];
    
    UIImageView *imageViewQR1 =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MFScanQR.bundle/ScanQR1_16x16_"]];
    imageViewQR1.translatesAutoresizingMaskIntoConstraints =NO;
    [self addSubview:imageViewQR1];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR1 attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeLeft) multiplier:1 constant:.3]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR1 attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeTop) multiplier:1 constant:.3]];
    

    UIImageView *imageViewQR2 =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MFScanQR.bundle/ScanQR2_16x16_"]];
    imageViewQR2.translatesAutoresizingMaskIntoConstraints =NO;
    [self addSubview:imageViewQR2];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR2 attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeRight) multiplier:1 constant:-.3]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR2 attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeTop) multiplier:1 constant:.3]];
    
    UIImageView *imageViewQR3 =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MFScanQR.bundle/ScanQR3_16x16_"]];
    imageViewQR3.translatesAutoresizingMaskIntoConstraints =NO;
    [self addSubview:imageViewQR3];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR3 attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeLeft) multiplier:1 constant:.3]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR3 attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeBottom) multiplier:1 constant:-.3]];
    

    UIImageView *imageViewQR4 =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MFScanQR.bundle/ScanQR4_16x16_"]];
    imageViewQR4.translatesAutoresizingMaskIntoConstraints =NO;
    [self addSubview:imageViewQR4];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR4 attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeRight) multiplier:1 constant:-.3]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:imageViewQR4 attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeBottom) multiplier:1 constant:-.3]];
    
    _line =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MFScanQR.bundle/ff_QRCodeScanLine_320x12_"]];
    _line.translatesAutoresizingMaskIntoConstraints =NO;
    [self addSubview:_line];
    _lineY=[NSLayoutConstraint constraintWithItem:_line attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeTop) multiplier:1 constant:0];

    [self addConstraint:_lineY];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_line attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeLeft) multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_line attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeRight) multiplier:1 constant:0]];
    //[self layoutIfNeeded];

   // [self performSelector:@selector(startLineAnimate) withObject:nil afterDelay:0.3];
}
- (void)stopLineAnimate{
    
    _line.alpha =1;

    [UIView animateWithDuration:0.5 animations:^{
        _line.alpha =0;
        
    } completion:^(BOOL finished) {
        if ([_line.layer animationForKey:@"animation"]) {
            [_line.layer removeAllAnimations];
        }
        _line.hidden = YES;
        
    }];
    
    
    

}
- (void)startLineAnimate{

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    CGFloat animationDuration = 2;
    
    CGMutablePathRef thePath = CGPathCreateMutable();
    
    CGPathMoveToPoint(thePath, NULL, self.bounds.size.width/2, 0);
    
    CGPathAddLineToPoint(thePath, NULL, self.bounds.size.width/2, 180);
    
    animation.path = thePath;
    
    animation.duration = animationDuration;
    
    animation.beginTime = 0;
    
    animation.repeatCount=CGFLOAT_MAX;
    
    animation.removedOnCompletion=NO;
    
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CGPathRelease(thePath);
    
    [_line.layer addAnimation:animation forKey:@"animation"];
    
    _line.hidden =NO;
    
    _line.alpha =0;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        _line.alpha =1;
        
    } completion:^(BOOL finished) {
    }];
}
- (void)dealloc{
    [self removeObserver:self forKeyPath:@"bounds" context:nil];

}
@end

@interface MFScanIndicatorView ()

@property (strong, nonatomic) UIActivityIndicatorView * indicatorView;
@end

@implementation MFScanIndicatorView

+ (instancetype)scanIndicatorView{
    MFScanIndicatorView *view =[[MFScanIndicatorView alloc] init];
    
    [view setup];
    
    return view;
    
}
- (void)setup{
    
    self.backgroundColor =[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
   _indicatorView =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
    
    _indicatorView.translatesAutoresizingMaskIntoConstraints =NO;
    
    [self addSubview:_indicatorView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_indicatorView attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterX) multiplier:1 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_indicatorView attribute:(NSLayoutAttributeCenterY) relatedBy:(NSLayoutRelationEqual) toItem:self attribute:(NSLayoutAttributeCenterY) multiplier:1 constant:0]];
    
    UILabel *label =[[UILabel alloc] init];
    
    label.font =[UIFont systemFontOfSize:13];
    
    label.textColor =[UIColor whiteColor];
    
    label.text =@"Processing...";
    
    label.translatesAutoresizingMaskIntoConstraints =NO;
    
    [self addSubview:label];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:_indicatorView attribute:(NSLayoutAttributeBottom) multiplier:1 constant:16]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:(NSLayoutAttributeCenterX) relatedBy:(NSLayoutRelationEqual) toItem:_indicatorView attribute:(NSLayoutAttributeCenterX) multiplier:1 constant:0]];

}

- (void)show{
    self.hidden =NO;
    self.alpha =0;

    [UIView animateWithDuration:0.5 animations:^{
        self.alpha =1;
    } completion:^(BOOL finished) {
    }];
    [_indicatorView startAnimating];
}

- (void)dismiss{
    self.alpha =1;

    [UIView animateWithDuration:0.5 animations:^{
        self.alpha =0;
        
    } completion:^(BOOL finished) {
        self.hidden =YES;
        
        [_indicatorView stopAnimating];

    }];
}
@end
