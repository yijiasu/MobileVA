//
//  VAMatrixView.h
//  MobileVA
//
//  Created by Su Yijia on 3/19/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VAMatrixView : UIView

- (void)setMatrixDimension:(NSInteger)dim;
- (void)pushValue:(NSInteger)value atPoint:(CGPoint)point;

@end
