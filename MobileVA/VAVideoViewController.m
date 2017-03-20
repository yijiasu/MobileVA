//
//  VAVideoViewController.m
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "FDSmoother.h"
#import "VAVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import <PureLayout/PureLayout.h>

const float FACE_DISAPPEAR_TOLERANCE_TIME = 0.1;

@interface VAVideoViewController () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, FDSmootherDataDelegate>

@property (weak, nonatomic) IBOutlet UIView *videoView;

// AVFoundation
@property (nonatomic, strong) AVCaptureSession * captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput * deviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillOutput;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;                   // Queue for metadata processing
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;    // Preview Layer
@property (nonatomic, strong) CAShapeLayer *roiLayer;                           // Overlay Layer for Face ROI
@property CGRect lastRect;                                                      // Last Rect Region of Face
@property double lastFaceAppearTime;                                            // Last Face Appear Time (Base on CACurrentTime())
@property BOOL isCaptureSessionConfigured;

// Data Smoother
@property (nonatomic, strong) FDSmoother *smoother;
@property BOOL isSmoothEnabled;

// Web View
@property (nonatomic, strong) UIWebView *webView;                               // WebView For Donut
@property (nonatomic, strong) UIView *touchView;                                // Touch View
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;                  // JS Bridge For WebView

@property (nonatomic, strong) NSTimer *trackingFrameRefreshTimer;


// Data Model

@property (nonatomic, strong) VAEgoPerson *currentEgoPerson;

@property BOOL isUsingTouchView;
@property float radius;

@end

@implementation VAVideoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.type = VAViewControllerTypeVideo;
    
    self.dataModel = [VAUtil util].model;
    [self configureData];
}

- (void)viewDidLayoutSubviews
{
    [self configureWebView];
    self.videoPreviewLayer.frame = self.webView.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startCaptureSession];
    [self startWebView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)configureData
{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        if ([_captureSession canSetSessionPreset:AVAssetExportPreset1280x720]) {
            [_captureSession setSessionPreset:AVAssetExportPreset1280x720];
        }
        
    }
    
    if (!_smoother) {
        _smoother = [[FDSmoother alloc] initWithMAWindowSizeForSize:12 location:10];
        _smoother.delegate = self;
    }
    
    if (!_trackingFrameRefreshTimer) {
        _trackingFrameRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(checkTrackingFrame:) userInfo:nil repeats:YES];
    }
    
    _lastFaceAppearTime = 0;
    _isUsingTouchView = NO;
    
    
    // Add Frame Observe
    [self addObserver:self forKeyPath:@"view.frame" options:kNilOptions context:NULL];
}

- (void)configureWebView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:_videoView.frame];
        _webView.delegate = self;
        _webView.opaque = NO;
        _webView.backgroundColor = [UIColor clearColor];
        
//        _webView.scrollView.scrollEnabled = NO;
        _webView.scrollView.bounces = NO;
    
        
        [self registerJSHandler];
        [self.view addSubview:_webView];
        
        [_webView autoPinEdgesToSuperviewEdges];
        if (_isUsingTouchView) {
            _touchView = [[UIView alloc] initWithFrame:_webView.frame];
            [self.view addSubview:_touchView];
            
            UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
            [_touchView addGestureRecognizer:pgr];
            
            _webView.userInteractionEnabled = NO;
        }
    }

}


- (void)startWebView
{
    if (_currentEgoPerson) {
        NSString *urlString = [[VAService defaultService] URLWithComponent:@"pie.html"
                                                                     width:CGRectGetWidth(_videoView.frame)
                                                                    height:CGRectGetHeight(_videoView.frame)
                                                                    params:@{@"egoname" : _currentEgoPerson.name}];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: urlString]]];

//        [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.location=%@", urlString]];
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: urlString]]];
////        });
    }
}


- (void)checkTrackingFrame:(NSTimer *)timer
{
    BOOL shouldHideFrame = fabs(_lastFaceAppearTime - CACurrentMediaTime()) > FACE_DISAPPEAR_TOLERANCE_TIME;
    if (shouldHideFrame) {
        if (_webView.alpha != 0) {
            [UIView animateWithDuration:0.3f animations:^{
                _roiLayer.opacity = 0;
                _webView.alpha = 0;
            }];
        }
    }
    else
    {
        if (_webView.alpha == 0) {
            [UIView animateWithDuration:0.3f delay:0.3f options:0
                             animations:^{
                                 _webView.alpha = 1;
                             } completion:nil];
        }
    }
    
}


