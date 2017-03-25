//
//  VAMatrixView.h
//  MobileVA
//
//  Created by Su Yijia on 3/19/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAMatrixCellView.h"

@interface VAMatrixView : UIView

@property NSInteger currentDimension;

- (void)setMatrixDimension:(NSInteger)dim;
- (void)pushValue:(NSInteger)value atPoint:(CGPoint)point;

@property (nonatomic, strong) VADataModel *dataModel;
@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, strong) NSArray<VAEgoPerson *> *egoList;
@property (nonatomic, strong) UIView *matrixPlaceholder;
@property BOOL shouldRefreshTitle;

- (void)drawMatrixPlaceholder;
- (void)removeMatrixPlaceholder;
- (void)refreshEgoTitle;
- (VAMatrixCellView *)getCellAtPoint:(CGPoint)point;

@end
