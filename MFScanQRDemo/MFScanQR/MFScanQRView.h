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



typedef void(^MFMetadataCallback)(AVCaptureOutput *captureOutput, NSArray *metadataObjects, AVCaptureConnection *connection);
typedef void(^MFAVStatusDeniedCallback)(void);



@interface MFScanQRView : UIView
+ (instancetype)scanQRViewWithFrame:(CGRect)frame withMetadataCallback:(MFMetadataCallback)metadataCallback withAVStatusDeniedCallback:(MFAVStatusDeniedCallback)deniedCallback;
- (void)startRunning;

- (void)stopRunning;
@end
@interface MFScanInterestView : UIView
+ (instancetype)scanInterestView;
@end