//
//  MFScanQRView.h
//  MFScanQRDemo
//
//  Created by MF on 16/5/10.
//  Copyright © 2016年 MF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>



typedef BOOL(^MFMetadataCallback)(NSString *metadata);
typedef void(^MFAVStatusDeniedCallback)(void);


@class MFScanInterestView;
@class MFScanIndicatorView;

@interface MFScanQRView : UIView
@property (strong, nonatomic, readonly)AVCaptureVideoPreviewLayer * avLayer ;

@property (strong, nonatomic, readonly)AVCaptureSession *session;

@property (strong, nonatomic, readonly)AVCaptureMetadataOutput * output;

@property (strong, nonatomic, readonly)CAShapeLayer *mask;

@property (strong, nonatomic, readonly)MFScanInterestView *scanInterestView;

@property (strong, nonatomic, readonly)MFScanIndicatorView *scanIndicatorView;

@property(strong, nonatomic, readonly)MFMetadataCallback metadataCallback;

@property(strong, nonatomic, readonly)MFAVStatusDeniedCallback statusDeniedCallback;

@property (nonatomic)BOOL isAnimation;

+ (instancetype)scanQRViewWithFrame:(CGRect)frame withMetadataCallback:(MFMetadataCallback)metadataCallback withAVStatusDeniedCallback:(MFAVStatusDeniedCallback)deniedCallback;

- (void)startRunning;


- (void)stopRunning;

- (void)scanCodeBegin;

- (void)scanCodeEnd;

@end


#pragma mark MFScanInterestView

@interface MFScanInterestView : UIView

@property(strong, nonatomic) NSLayoutConstraint *widthLayout;

@property(strong, nonatomic) NSLayoutConstraint *heightLayout;

+ (instancetype)scanInterestView;

- (void)stopLineAnimate:(BOOL)b;

- (void)startLineAnimate;
@end


#pragma mark MFScanIndicatorView

@interface MFScanIndicatorView : UIView

+ (instancetype)scanIndicatorView;

- (void)show:(BOOL)animation;

- (void)dismiss:(BOOL)animation;

@end
