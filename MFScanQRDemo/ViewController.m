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
    v =[MFScanQRView scanQRViewWithFrame:CGRectMake(0, 0, 300, 300) withMetadataCallback:^(AVCaptureOutput *captureOutput, NSArray *metadataObjects, AVCaptureConnection *connection) {
        
    } withAVStatusDeniedCallback:nil];
    
    [self.view addSubview:v];
    
    [v startRunning];
    
    [self performSelector:@selector(asd) withObject:nil afterDelay:2];
}
- (void)asd{
    v.frame =self.view.bounds;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
