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
#import "UIImage+Extensions.h"
#import <PureLayout/PureLayout.h>
#import "WToast.h"
const float FACE_DISAPPEAR_TOLERANCE_TIME = 2;

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
@property (nonatomic, strong) NSMutableArray<UIWebView *> *accompanyViews;      // Collection of WebView For Accompany, which each element has an associated object as its webview bridge

@property (nonatomic, strong) UIView *touchView;                                // Touch View
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;                  // JS Bridge For WebView
@property (nonatomic, strong) WebViewJavascriptBridge* accBridge;               // JS Bridge For WebView
@property (nonatomic, strong) NSTimer *trackingFrameRefreshTimer;


// Data Model

@property (nonatomic, strong) VAEgoPerson *currentEgoPerson;
@property (nonatomic, strong) NSMutableArray<VAEgoPerson *> *accompanyEgoPersons;
@property (nonatomic, weak)   VAEgoPerson *currentAccPerson;

@property NSInteger currentYear;

@property BOOL isUsingTouchView;
@property float radius;

// Face Recoginze
@property BOOL isRecognizeSuspended;
@property NSInteger currentFaceID;
@property BOOL isShouldCrop;                                                    // if YES, get Face Frame


// Tip View
@property (weak, nonatomic) IBOutlet UIVisualEffectView *tipView;
@property (weak, nonatomic) IBOutlet UILabel *egoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeAccEgoButton;
@property NSInteger showAccPersonIndex;

// Thumbnail View
@property (nonatomic, strong) UIVisualEffectView *visEffectView;
@property (nonatomic, strong) UIVisualEffectView *vibrancyEffectView;
@property (nonatomic, strong) UILabel *yearLabel;

@property (nonatomic, weak) VAEgoPerson *lastInteractedPerson;
@property BOOL isUpdateTipFrozen;
@end

@implementation VAVideoViewController

const NSInteger MAX_ACCOMPANY_VIEWS = 1;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.type = VAViewControllerTypeVideo;
    self.isRecognizeSuspended = NO;
    
    self.dataModel = [VAUtil util].model;
    [self configureData];
    [self addObserver:self forKeyPath:@"currentFaceID" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"currentEgoPerson" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"currentAccPerson" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    [self.dataModel addObserver:self forKeyPath:@"selectedEgoPerson" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _visEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _visEffectView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 3, [UIScreen mainScreen].bounds.size.width / 3);
    [self.view addSubview:_visEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    _vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    
    _vibrancyEffectView.frame = _visEffectView.bounds;
    [_visEffectView.contentView addSubview:_vibrancyEffectView];
    
    UILabel *labelForHint = [[UILabel alloc] initWithFrame:CGRectMake(0, _vibrancyEffectView.frame.size.height - 50, _vibrancyEffectView.frame.size.width, 50)];
    _yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _vibrancyEffectView.frame.size.width, _vibrancyEffectView.frame.size.height - 50)];
    
    [labelForHint setText:@"Current Year"];
    [labelForHint setFont:[UIFont systemFontOfSize:16]];
    [labelForHint setTextAlignment:NSTextAlignmentCenter];
    
    [_yearLabel setText:[NSString stringWithFormat:@"%ld", self.dataModel.currentYear]];
    [_yearLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:42]];
    [_yearLabel setTextAlignment:NSTextAlignmentCenter];

    [_vibrancyEffectView.contentView addSubview:labelForHint];
    [_vibrancyEffectView.contentView addSubview:_yearLabel];
    
    _tipView.hidden = YES;
    
    UIBlurEffect *darkBlurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    _tipView.effect = darkBlurEffect;
    [_egoNameLabel removeFromSuperview];
    [_tipContentLabel removeFromSuperview];
    [_changeAccEgoButton removeFromSuperview];
    
    [_tipView.contentView addSubview:_egoNameLabel];
    [_tipView.contentView addSubview:_tipContentLabel];
    [_tipView.contentView addSubview:_changeAccEgoButton];
    
    _tipView.layer.zPosition = MAXFLOAT;
    _tipView.layer.cornerRadius = 6.0f;
    _tipView.clipsToBounds = YES;
}

