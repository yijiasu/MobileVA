//
//  VATimeLineViewController.m
//  MobileVA
//
//  Created by Su Yijia on 3/18/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VATimeLineViewController.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import <PureLayout/PureLayout.h>
#import "VAMatrixView.h"
#import "VADataModel.h"
#import "WToast.h"
#import "FDMagnifyView.h"
#import "UIView+draggable.h"
#import "UIView+DragDrop.h"
#import "UIWebView+ScreenShot.h"
#import "VATimeLineMatrixView.h"
//#import "UIImage+Trim.h"


@interface VATimeLineViewController () <UIScrollViewDelegate, UIViewDragDropDelegate>
{
    int **_egoMatrix;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;                  // JS Bridge For WebView

// Control Bar
@property (weak, nonatomic) IBOutlet UIButton *magnifyButton;
@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (weak, nonatomic) IBOutlet UIButton *downButton;
@property (weak, nonatomic) IBOutlet UILabel *egoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *coordinationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *currentEgoTitle;

@property (strong, nonatomic) FDMagnifyView *magnifyView;
@property (strong, nonatomic) NSMutableArray *egoList;
@property NSInteger matrixWidth;
@property NSInteger matrixHeight;

@property CGFloat screenScale;
@property BOOL isMagnifyViewDisplay;
@property (strong, nonatomic) NSString *currentHighlightNodeKey;
@property int currentMagnifyXValue;
@property int currentMagnifyYValue;
@property int currentEgoNodeID;

@property (nonatomic) BOOL arrowButtonEnabled;

@property (strong, nonatomic) UIImage *webSnapshot;

@property (weak, nonatomic) IBOutlet UIView *slidingWindow;

@property BOOL isInitialized;
@property (nonatomic) BOOL isTimelineLoading;

// Matrix
@property (nonatomic, strong) VATimeLineMatrixView *matrixView;


@end

@implementation VATimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.type = VAViewControllerTypeTimeLine;
    [self initTimelineView];
    [self hideControlBar];
    [self hideSlidingWindowAndImageView];
    [self configureWebView];
    _currentEgoTitle.text = @"";
    if (self.dataModel) {
        [self.dataModel addObserver:self forKeyPath:@"selectedEgoPerson" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
        [self.dataModel addObserver:self forKeyPath:@"currentYear" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];

    }
    
    _matrixView = [[VATimeLineMatrixView alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         [UIScreen mainScreen].bounds.size.width / 3,
                                                                         [UIScreen mainScreen].bounds.size.width / 3)];

    [_matrixView setHidden:NO];
    
    [self.view addSubview:_matrixView];

    

}

- (void)dealloc
{
    [self.dataModel removeObserver:self forKeyPath:@"selectedEgoPerson"];
    [self.dataModel removeObserver:self forKeyPath:@"currentYear"];
}

- (void)initTimelineView
{
    if (!_magnifyView) {
        _magnifyView = [[FDMagnifyView alloc] init];
        _egoList = [NSMutableArray new];
        _screenScale = 2.0f;
        [self configureDragging];
    }
    
    _webView.scrollView.bounces = NO;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    
    _webView.scrollView.delegate = self;
    
    [_slidingWindow makeDraggable];
    [_slidingWindow setDragMode:UIViewDragDropModeRestrictX];
    [_slidingWindow setDelegate:self];
    
    [self.slidingWindow addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:@"center"]) {
        NSLog(@"observer keypath = center");
        UIView *v = object;
        if (v.frame.origin.x <= 0) {
            v.frame = CGRectMake(0, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
            return;
        }
        else if (v.frame.origin.x + v.frame.size.width >= [UIScreen mainScreen].bounds.size.width)
        {
            v.frame = CGRectMake([UIScreen mainScreen].bounds.size.width -  v.frame.size.width,  v.frame.origin.y, v.frame.size.width, v.frame.size.height);
            return;
        }
        
        CGFloat ratio = v.frame.origin.x / [UIScreen mainScreen].bounds.size.width;
        _webView.scrollView.contentOffset = CGPointMake(ratio * _webView.scrollView.contentSize.width, _webView.scrollView.contentOffset.y);
    }
    else if ([keyPath isEqualToString:@"selectedEgoPerson"])
    {
        NSLog(@"currentEgoPerson");
        if (self.dataModel.currentEgoPerson) {
            [self refreshTimelineWithEgoPerson:self.dataModel.currentEgoPerson];
        }
    }
    else if ([keyPath isEqualToString:@"currentYear"])
    {
        [self switchToYear:self.dataModel.currentYear];
    }
}


- (void)configureTimelineView
{

}
- (void)viewDidLayoutSubviews
{
    _slidingWindow.frame = CGRectMake(_slidingWindow.frame.origin.x,
                                      _imageView.frame.origin.y,
                                      _slidingWindow.frame.size.width,
                                      _slidingWindow.frame.size.height);
}
- (void)configureWebView
{
    [self registerJSHandler];

    if (self.dataModel.currentEgoPerson) {
        VAEgoPerson *egoPerson  = self.dataModel.currentEgoPerson;
        [self refreshTimelineWithEgoPerson:egoPerson];
    }

}

- (void)refreshTimelineWithEgoPerson:(VAEgoPerson *)egoPerson
{
    NSString *urlString = [[VAService defaultService] URLWithComponent:@"timeline.html"
                                                                 width:_webView.frame.size.width
                                                                height:_webView.frame.size.height
                                                                params:@{
                                                                         @"egoname"   : egoPerson.name,
                                                                         @"startyear" : [NSString stringWithFormat:@"%ld", (long)egoPerson.startYear],
                                                                         @"endyear"   : [NSString stringWithFormat:@"%ld", (long)egoPerson.endYear]
                                                                         }];
    
    _currentEgoTitle.text = [NSString stringWithFormat:@"%@'s Storyline", egoPerson.name];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    [self setIsTimelineLoading:YES];
    [self hideSlidingWindowAndImageView];
    if (self.dataModel.currentYear) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self switchToYear:self.dataModel.currentYear];
        });
    }
}

