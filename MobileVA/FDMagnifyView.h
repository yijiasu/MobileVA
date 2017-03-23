//
//  FDMagnifyView.h
//  FaceDetection
//
//  Created by Su Yijia on 3/2/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDMagnifyView : UIView

@property (nonatomic, strong) UIImage *snapshotImage;
@property (nonatomic) UIView *viewToMagnify;
@property (nonatomic) CGPoint pointToMagnify;

- (void)moveCenterPointTo:(CGPoint)centerPoint;

@end