- (void)viewDidLayoutSubviews
{
    [self configureWebView];
    [self setupAccompanyViews];
    [self layoutTipView];
    self.videoPreviewLayer.frame = self.webView.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startCaptureSession];
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
        _smoother = [[FDSmoother alloc] initWithMAWindowSizeForSize:12 location:20];
        _smoother.delegate = self;
    }
    
    
    _lastFaceAppearTime = 0;
    _isUsingTouchView = NO;
    
    
    // Add Frame Observe
    [self addObserver:self forKeyPath:@"view.frame" options:kNilOptions context:NULL];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!_trackingFrameRefreshTimer) {
            _trackingFrameRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(checkTrackingFrame:) userInfo:nil repeats:YES];
        }
    });

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
    
        
        [self registerJSHandlerForWebview:_webView];
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


- (void)refreshVisOverlayWithCurrentEgoPersonWithFaceID:(NSInteger)faceID
{
    if (_currentEgoPerson) {
        if ([_webView tag] != faceID) {
            NSString *urlString = [[VAService defaultService] URLWithComponent:@"pie.html"
                                                                         width:CGRectGetWidth(_videoView.frame)
                                                                        height:CGRectGetHeight(_videoView.frame)
                                                                        params:@{@"egoname" : _currentEgoPerson.name}];
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: urlString]]];
            [_webView setTag:faceID];
            if (_webView.alpha == 0) {
                [UIView animateWithDuration:0.3f delay:0.3f options:0
                                 animations:^{
                                     _webView.alpha = 1;
                                 } completion:nil];
            }
        }
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
        _roiLayer.opacity = 0;

        if (_webView.alpha != 0) {
            [UIView animateWithDuration:0.3f animations:^{
                _webView.alpha = 0.0;
            }];
        }
        
        // Remove Ego Person
        if (!_isRecognizeSuspended) {
            NSLog(@"Removed");
            self.currentEgoPerson = nil;
            [self.dataModel removeEgoPersonFromVideo];
//            [self hideAccompanyViews];
            if ([self.accompanyViews count]) {
                __block CGRect lastAccFrame = self.accompanyViews[0].frame;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.accompanyViews[0] setFrame:lastAccFrame];
                });
                self.tipView.hidden = (self.accompanyViews[0].hidden && self.webView.alpha != 0) && ![self.tipContentLabel.text isEqualToString:@"CONTENT"];
                
            }

        }
    }
    else
    {
        if (_webView.alpha == 0) {
            if (_webView.tag == _currentFaceID) {
                [UIView animateWithDuration:0.3f delay:0.3f options:0
                                 animations:^{
                                     _webView.alpha = 1;
                                 } completion:nil];
            }
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
    if (_isRecognizeSuspended) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AVMetadataFaceObject *avmo = [metadataObjects firstObject];
        AVMetadataObject *transformedMetadata = [_videoPreviewLayer transformedMetadataObjectForMetadataObject:avmo];
        _lastFaceAppearTime = CACurrentMediaTime();
        [self.smoother inputData:@[[NSValue valueWithCGRect:transformedMetadata.bounds]]];
//        NSLog(@"MetaData Face ID = %d", avmo.faceID);
        self.currentFaceID = avmo.faceID;
    });
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if (_isRecognizeSuspended) return;

    if (_isShouldCrop) {
        _isShouldCrop = NO;
        CGImageRef imageFromBuffer = [[VAUtil util] imageFromSampleBuffer:sampleBuffer];
        UIImage *imageFrame =[[[UIImage alloc] initWithCGImage:imageFromBuffer] imageRotatedByDegrees:90.0f];
        
        CGSize videoSize = self.videoPreviewLayer.bounds.size;
        CGRect ratioRect = CGRectMake(_lastRect.origin.x / videoSize.width,
                                      _lastRect.origin.y / videoSize.height,
                                      _lastRect.size.width / videoSize.width,
                                      _lastRect.size.height / videoSize.height);
        
        CGRect refineRect = CGRectMake(ratioRect.origin.x * imageFrame.size.width - 20,
                                       ratioRect.origin.y * imageFrame.size.height - 20,
                                       ratioRect.size.width * imageFrame.size.width + 40,
                                       ratioRect.size.height * imageFrame.size.height + 40);
        
        CGImageRef croppedImageRef = CGImageCreateWithImageInRect(imageFrame.CGImage, refineRect);
        UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef];
        CGImageRelease(croppedImageRef);
        
        

        self.dataModel.croppedVideoImage = croppedImage;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self submitFaceImageForCurrentFaceID];
        });
    }
    
    
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
    
    CGFloat cx = avmoBound.origin.x + avmoBound.size.width * 0.5;
    CGFloat cy = avmoBound.origin.y + avmoBound.size.height * 0.5;
    NSString *pieData = [NSString stringWithFormat:@"move(%f,%f,%f)", cx, cy, _radius];

    [_webView stringByEvaluatingJavaScriptFromString:pieData];
    
    // Move WebView
    CGFloat borderWidth = (_radius / 110.0) * 60.0f;
    CGFloat webViewWidth = 2 * (_radius + borderWidth);

    [_webView setFrame:CGRectMake(cx - 0.5 * webViewWidth,
                                  cy - 1.5 * webViewWidth,
                                  webViewWidth,
                                  3 * webViewWidth)];
    
    if ([self.dataModel.selectedEgoPerson count] > 1) {
        if (_webView.alpha != 0) {
            [self refreshAccompanyVisWithRadius:_radius];
        }
    }
    
    if (_tipView) {
        [self.view bringSubviewToFront:_tipView];
    }
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

