//
//  VAMDSViewController.m
//  MobileVA
//
//  Created by Su Yijia on 3/18/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAMDSViewController.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import <PureLayout/PureLayout.h>
#import "VAMDSMatrixView.h"
#import "VADataModel.h"
#import "WToast.h"

@interface VAMDSViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *selectedPersonLabel;
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;                  // JS Bridge For WebView
@property (nonatomic, strong) VAMDSMatrixView *matrixView;
@property (nonatomic, strong) NSMutableArray<VAEgoPerson *> *selectedEgo;

@property NSInteger currentYear;
@end

@implementation VAMDSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.type = VAViewControllerTypeMDS;
    [self configureWebView];
    
    _selectedEgo = [NSMutableArray new];
    _matrixView = [[VAMDSMatrixView alloc] initWithFrame:CGRectMake(0,
                                                                    0,
                                                                    [UIScreen mainScreen].bounds.size.width / 3,
                                                                    [UIScreen mainScreen].bounds.size.width / 3)];
    
//    [_matrixView setMatrixDimension:3];
    [_matrixView setHidden:NO];
    
    [self.view addSubview:_matrixView];
    
    
    if (self.dataModel) {
        [self.dataModel addObserver:self forKeyPath:@"currentYear" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
        [self.dataModel addObserver:self forKeyPath:@"selectedEgoPerson" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
        [self.dataModel addObserver:self forKeyPath:@"MDSEgoPersonImage" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];

    }
    
    
}

- (void)dealloc
{
    [self.dataModel removeObserver:self forKeyPath:@"currentYear"];
    [self.dataModel removeObserver:self forKeyPath:@"selectedEgoPerson"];
    [self.dataModel removeObserver:self forKeyPath:@"MDSEgoPersonImage"];

    
}
- (void)configureWebView
{

    [self registerJSHandler];

    self.webView.userInteractionEnabled = NO;
    self.webView.scrollView.scrollEnabled = NO;
    
    // Add Gesture Recoginzer
    
    UIPinchGestureRecognizer *pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    UIPanGestureRecognizer *pagr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [pgr requireGestureRecognizerToFail:pagr];
    pgr.delegate = self;
    pagr.delegate = self;
    pagr.maximumNumberOfTouches = 1;
    pagr.minimumNumberOfTouches = 1;
    //                        targetWebview.userInteractionEnabled = NO;
    if ([self.webView.gestureRecognizers count] < 2) {
        [self.webView addGestureRecognizer:pgr];
        [self.webView addGestureRecognizer:pagr];
    }
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:@"currentYear"]) {
        NSLog(@"%@", change);
        NSInteger newYear = [change[NSKeyValueChangeNewKey] integerValue];
        _currentYear = newYear;
//        [self redrawMatrixViewForYear:_currentYear];
        [self redrawMDSViewForYear:_currentYear];
    }
    else if ([keyPath isEqualToString:@"selectedEgoPerson"]) {
        _selectedEgo = change[NSKeyValueChangeNewKey];
//        if (_currentYear) {
//            [self redrawMatrixViewForYear:_currentYear];
//        }
        [self refreshEgoDisplay];
    }
    else if ([keyPath isEqualToString:@"MDSEgoPersonImage"]) {
        [self sendImageToWebview:change[NSKeyValueChangeNewKey]];
    }
}


#pragma mark Register JS Handler

- (void)registerJSHandler
{
    // Configure Bridege
    if (!_bridge) {
        _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
        
        [_bridge registerHandler:@"onMDSClick" handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {
            NSString *selectedPeople = data[@"people"];
            [WToast showWithText:selectedPeople];
            [self addPerson:selectedPeople];
        }];
    }
//
//    [_bridge registerHandler:@"onJSONLoadFinish" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"JSON Data Load Finish");
//    }];
//    
//    [_bridge registerHandler:@"onEgoScrollEnd" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"Ego Scroll Current Index = %d", [data[@"index"] integerValue]);
//        [self.dataModel videoViewController:self donutDidScrollToIndex:[data[@"index"] integerValue]];
//        
//    }];
//    
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint offset = [panGestureRecognizer translationInView:_webView];
    NSLog(@"Pan Offset! x=%f y=%f", offset.x, offset.y);

    
    if (panGestureRecognizer.state == 1) {
        // Start Pan
        [_webView stringByEvaluatingJavaScriptFromString:@"initPanGesture()"];
    }
    else if (panGestureRecognizer.state == 2) {
        NSString *stringToExecute = [NSString stringWithFormat:@"updatePanGestureOffset(%f, %f)", offset.x, offset.y];
        [_webView stringByEvaluatingJavaScriptFromString:stringToExecute];
    }
    else if (panGestureRecognizer.state == 3)
    {
        [_webView stringByEvaluatingJavaScriptFromString:@"endPanGesture()"];
    }
    
}



- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGestureRecoginzer
{

    
    UIWebView *targetWebview = self.webView;

    // In Web Stage
    if (pinchGestureRecoginzer.state == 1) {
        if (pinchGestureRecoginzer.scale < 1) {
            [targetWebview stringByEvaluatingJavaScriptFromString:@"gestureZoomOut()"];
        }
        else if (pinchGestureRecoginzer.scale > 1)
        {
            NSString *rtnValue = [targetWebview stringByEvaluatingJavaScriptFromString:@"gestureZoomIn()"];
            if ([rtnValue isEqualToString:@"root"]) {
                NSLog(@"root stage");
            }
        }
    }
    
}

- (void)addPerson:(NSString *)personID
{
    VAEgoPerson *egoPerson = [[[VAUtil util] coordinator] egoPersonWithName:personID];
    if (egoPerson) {
        [_selectedEgo addObject:egoPerson];
        if ([_selectedEgo count] > MAX_SELECTED_EGO_LIMIT) {
            [_selectedEgo removeObjectAtIndex:0];
        }
    }
    
    self.dataModel.selectedEgoPerson = _selectedEgo;
    [_matrixView setMatrixDimension:_selectedEgo.count];
    
    [self refreshEgoDisplay];
    
}

- (void)refreshEgoDisplay
{
    if ([_selectedEgo count] == 0) {
        self.selectedPersonLabel.text = @"No EgoPerson is selected.";
    }
    else
    {
        self.selectedPersonLabel.text = [NSString stringWithFormat:@"Selected Person: %@", [[self.dataModel egoPersonNameArray] componentsJoinedByString:@", "]];
        NSString *evalJS = [NSString stringWithFormat:@"setHighlight(['%@'])", [[self.dataModel egoPersonNameArray] componentsJoinedByString:@"','"]];
        [_webView stringByEvaluatingJavaScriptFromString:@"clearHighlight()"];
        [_webView stringByEvaluatingJavaScriptFromString:evalJS];
    }
}


- (void)redrawMDSViewForYear:(NSInteger)newYear
{
    NSString *urlString = [[VAService defaultService] URLWithComponent:@"mds.html"
                                                                 width:_MDSViewSize.width
                                                                height:_MDSViewSize.height
                                                                params:@{@"year" : [NSString stringWithFormat:@"%ld", _currentYear],
                                                                         @"egoname" : [NSString stringWithFormat:@"%@", self.dataModel.currentEgoPerson.name]}];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sendImageToWebview:self.dataModel.MDSEgoPersonImage];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshEgoDisplay];
    });

}

- (void)sendImageToWebview:(UIImage *)imageToSend
{
    NSData *imageData = UIImageJPEGRepresentation(imageToSend, 1.0);
    NSString *encodedString = [imageData base64EncodedStringWithOptions:0];
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setImageData('%@','%@')",self.dataModel.currentEgoPerson.name, encodedString]];

}


#pragma mark VAViewController View Size Control

- (void)becomeThumbnailView
{
    NSLog(@"%@ becomeThumbnailView", self);
    _webView.userInteractionEnabled = NO;
    [_matrixView setHidden:NO];
    [_matrixView setFrame:CGRectMake(0,
                                     0,
                                     [UIScreen mainScreen].bounds.size.width / 3,
                                     [UIScreen mainScreen].bounds.size.width / 3)];
    
}

- (void)becomeMainView
{
    NSLog(@"%@ becomeMainView", self);
    _webView.userInteractionEnabled = YES;
    [_matrixView setHidden:YES];
}




@end
