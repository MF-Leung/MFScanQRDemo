//
//  ViewController.m
//  MFScanQRDemo
//
//  Created by MF on 16/5/10.
//  Copyright © 2016年 MF. All rights reserved.
//

#import "ViewController.h"
#import "MFScanQRView.h"
@interface ViewController ()
@property (strong, nonatomic)MFScanQRView *scanQRView;
@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor =[UIColor blackColor];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _scanQRView =[MFScanQRView scanQRViewWithFrame:CGRectZero withMetadataCallback:^BOOL(NSString *metadata) {
        
        return YES;
        
    } withAVStatusDeniedCallback:nil];
    _scanQRView.isAnimation =YES;
    _scanQRView.translatesAutoresizingMaskIntoConstraints =NO;
    [self.view addSubview:_scanQRView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_scanQRView attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeLeft) multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_scanQRView attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeRight) multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_scanQRView attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeTop) multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_scanQRView attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeBottom) multiplier:1 constant:0]];
    
    [_scanQRView startRunning];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
  
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            [(AVCaptureVideoPreviewLayer*)_scanQRView.avLayer connection].videoOrientation =AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [(AVCaptureVideoPreviewLayer*)_scanQRView.avLayer connection].videoOrientation =AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [(AVCaptureVideoPreviewLayer*)_scanQRView.avLayer connection].videoOrientation =AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            [(AVCaptureVideoPreviewLayer*)_scanQRView.avLayer connection].videoOrientation =AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            break;
    }
   // _scanQRView.frame =self.view.bounds;
}

@end