- (void)registerJSHandlerForWebview:(UIWebView *)webview
{
    if (webview == _webView) {
        // if Main View
        // Configure Bridege
        _bridge = [WebViewJavascriptBridge bridgeForWebView:webview];
        
//        [_bridge registerHandler:@"onJSONLoadFinish" handler:^(id data, WVJBResponseCallback responseCallback) {
//            NSLog(@"JSON Data Load Finish");
//        }];
        
        [_bridge registerHandler:@"onEgoScrollEnd" handler:^(id data, WVJBResponseCallback responseCallback) {
            
            NSLog(@"Ego Scroll Current Index = %d", [data[@"index"] integerValue]);

            NSInteger index = [data[@"index"] integerValue];
            NSInteger currentYear = [[self.currentEgoPerson.years objectAtIndex:index] integerValue];
            _currentYear = currentYear;
            self.dataModel.currentYear = currentYear;
            [self refreshThumbnailView];
            [self egoPerson:_currentEgoPerson donutDidSlideToIndex:index year:currentYear];
            
        }];

    }
    else
    {
        // if accompany view
        _accBridge = [WebViewJavascriptBridge bridgeForWebView:webview];
        [_accBridge registerHandler:@"onEgoScrollEnd" handler:^(id data, WVJBResponseCallback responseCallback) {
            

            NSInteger index = [data[@"index"] integerValue];
            NSInteger accViewIndex = [self indexOfAccompanyView:webview];
            VAEgoPerson *egoPerson = self.accompanyEgoPersons[accViewIndex];
            NSInteger currentYear = [[egoPerson.years objectAtIndex:index] integerValue];
            
            NSLog(@"accViewIndex = %ld; Accompany Ego Scroll Current Index = %d", accViewIndex, [data[@"index"] integerValue]);
            [self accompanyEgoPerson:egoPerson donutDidSlideToIndex:index year:currentYear];
        }];
    }
    
    
}


#pragma mark Ego Data Method

- (void)loadEgoPerson:(VAEgoPerson *)egoPerson withFaceID:(NSInteger)faceID
{
    _currentEgoPerson = egoPerson;
    [self refreshVisOverlayWithCurrentEgoPersonWithFaceID:(NSInteger)faceID];
}


#pragma mark VAViewController View Size Control

- (void)becomeThumbnailView
{
    NSLog(@"%@ becomeThumbnailView", self);
    self.webView.userInteractionEnabled = NO;
    self.webView.hidden = YES;
    _isRecognizeSuspended = YES;
    self.visEffectView.hidden = NO;
    [self refreshThumbnailView];
    
    [_accompanyViews enumerateObjectsUsingBlock:^(UIWebView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setHidden:YES];
        [obj setUserInteractionEnabled:NO];
    }];
    _tipView.hidden = YES;
}

