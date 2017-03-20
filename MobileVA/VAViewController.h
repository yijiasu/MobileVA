//
//  VAViewController.h
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAUtil.h"
#import "VADataModel.h"

@protocol VAViewControllerProtocol <NSObject>

@optional
- (void)becomeMainView;
- (void)becomeThumbnailView;

@end

@interface VAViewController : UIViewController <VAViewControllerProtocol>

@property (nonatomic) BOOL isMinimized;
@property (nonatomic, assign) VAViewControllerType type;
@property (nonatomic, strong) VADataModel *dataModel;

@end
