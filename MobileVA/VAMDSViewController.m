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
#import "VAMatrixView.h"

@interface VAMDSViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge* bridge;                  // JS Bridge For WebView
@property (nonatomic, strong) VAMatrixView *matrixView;

@end

@implementation VAMDSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.type = VAViewControllerTypeMDS;
    [self configureWebView];
    
    _matrixView = [[VAMatrixView alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 [UIScreen mainScreen].bounds.size.width / 3,
                                                                 [UIScreen mainScreen].bounds.size.width / 3)];
    
    [_matrixView setMatrixDimension:3];
    [_matrixView setHidden:NO];
    [self.view addSubview:_matrixView];
    
    
    if (self.dataModel) {
        [self.dataModel addObserver:self forKeyPath:@"currentYear" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
    }
    
}

- (void)dealloc
{
    [self.dataModel removeObserver:self forKeyPath:@"currentYear"];
    
}
- (void)configureWebView
{
    NSString *urlString = [[VAService defaultService] URLWithComponent:@"mds.html"
                                                                 width:_webView.frame.size.width
                                                                height:_webView.frame.size.height];
    [self registerJSHandler];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    self.webView.userInteractionEnabled = NO;
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentYear"]) {
        NSLog(@"%@", change);
        NSInteger newYear = [change[NSKeyValueChangeNewKey] integerValue];
        VADataCoordinator *coordinator = [VAUtil util].coordinator;
        
        NSArray *egoList = @[@"Hans-Peter Seidel", @"Kwan-Liu Ma", @"Huamin Qu"];
        NSDictionary *result = [coordinator queryEgoDistanceForYear:newYear egoList:egoList];
        
        NSMutableArray *array = [NSMutableArray new];
        for (int i = 0; i < 3; i++) {
            NSString *yValue = result[egoList[i]];
            if (!yValue) {
                [array addObject:@[@(-1), @(-1), @(-1)]];
            }
            else
            {
                NSMutableArray *rowArray = [NSMutableArray new];
                for (int j = 0; j < 3; j++) {
                    NSString *xValue = result[egoList[j]];
                    if (!xValue) {
                        [rowArray addObject:@(-1)];
                    }
                    else
                    {
                        NSArray *p1Array = [yValue componentsSeparatedByString:@","];
                        NSArray *p2Array = [xValue componentsSeparatedByString:@","];
                        CGPoint p1 = CGPointMake([p1Array[0] floatValue], [p1Array[1] floatValue]);
                        CGPoint p2 = CGPointMake([p2Array[0] floatValue], [p2Array[1] floatValue]);
                        
                        CGFloat distance = sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
                        
                        [rowArray addObject:@(distance * 40)];
                    }
                }
                [array addObject:rowArray];
            }

        }
        NSLog(@"Query Result = %@", result);
        NSLog(@"Calc Result = %@", array);
        
        [array enumerateObjectsUsingBlock:^(NSArray * _Nonnull subArray, NSUInteger idY, BOOL * _Nonnull stop) {
            [subArray enumerateObjectsUsingBlock:^(NSNumber  * _Nonnull value, NSUInteger idX, BOOL * _Nonnull stop) {
                [_matrixView pushValue:[value integerValue] atPoint:CGPointMake(idX, idY)];
            }];
        }];

    }
}


#pragma mark Register JS Handler

- (void)registerJSHandler
{
    // Configure Bridege
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
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