- (void)becomeMainView
{
    NSLog(@"%@ becomeMainView", self);
    self.webView.userInteractionEnabled = YES;
    self.webView.hidden = NO;
    self.visEffectView.hidden = YES;
    _isRecognizeSuspended = NO;
    
    [_accompanyViews enumerateObjectsUsingBlock:^(UIWebView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setHidden:NO];
        [obj setUserInteractionEnabled:YES];
    }];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if ([keyPath isEqualToString:@"view.frame"]) {
        [self.videoView.layer layoutSublayers];
    }
    else if([keyPath isEqualToString:@"currentFaceID"])
    {
        if ([change[NSKeyValueChangeOldKey] integerValue] != [change[NSKeyValueChangeNewKey] integerValue]) {
            NSLog(@"changed Face ID!!!");
            NSInteger startID = _currentFaceID;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // if the face is not changed between 1.5 sec duration
                if (startID == _currentFaceID) {
                    [self requestFaceRecognizeForCurrentFaceID];
                }
            });
        }
    }
    else if([keyPath isEqualToString:@"selectedEgoPerson"])
    {
        [self updateAccompanyViewsWithEgoPersons:change[NSKeyValueChangeNewKey]];
    }
    else if ([keyPath isEqualToString:@"currentAccPerson"])
    {
        [self changeAccEgoPerson:change[NSKeyValueChangeNewKey]];
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"view.frame"];
    [self removeObserver:self forKeyPath:@"currentFaceID"];
    [self removeObserver:self forKeyPath:@"currentEgoPerson"];

}

#pragma mark Face Recognize

- (void)requestFaceRecognizeForCurrentFaceID
{
    [WToast showWithText:@"Face Recognizing in Progress ..."];
    _isShouldCrop = YES;
}

- (void)submitFaceImageForCurrentFaceID
{
    if (self.dataModel.croppedVideoImage) {
        [[VAService defaultService] imageRecoginzeForImage:self.dataModel.croppedVideoImage
                                                   imageID:_currentFaceID
                                           completionBlock:^(BOOL isSuccess, VAEgoPerson *egoPerson, NSInteger imageID) {
                                               if (isSuccess) {
                                                   [self finishFaceRecognizeForImageID:imageID egoPerson:egoPerson];
                                               }
                                               else
                                               {
                                                   [WToast showWithText:@"Face is not recognized. Try again."];
                                               }
                                           }];
    }
}

- (void)finishFaceRecognizeForImageID:(NSInteger)imageID egoPerson:(VAEgoPerson *)egoPerson
{
    if (imageID == _currentFaceID) {
        // The Person is Not Changed
        [WToast showWithText:[NSString stringWithFormat:@"Face = %@", egoPerson.name]];
        [self loadEgoPerson:egoPerson withFaceID:imageID];
        [self.dataModel inputEgoPersonFromVideo:egoPerson];
        _currentYear = [[egoPerson.years firstObject] integerValue];
    }
}

#pragma mark Thumbnail View
- (void)refreshThumbnailView
{
    _yearLabel.text = [NSString stringWithFormat:@"%ld", _currentYear];
}


#pragma mark Accompany Views

- (NSInteger)indexOfAccompanyView:(UIWebView *)accView
{
    return [self.accompanyViews indexOfObject:accView];
}

- (void)setupAccompanyViews
{
    if (!_accompanyViews) {
        _accompanyViews = [NSMutableArray new];
        
        for (int i = 0; i < MAX_ACCOMPANY_VIEWS; i++) {
            
            UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            webview.delegate = self;
            webview.opaque = NO;
            webview.backgroundColor = [UIColor clearColor];
            webview.scrollView.bounces = NO;
            webview.hidden = YES;
            webview.userInteractionEnabled = NO;
            
            // To be finish
            [self.view addSubview:webview];
            [_accompanyViews addObject:webview];

            [self registerJSHandlerForWebview:webview];

        }
    }
    
}

- (void)updateAccompanyViewsWithEgoPersons:(NSArray<VAEgoPerson *> *)egoPersons
{
    NSArray *showPersons = [egoPersons mutableCopy];
    [(NSMutableArray *)showPersons removeObject:self.currentEgoPerson];
    showPersons = [showPersons subarrayWithRange:NSMakeRange(0, MIN(MAX_ACCOMPANY_VIEWS, showPersons.count))];
    
    _accompanyEgoPersons = [showPersons mutableCopy];
    
    if ([_accompanyEgoPersons count]) {
        self.currentAccPerson = _accompanyEgoPersons[0];

    }
//    
//    [showPersons enumerateObjectsUsingBlock:^(VAEgoPerson *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [self loadEgoPerson:obj atAccompanyViewIndex:idx];
//    }];
}

