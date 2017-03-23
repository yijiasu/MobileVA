//
//  VAHomeViewController.m
//  MobileVA
//
//  Created by Su Yijia on 3/18/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAHomeViewController.h"
#import "VAViewController.h"
@interface VAHomeViewController ()

@property (nonatomic, strong) VAVideoViewController *videoVC;
@property (nonatomic, strong) VAViewController *mdsVC;
@property (nonatomic, strong) VAViewController *tlVC;
@property (nonatomic, strong) VAViewController *tableVC;

@property (nonatomic, strong) VADataModel *dataModel;

@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIView *mdsView;
@property (weak, nonatomic) IBOutlet UIView *tlView;
@property (weak, nonatomic) IBOutlet UIView *tableView;

@property (nonatomic) VAViewControllerType activeViewType;
@property (nonatomic, strong) NSMutableArray *thumbnailOrder;


@property CGSize screenSize;
@property CGSize thumbnailSize;
@property CGSize mainViewSize;

@end

@implementation VAHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _thumbnailOrder = [@[@(VAViewControllerTypeMDS),
                         @(VAViewControllerTypeTimeLine),
                         @(VAViewControllerTypeTable)] mutableCopy];
    _activeViewType = VAViewControllerTypeVideo;
    
    [self configureData];
    [self configureView];
    [self relocateViews];
    
    self.dataModel.activeViewType = _activeViewType;

    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"view did appear");
    
    // Configure Data Model
    
    
}

- (void)configureData
{
    if (!_dataModel) {
        _dataModel = [VADataModel sharedDataModel];
    }
    
    VADataCoordinator *data = [[VAUtil util] coordinator];
    if (data) {
//        VAEgoPerson *person = [data egoPersonWithName:@"Hans-Peter Seidel"];
//        [_videoVC loadEgoPerson:person];
//        [_dataModel setCurrentEgoPerson:person];
    }
//    
//    if (!_thumbnailViews) {
//        _thumbnailViews = [NSMutableArray new];
//        [_thumbnailViews addObject:_mdsView];
//        [_thumbnailViews addObject:_tlView];
//        [_thumbnailViews addObject:_tableView];
//    }

}

- (void)relocateViews
{
    // Determine View
    UIView *mainView = [self getViewByType:_activeViewType];
    UIView *leftView = [self getViewByType:[_thumbnailOrder[0] integerValue]];
    UIView *midView = [self getViewByType:[_thumbnailOrder[1] integerValue]];
    UIView *rightView = [self getViewByType:[_thumbnailOrder[2] integerValue]];
    
    _screenSize = [UIScreen mainScreen].bounds.size;
    _thumbnailSize = CGSizeMake(_screenSize.width / 3, _screenSize.width / 3);
    _mainViewSize = CGSizeMake(_screenSize.width, _screenSize.height - _thumbnailSize.height - 20);
    
    [mainView  setFrame: CGRectMake(0, 0, _mainViewSize.width, _mainViewSize.height)];
    
    [leftView  setFrame: CGRectMake(0,
                                    _mainViewSize.height + 20,
                                    _thumbnailSize.width,
                                    _thumbnailSize.height)];
    
    [midView   setFrame: CGRectMake(_thumbnailSize.width,
                                    _mainViewSize.height + 20,
                                    _thumbnailSize.width,
                                    _thumbnailSize.height)];
    
    [rightView setFrame: CGRectMake(_thumbnailSize.width * 2,
                                    _mainViewSize.height + 20,
                                    _thumbnailSize.width,
                                    _thumbnailSize.height)];
    
//    [(VAViewController *)[mainView  associatedObject] setIsMinimized:NO];
//    [(VAViewController *)[leftView  associatedObject] setIsMinimized:YES];
//    [(VAViewController *)[midView   associatedObject] setIsMinimized:YES];
//    [(VAViewController *)[rightView associatedObject] setIsMinimized:YES];

    
}

- (UIView *)getViewByType:(VAViewControllerType)viewType
{
    UIView *mainView;
    if (viewType == VAViewControllerTypeVideo) {
        mainView = _videoView;
    }
    else if (viewType == VAViewControllerTypeMDS) {
        mainView = _mdsView;
    }
    else if (viewType == VAViewControllerTypeTimeLine) {
        mainView = _tlView;
    }
    else if (viewType == VAViewControllerTypeTable) {
        mainView = _tableView;
    }

    return mainView;

}

- (void)configureView
{
    [_videoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnView:)]];
    [_mdsView   addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnView:)]];
    [_tlView    addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnView:)]];
    [_tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnView:)]];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"embed_main"]) {
        _videoVC = [segue destinationViewController];
        [_videoVC setAssociatedObject:_videoView];
        [_videoView setAssociatedObject:_videoVC];
        [_videoVC setIsMinimized:NO];
        NSLog(@"embed_main");
    }
    else if ([[segue identifier] isEqualToString:@"embed_left"]) {
        _mdsVC = [segue destinationViewController];
        [_mdsVC setAssociatedObject:_mdsView];
        [_mdsView setAssociatedObject:_mdsVC];
        [_mdsVC setIsMinimized:YES];
        CGSize mainViewSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,
                                         [UIScreen mainScreen].bounds.size.height - 1/3  * [UIScreen mainScreen].bounds.size.width - 20);

        [_mdsVC setValue:[NSValue valueWithCGSize:mainViewSize] forKey:@"MDSViewSize"];
        NSLog(@"embed_LEFT");
    }
    else if ([[segue identifier] isEqualToString:@"embed_mid"]) {
        _tlVC = [segue destinationViewController];
        [_tlVC setAssociatedObject:_tlView];
        [_tlView setAssociatedObject:_tlVC];
        [_tlVC setIsMinimized:YES];

        NSLog(@"embed_MID");
    }
    else if ([[segue identifier] isEqualToString:@"embed_right"]) {
        _tableVC = [segue destinationViewController];
        [_tableVC setAssociatedObject:_tableView];
        [_tableView setAssociatedObject:_tableVC];
        [_tableVC setIsMinimized:YES];

        NSLog(@"embed_RIGHT");
    }
    

    

    

}

- (void)handleTapOnView:(UITapGestureRecognizer *)gestureRecognizer
{

//    // Check if the tap is ON THE MAIN View
//    // If so just ignore
    VAViewController *vc = (VAViewController *)[gestureRecognizer.view associatedObject];
    NSLog(@"Tap On %@", vc);

    [self setActiveViewType:vc.type];
    
}

- (void)setActiveViewType:(VAViewControllerType)activeViewType
{
    if (_activeViewType == activeViewType) {
        return;
    }
    
    [_thumbnailOrder addObject:@(_activeViewType)];
    [_thumbnailOrder removeObject:@(activeViewType)];
    _activeViewType = activeViewType;
    _dataModel.activeViewType = activeViewType;
//    [_dataModel setValue:@(activeViewType) forKey:@"activeViewType"];
    [self relocateViews];
    [self refreshGestureRecogizer];
}

- (void)refreshGestureRecogizer
{
    [[[[self getViewByType:_activeViewType] gestureRecognizers] firstObject] setEnabled:NO];
    for (NSNumber *type in _thumbnailOrder) {
        [[[[self getViewByType:[type integerValue]] gestureRecognizers] firstObject] setEnabled:YES];
    }
}


@end