- (void)configureDragging
{
    __weak id weakSelf = self;
    
    [_magnifyView enableDragging];
    [_magnifyView setDraggable:YES];
    [_magnifyView setDraggingMovedBlock:^(UIView *view) {
        CGPoint crossPoint = [weakSelf centerPointOfMagnifyView];
        NSLog(@"Location X=%f Y=%f", crossPoint.x, crossPoint.y);
        [weakSelf updateMagnifyView:crossPoint];
    }];
}


- (CGPoint)centerPointOfMagnifyView
{
    CGRect rect = [self.magnifyView convertRect:self.magnifyView.frame toView:self.view];
    CGPoint crossPoint = CGPointMake(rect.origin.x / _screenScale + rect.size.width / 2, rect.origin.y / _screenScale + rect.size.height / 2);
    
    return crossPoint;
}


- (void)updateMagnifyView:(CGPoint)centerPoint
{
    CGPoint scrollViewOffsetPoint = self.webView.scrollView.contentOffset;
    int xValue = MAX(MIN((int)(centerPoint.x + scrollViewOffsetPoint.x), (int)_matrixWidth), 0);
    int yValue = MAX(MIN((int)(centerPoint.y + scrollViewOffsetPoint.y), (int)_matrixHeight), 0);
    if (xValue >= _matrixWidth || yValue >= _matrixHeight) {
        return;
    }
    int value = _egoMatrix[xValue][yValue];
    
    _currentMagnifyXValue = xValue;
    _currentMagnifyYValue = yValue;
    _currentEgoNodeID     = value;
    
    _coordinationLabel.text = [NSString stringWithFormat:@"Current X=%d, Y=%d", xValue, yValue];
    if (value != -1) {
        [self highlightD3Node:_egoList[value]];
    }
    else
    {
        [self unfocusD3Node];
    }
    
    // Crop Image
    //
    //    CGImageRef croppedImage = CGImageCreateWithImageInRect(_webSnapshot.CGImage, CGRectMake((xValue - 30) * 3, (yValue - 30) * 3, 60, 60));
    //    UIImage *croppedUIImage = [UIImage imageWithCGImage:croppedImage];
    //    CGImageRelease(croppedImage);
    //
    //    [_magnifyView setContentImage:croppedUIImage];
    
    [_magnifyView moveCenterPointTo:CGPointMake(xValue, yValue)];
    
}