- (void)loadEgoPerson:(VAEgoPerson *)egoPerson atAccompanyViewIndex:(NSInteger)index
{
    //   0 (MAINVIEW)
    //   0 (MAINVIEW) 1
    // 2 0 (MAINVIEW) 1
    // 2 0 (MAINVIEW) 1 3
    // 2 0 (MAINVIEW) 1 3 5
    
    
    UIWebView *accWebview = self.accompanyViews[index];
    accWebview.hidden = NO;

    NSString *urlString = [[VAService defaultService] URLWithComponent:@"pie.html"
                                                                 width:CGRectGetWidth(_webView.frame)
                                                                height:CGRectGetHeight(_webView.frame)
                                                                params:@{@"egoname" : egoPerson.name}];
    [accWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: urlString]]];

}

- (void)accompanyEgoPerson:(VAEgoPerson *)egoPerson donutDidSlideToIndex:(NSInteger)index year:(NSInteger)year
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTipViewForEgoPerson:_currentAccPerson selectedYear:year];
    });

    NSString *yearString = [NSString stringWithFormat:@"%ld", year];

    // Check if this year is existed in Main Person
    if ([self.dataModel.currentEgoPerson.years containsObject:yearString]) {
        [self slideEgoPersonDonutToIndex:[self.dataModel.currentEgoPerson.years indexOfObject:yearString] inWebview:_webView];
    }
    
//    // Check if this year is existed in all other e
//    
//    NSInteger accIndex = [self.accompanyEgoPersons indexOfObject:egoPerson];
//    [_accompanyViews enumerateObjectsUsingBlock:^(UIWebView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (idx == accIndex) {
//            return;
//        }
//        
//        VAEgoPerson *egoPerson = self.accompanyEgoPersons[idx];
//        if ([egoPerson.years containsObject:@(year)]) {
//            [self slideEgoPersonDonutToIndex:[egoPerson.years indexOfObject:@(year)] inWebview:obj];
//        }
//    }];
}

- (void)egoPerson:(VAEgoPerson *)egoPerson donutDidSlideToIndex:(NSInteger)index year:(NSInteger)year
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTipViewForEgoPerson:egoPerson selectedYear:year];
    });
    if ([_accompanyEgoPersons count]) {
        NSString *yearString = [NSString stringWithFormat:@"%ld", year];
        VAEgoPerson *accEgoPerson = _accompanyEgoPersons[0];
        
        // Check if this year is existed in Main Person
        if ([accEgoPerson.years containsObject:yearString]) {
            [self slideEgoPersonDonutToIndex:[accEgoPerson.years indexOfObject:yearString] inWebview:_accompanyViews[0]];
        }
    }
    
}

- (void)slideEgoPersonDonutToIndex:(NSInteger)index inWebview:(UIWebView *)webview
{
    NSString *scriptToExecute = [NSString stringWithFormat:@"moveToSelectedIndex(%ld)", (long)index];
    NSLog(@"%@", scriptToExecute);
    [webview stringByEvaluatingJavaScriptFromString:scriptToExecute];
}
- (void)refreshAccompanyVisWithRadius:(CGFloat)radius
{
    if ([_accompanyViews count] == 1) {
        [_accompanyViews enumerateObjectsUsingBlock:^(UIWebView * _Nonnull webview, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat centerX = _webView.frame.origin.x + _webView.frame.size.width / 2;
            CGFloat width = _webView.frame.size.width;
            CGFloat height = _webView.frame.size.height;
            NSInteger alignFactor = -1;
            if (_lastRect.origin.x < (_lastRect.size.width)) {
                // if no enough space on left side
                alignFactor = 1;
            }
            else if ((_videoView.frame.size.width - _lastRect.origin.x - _lastRect.size.width) < (_lastRect.size.width))
            {
                // if no enough space on right side
                alignFactor = -1;
            }
            
            
            CGRect newFrame;
            if (alignFactor == -1) {
                newFrame = CGRectMake(centerX - 0.5 * width - width,
                                      _webView.frame.origin.y,
                                      width,
                                      height);

            }
            else
            {
                newFrame = CGRectMake(centerX + 0.5 * width,
                                      _webView.frame.origin.y,
                                      width,
                                      height);

            }
            
            if (_webView.alpha != 0) {
                [webview setFrame:newFrame];
            }
            
            NSString *pieData = [NSString stringWithFormat:@"move(%d,%d,%f)", 0, 0, radius];
            [webview stringByEvaluatingJavaScriptFromString:pieData];
            
            
        }];

    }
}

