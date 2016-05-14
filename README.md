# MFScanQRDemo
这是一个类似微信扫描二维码的demo ,接下来会持续更新,新增图片识别等

#Usage
-----

```java
_scanQRView =[MFScanQRView scanQRViewWithFrame:CGRectZero withMetadataCallback:^BOOL(NSString *metadata) {
    //这里处理收到的二维码或条形码
    //return BOOL类型,自动判断是否扫码成功,YES为成功,将不会再进入扫码回调,以免过快重复扫码并回调
    //或可以自行调用scanCodeBegin 和scanCodeEnd 重新进入扫码
return YES;

} withAVStatusDeniedCallback:nil];
```