- (void)highlightD3Node:(NSString *)nodeKey
{
    if ([_currentHighlightNodeKey isEqualToString:nodeKey]) {
        return;
    }
    _egoNameLabel.text = nodeKey;
    _currentHighlightNodeKey = nodeKey;
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"highlight('%@')", nodeKey]];
    
    self.arrowButtonEnabled = YES;
    
}

- (void)unfocusD3Node
{
    if (!_currentHighlightNodeKey) {
        return;
    }
    _currentHighlightNodeKey = nil;
    _egoNameLabel.text = @"";
    [_webView stringByEvaluatingJavaScriptFromString:@"unfocus()"];
    
    self.arrowButtonEnabled = NO;
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateMagnifyView:[self centerPointOfMagnifyView]];
    CGPoint offset = scrollView.contentOffset;
    _slidingWindow.frame = CGRectMake(offset.x / scrollView.contentSize.width * [UIScreen mainScreen].bounds.size.width,
                                      _slidingWindow.frame.origin.y,
                                      _slidingWindow.frame.size.width,
                                      _slidingWindow.frame.size.height);
    
}

- (IBAction)onButtonTap:(id)sender {
    
    if (!_isMagnifyViewDisplay) {
        _isMagnifyViewDisplay = YES;
        [self.view addSubview:_magnifyView];
        [_magnifyView setAlpha:0];
        [_magnifyView setFrame:CGRectMake(20, 20, _magnifyView.frame.size.width, _magnifyView.frame.size.height)];
        [_magnifyView setClipsToBounds:YES];
        _magnifyView.center = [_magnifyButton convertPoint:_magnifyButton.center toView:self.view];
        [UIView animateWithDuration:0.5 animations:^{
            [_magnifyView setAlpha:1];
            [_magnifyView setCenter:_webView.center];
        }];
    }
    else
    {
        _magnifyButton.enabled = NO;
        [UIView animateWithDuration:0.5f animations:^{
            [_magnifyView setAlpha:0];
            _magnifyView.center = [_magnifyButton convertPoint:_magnifyButton.center toView:self.view];
        } completion:^(BOOL finished) {
            [_magnifyView removeFromSuperview];
            _isMagnifyViewDisplay = NO;
            _magnifyButton.enabled = YES;
        }];
    }
}

- (IBAction)moveUpward:(id)sender {
    //    int chooseValue = -1;
    for (int i = _currentMagnifyYValue; i > 0; i--) {
        if (_egoMatrix[_currentMagnifyXValue][i] == _currentEgoNodeID + 1)
        {
            [self moveMagnifyViewTo:CGPointMake(_currentMagnifyXValue, i)];
            break;
        }
    }
    
}

- (IBAction)moveDownward:(id)sender {
    for (int i = _currentMagnifyYValue; i < _matrixHeight; i++) {
        if (_egoMatrix[_currentMagnifyXValue][i] == _currentEgoNodeID - 1)
        {
            [self moveMagnifyViewTo:CGPointMake(_currentMagnifyXValue, i)];
            break;
        }
    }
    
}