- (void)updateTipViewForEgoPerson:(VAEgoPerson *)egoPerson selectedYear:(NSInteger)year
{
//    _tipView.hidden = NO;
    if (_isUpdateTipFrozen) {
        return;
    }
    if (!egoPerson) {
        _tipView.hidden = YES;
    }
    _tipView.hidden = NO;
    _egoNameLabel.text = [NSString stringWithFormat:@"%@", egoPerson.name];

    NSDictionary *dataDict = [egoPerson alterChangeForYear:year];
    
    NSArray *contentArray = @[
                              [NSString stringWithFormat:@"Publication of %ld: %ld", year, [egoPerson publicationCountForYear:year]],
                              [NSString stringWithFormat:@"Second Degree Alters: %ld", [egoPerson secLevelAlterCountForYear:year]],
                              [NSString stringWithFormat:@"Direct Alters: %@ Density: %.2f", dataDict[@"count"], [egoPerson densityForYear:year]],
                              [NSString stringWithFormat:@"[New: %ld  Weaker: %ld  Same-Tie: %ld  Stronger: %ld]",
                               [dataDict[@"new"] count],
                               [dataDict[@"weaker"] count],
                               [dataDict[@"same"] count],
                               [dataDict[@"stronger"] count]]
                              ];
    _tipContentLabel.text = [NSString stringWithFormat:@"%@", [contentArray componentsJoinedByString:@"\n"]];
    _isUpdateTipFrozen = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isUpdateTipFrozen = NO;
    });
    
}

- (void)hideAccompanyViews
{
    [_accompanyViews enumerateObjectsUsingBlock:^(UIWebView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setHidden:YES];
    }];
}

- (void)layoutTipView
{
    _egoNameLabel.frame = CGRectMake(8, 4, _tipView.frame.size.width, 20);
    _tipContentLabel.frame = CGRectMake(8, 22, _tipView.frame.size.width, _tipView.frame.size.height - 20);
//    _changeAccEgoButton.frame = CGRectMake(_tipView.frame.size.width - _changeAccEgoButton.frame.size.width - 10,
//                                           _changeAccEgoButton.frame.origin.y,
//                                           _changeAccEgoButton.frame.size.width,
//                                           _changeAccEgoButton.frame.size.height);
    
}

- (IBAction)onChangeAccEgo:(id)sender
{
    NSMutableArray<VAEgoPerson *> *selectablePersons = [self.dataModel.selectedEgoPerson mutableCopy];
    [selectablePersons removeObject:self.dataModel.currentEgoPerson];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Select EgoPerson"
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    [selectablePersons enumerateObjectsUsingBlock:^(VAEgoPerson * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ac addAction:[UIAlertAction actionWithTitle:obj.name
                                               style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 [self changeAccEgoPerson: obj];
                                             }]];
    }];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                           style:UIAlertActionStyleCancel
                                         handler:nil]];
    
    [self presentViewController:ac animated:YES completion:nil];
    
}

- (void)changeAccEgoPerson:(VAEgoPerson *)egoPerson
{
    _currentAccPerson = egoPerson;
    [self loadEgoPerson:egoPerson atAccompanyViewIndex:0];
}
#pragma mark Ego Person Sliding

//- (void)videoViewController:(VAVideoViewController *)videoVC donutDidScrollToIndex:(NSInteger)dountIndex
//{
//    NSString *yearOfSelection = [self.currentEgoPerson.years objectAtIndex:dountIndex];
//    NSLog(@"Did Scroll To Year = %@", yearOfSelection);
//    [self setCurrentYear:[yearOfSelection integerValue]];
//    
//}

@end

