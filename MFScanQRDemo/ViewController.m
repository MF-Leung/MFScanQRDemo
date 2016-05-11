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

@end

@implementation ViewController
MFScanQRView *v;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    v =[MFScanQRView scanQRViewWithFrame:self.view.bounds withMetadataCallback:^(AVCaptureOutput *captureOutput, NSArray *metadataObjects, AVCaptureConnection *connection) {
        
    } withAVStatusDeniedCallback:nil];
  // v.translatesAutoresizingMaskIntoConstraints =NO;
    [self.view addSubview:v];

//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeLeft) multiplier:1 constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeRight) multiplier:1 constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeTop) multiplier:1 constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:v attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self.view attribute:(NSLayoutAttributeBottom) multiplier:1 constant:0]];
//    
//    [v updateConstraintsIfNeeded];
    [v startRunning];
    
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            [(AVCaptureVideoPreviewLayer*)v.avLayer connection].videoOrientation =AVCaptureVideoOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [(AVCaptureVideoPreviewLayer*)v.avLayer connection].videoOrientation =AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            [(AVCaptureVideoPreviewLayer*)v.avLayer connection].videoOrientation =AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            [(AVCaptureVideoPreviewLayer*)v.avLayer connection].videoOrientation =AVCaptureVideoOrientationLandscapeRight;
            break;
        default:
            break;
    }
    v.frame =self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