- (void)moveMagnifyViewTo:(CGPoint)newLocation
{
    CGPoint scrollViewOffsetPoint = self.webView.scrollView.contentOffset;
    newLocation.x = newLocation.x - scrollViewOffsetPoint.x;
    newLocation.y = newLocation.y - scrollViewOffsetPoint.y;
    
    [self updateMagnifyView:newLocation];
    newLocation.x = newLocation.x - _magnifyView.frame.size.width / 2;
    newLocation.y = newLocation.y - _magnifyView.frame.size.height / 2;
    
    [_magnifyView setFrame:CGRectMake(newLocation.x, newLocation.y, _magnifyView.frame.size.width, _magnifyView.frame.size.height)];
    
    [self setControlButton:_upButton enabled:![self isCurrentNodeTopOfStack]];
    [self setControlButton:_downButton enabled:![self isCurrentNodeBottomOfStack]];
    
}

- (BOOL)isCurrentNodeTopOfStack
{
    BOOL rtnValue = YES;
    for (int i = _currentMagnifyYValue; i > 0; i--) {
        if (_egoMatrix[_currentMagnifyXValue][i] != -1 && _egoMatrix[_currentMagnifyXValue][i] != _currentEgoNodeID) {
            rtnValue = NO;
            break;
        }
    }
    
    return rtnValue;
}

- (BOOL)isCurrentNodeBottomOfStack
{
    BOOL rtnValue = YES;
    for (int i = _currentMagnifyYValue; i < _matrixHeight; i++) {
        if (_egoMatrix[_currentMagnifyXValue][i] != -1 && _egoMatrix[_currentMagnifyXValue][i] != _currentEgoNodeID) {
            rtnValue = NO;
            break;
        }
    }
    
    return rtnValue;
}