- (void)startCaptureSession
{
    if (_isCaptureSessionConfigured) {
        return;
    }
    
    _isCaptureSessionConfigured = YES;
    
    AVCaptureDevice *videoDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
    NSError *error;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if ( !error ) {
        [self setDeviceInput:videoInput];
    } else {
        NSLog(@"Could not open input port for device %@ (%@)", videoDevice, [error localizedDescription]);
        return;
    }
    
    if ( [self.captureSession canAddInput:videoInput] ) {
        [self.captureSession addInput:videoInput];
    } else {
        NSLog(@"Could not add input port to capture session %@", self.captureSession);
        return;
    }
    
    // Add output
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    _dispatchQueue = dispatch_queue_create("metadataQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:_dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeFace]];
    
    
    // Add Video Output
    
    
    AVCaptureVideoDataOutput * captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    
    // (2) The sample buffer delegate requires a serial dispatch queue
    dispatch_queue_t queue;
    queue = dispatch_queue_create("videoQueue", DISPATCH_QUEUE_SERIAL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
    // (3) Define the pixel format for the video data output
    NSString * key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber * value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    //    NSNumber * value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
    
    
    NSDictionary * settings = @{key:value};
    [captureOutput setVideoSettings:settings];
    
    // (4) Configure the output port on the captureSession property
    [self.captureSession addOutput:captureOutput];
    
    // Add Preview Layer
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_videoView.layer.bounds];
    [_videoPreviewLayer setMasksToBounds:YES];
    [_videoView.layer addSublayer:_videoPreviewLayer];
    
    
    
    [_captureSession startRunning];
    
    // Add ROI Layer
    
    _roiLayer = [[CAShapeLayer alloc] init];
    [_roiLayer setFrame:_videoView.layer.bounds];
//    [_roiLayer setMasksToBounds:YES];
    [_videoView.layer addSublayer:_roiLayer];
    
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice * device in devices ) {
        if ( [device position] == position ) {
            return device;
        }
    }
    return nil;
}

#pragma mark Delegate For AVFoundation

- (void)        captureOutput:(AVCaptureOutput *)captureOutput
     didOutputMetadataObjects:(NSArray *)metadataObjects
               fromConnection:(AVCaptureConnection *)connection
{

    
    dispatch_async(dispatch_get_main_queue(), ^{
        AVMetadataObject *avmo = [metadataObjects firstObject];
        AVMetadataObject *transformedMetadata = [_videoPreviewLayer transformedMetadataObjectForMetadataObject:avmo];
        _lastFaceAppearTime = CACurrentMediaTime();
        [self.smoother inputData:@[[NSValue valueWithCGRect:transformedMetadata.bounds]]];
    });
    
}

- (void)smootherDidOutputSingleData:(CGRect)rectData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _lastRect = rectData;
        [self drawROIPath:rectData];
        [self refreshVis:@[[NSValue valueWithCGRect:rectData]]];
//        [self tryCropImage: rectData];
    });
    
}



- (void)drawROIPath:(CGRect)roiRect
{
    _roiLayer.path = [UIBezierPath bezierPathWithRoundedRect:roiRect cornerRadius:2.0f].CGPath;
    _roiLayer.fillColor = [UIColor clearColor].CGColor;
    _roiLayer.strokeColor = [UIColor redColor].CGColor;
//    _roiLayer.borderWidth = 10.0f;
    _roiLayer.opacity = 1;
    
}



- (void)refreshVis:(NSArray *)rectValues
{

    CGRect avmoBound = [[rectValues firstObject] CGRectValue];

    if (!_radius) {
        _radius = MAX(avmoBound.size.width, avmoBound.size.height) / 2;
    }

    NSString *pieData = [NSString stringWithFormat:@"move(%f,%f,%f)",
                         avmoBound.origin.x + avmoBound.size.width * 0.5,
                         avmoBound.origin.y + avmoBound.size.height * 0.5,
                         _radius];

    [_webView stringByEvaluatingJavaScriptFromString:pieData];

}

#pragma mark Handle Gesture

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == 1) {
        CGPoint velocity = [panGestureRecognizer velocityInView:_touchView];
        if (velocity.y < 0) {
            [_webView stringByEvaluatingJavaScriptFromString:@"scrollDown()"];
        }
        else
        {
            [_webView stringByEvaluatingJavaScriptFromString:@"scrollUp()"];

        }
    }
}

#pragma mark Register JS Handler

- (void)registerJSHandler
{
    // Configure Bridege
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
    
    [_bridge registerHandler:@"onJSONLoadFinish" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"JSON Data Load Finish");
    }];
    
    [_bridge registerHandler:@"onEgoScrollEnd" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"Ego Scroll Current Index = %d", [data[@"index"] integerValue]);
        [self.dataModel videoViewController:self donutDidScrollToIndex:[data[@"index"] integerValue]];
        
    }];
    
    
}


#pragma mark Ego Data Method

- (void)loadEgoPerson:(VAEgoPerson *)egoPerson
{
    _currentEgoPerson = egoPerson;
    [self startWebView];
}


#pragma mark VAViewController View Size Control

- (void)becomeThumbnailView
{
    NSLog(@"%@ becomeThumbnailView", self);
    self.webView.userInteractionEnabled = NO;
}

- (void)becomeMainView
{
    NSLog(@"%@ becomeMainView", self);
    self.webView.userInteractionEnabled = YES;

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    NSLog(@"Frame Changed");

    [self.videoView.layer layoutSublayers];
}


- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"view.frame"];
}

@end