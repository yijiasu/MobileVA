//
//  VAVideoViewController.h
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAViewController.h"
#import "VAEgoPerson.h"
#import "VADataModel.h"

@class VAVideoViewController;

@protocol VAVideoViewControllerDelegate <NSObject>

- (void)videoViewController:(VAVideoViewController *)videoVC donutDidScrollToIndex:(NSInteger)dountIndex;

@end

@interface VAVideoViewController : VAViewController <VAViewControllerProtocol>

- (void)loadEgoPerson:(VAEgoPerson *)egoPerson;

@property (nonatomic, weak) id<VAVideoViewControllerDelegate> dataModel;

@end