- (void)setControlButton:(UIButton *)aButton enabled:(BOOL)enabled
{
    if (enabled) {
        aButton.alpha  = 1.0;
        aButton.userInteractionEnabled = YES;
    }
    else
    {
        aButton.alpha = 0.3;
        aButton.userInteractionEnabled = NO;
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)didReceivedBitmapDataFromWebview:(id)data
{
    if ([[data class] isSubclassOfClass:[NSDictionary class]]) {
        // Processed
        CGPoint basePoint = CGPointMake([data[@"transX"] integerValue], [data[@"transY"] integerValue]);
        [self setIsTimelineLoading:NO];
        NSDictionary *dict = data;
        [self createMatrixArrayWithWidth:[dict[@"width"] integerValue] height:[dict[@"height"] integerValue]];
        
        [self fillMatrixWithData:dict[@"bitmap"] translateBasePoint:basePoint];
        
        [self updateWebPageSnapshot];
        [self resizeSlidingWindow];
        [self showSlidingWindowAndImageView];
        //        [self printMatrix];
    }
}

- (void)updateWebPageSnapshot
{

    _webSnapshot = [_webView screenshot];
    NSLog(@"%@", _webSnapshot);
    _magnifyView.snapshotImage = _webSnapshot;
    _imageView.image = _webSnapshot;
}

- (void)resizeSlidingWindow
{
    _slidingWindow.frame = CGRectMake(_slidingWindow.frame.origin.x,
                                      _slidingWindow.frame.origin.y,
                                      [UIScreen mainScreen].bounds.size.width / _webSnapshot.size.width * [UIScreen mainScreen].bounds.size.width,
                                      _slidingWindow.frame.size.height);
}


- (void)showSlidingWindowAndImageView
{
    [UIView animateWithDuration:0.3f animations:^{
        _slidingWindow.alpha = 0.3;
        _imageView.alpha = 1;
    }];
}

- (void)hideSlidingWindowAndImageView
{
//    [UIView animateWithDuration:0.3f animations:^{
        _slidingWindow.alpha = 0;
        _imageView.alpha = 0;
//    }];

}
- (void)createMatrixArrayWithWidth:(NSUInteger)width height:(NSUInteger)height
{
    
    _egoMatrix = (int **)malloc(sizeof(int *) * width);
    for (int i = 0; i < width; i++) {
        _egoMatrix[i] = (int *)malloc(sizeof(int) * height);
        for (int k = 0; k < height; k++) {
            _egoMatrix[i][k] = -1;
        }
    }
    
    _matrixWidth = width;
    _matrixHeight = height;
    
    ////    int count = 0;
    ////    for (int i = 0; i <  width; i++)
    ////        for (int j = 0; j < height; j++)
    ////            _egoMatrix[i][j] = ++count; // Or *(*(arr+i)+j) = ++count
    ////
    //
    //
    //
}

- (void)printMatrix
{
    for(int i = 0; i < _matrixWidth; i++) {
        for(int j = 0; j < _matrixHeight; j++) {
            printf("%d ", _egoMatrix[i][j]);
        }
        printf("\n");
    }
    
}

- (void)fillMatrixWithData:(NSArray *)allNodeData translateBasePoint:(CGPoint)basePoint
{
    NSLog(@"%@", [allNodeData firstObject]);
    for (NSDictionary *d in allNodeData) {
        [_egoList addObject:d[@"name"]];
        NSInteger index = [_egoList count] - 1;
        
        NSInteger x1 = [d[@"x1"] integerValue] + basePoint.x;
        NSInteger x2 = [d[@"x2"] integerValue] + basePoint.x;
        NSInteger y1 =  [d[@"y1"] integerValue] + basePoint.y - 1;
        NSInteger y2 =  [d[@"y1"] integerValue] + basePoint.y + 1;
        
        for (NSInteger x = x1; x <= x2; x++) {
            for (NSInteger y = y1; y <= y2; y++) {
                _egoMatrix[x][y] = (int)index;
            }
        }
        
    }
}



- (void)setIsTimelineLoading:(BOOL)isTimelineLoading
{
    _isTimelineLoading = isTimelineLoading;
    UIActivityIndicatorView *aiv;
    if ([_magnifyButton associatedObject]) {
        aiv = [_magnifyButton associatedObject];
    }
    else
    {
        aiv = [[UIActivityIndicatorView alloc] initWithFrame:_magnifyButton.frame];
        [_magnifyButton setAssociatedObject:aiv];
    }
    
    if (_isTimelineLoading) {
        [_magnifyButton setHidden:YES];
        
        [self.view addSubview:aiv];
        [aiv autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_magnifyButton withOffset:4.0f];
        [aiv autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:_magnifyButton withOffset:4.0f];
        
        aiv.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [aiv startAnimating];
        
        [self setControlButton:_upButton enabled:NO];
        [self setControlButton:_downButton enabled:NO];
        
    }
    else
    {
        [_magnifyButton setHidden:NO];
        [aiv stopAnimating];
        
        [aiv removeFromSuperview];
        
        [self setControlButton:_upButton enabled:YES];
        [self setControlButton:_downButton enabled:YES];
        
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //            UIImage *webSnapShot = [_webView screenshot];
        //            _imageView.image = webSnapShot;
        //        });
    }
}

- (void)switchToYear:(NSInteger)newYear
{
    NSInteger yearDistance = labs(self.dataModel.currentEgoPerson.startYear - self.dataModel.currentYear);
    self.webView.scrollView.contentOffset = CGPointMake((yearDistance - 2) * 100 + 25, 0);
}


#pragma mark Register JS Handler

- (void)registerJSHandler
{
    // Configure Bridege
    if (!_bridge) {
        _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
        __weak id weakSelf = self;
        [_bridge registerHandler:@"bitmapDataHandler" handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {

            NSLog(@"callback");
            [weakSelf didReceivedBitmapDataFromWebview:data];

        }];
    }

    
}

- (void)hideControlBar
{
    [[self.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 999) {
            [obj setHidden:YES];
        }
    }];

}

- (void)showControlBar
{
    [[self.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 999) {
            [obj setHidden:NO];
        }
    }];
}



#pragma mark VAViewController View Size Control

- (void)becomeThumbnailView
{
    NSLog(@"%@ becomeThumbnailView", self);
    _webView.userInteractionEnabled = NO;
    [self hideControlBar];
    _matrixView.hidden = NO;
}

- (void)becomeMainView
{
    NSLog(@"%@ becomeMainView", self);
    _webView.userInteractionEnabled = YES;
    [self showControlBar];
    _matrixView.hidden = YES;
    
}



@end
