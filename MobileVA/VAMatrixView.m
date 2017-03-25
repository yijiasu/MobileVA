//
//  VAMatrixView.m
//  MobileVA
//
//  Created by Su Yijia on 3/19/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAMatrixView.h"
@interface VAMatrixView ()


@end

@implementation VAMatrixView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.dataModel = [VAUtil util].model;

        if (!_matrixPlaceholder) {
            
            _matrixPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 3, [UIScreen mainScreen].bounds.size.width / 3)];
            [_matrixPlaceholder setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.2]];
            
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 3, [UIScreen mainScreen].bounds.size.width / 3)];
            [textLabel setNumberOfLines:0];
            [textLabel setTextAlignment:NSTextAlignmentCenter];
            
            [textLabel setText:@"No Enough\nEgo Person"];
            
            [_matrixPlaceholder addSubview:textLabel];
            textLabel.center = _matrixPlaceholder.center;
            
            [_matrixPlaceholder setAlpha:0];
            [self addSubview:_matrixPlaceholder];
            
            _shouldRefreshTitle = YES;
        }

    }
    return self;
}

- (void)didMoveToSuperview
{
    [self drawMatrixPlaceholder];
}

- (void)setMatrixDimension:(NSInteger)dim
{
    if ([_viewArray count]) {
        [_viewArray enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperview];
            }];
        }];
    }
    
    _viewArray = [NSMutableArray new];
    CGSize cellSize = CGSizeMake((self.frame.size.width - MATRIX_BORDER_WIDTH) / dim, (self.frame.size.height - MATRIX_BORDER_WIDTH) / dim);
    
    for (int i = 0; i < dim; i++) {
        NSMutableArray *rowArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < dim; j++) {
            VAMatrixCellView *cellView = [[VAMatrixCellView alloc] initWithFrame:CGRectMake(j * cellSize.width + MATRIX_BORDER_WIDTH,
                                                                                            i * cellSize.height + MATRIX_BORDER_WIDTH,
                                                                                            cellSize.width,
                                                                                            cellSize.height) level:1];
//            CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
//            CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
//            CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
//            UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
            UIColor *color;
            if (i == j) {
                color = [UIColor lightGrayColor];
            }
            else
            {
                int index = i+j;
                color = [[VAUtil util] colorSchemaForMatrixIndex:index];
            }
            
            [cellView setBaseColor:color];
            [self addSubview:cellView];
            
            [rowArray addObject:cellView];
            
        }
        [_viewArray addObject:rowArray];
    }
    
    
    
    _currentDimension = dim;
    
}

- (void)clearAllTitles
{
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 999) {
            [obj removeFromSuperview];
        }
    }];

}
- (void)refreshEgoTitle
{
    if (!_shouldRefreshTitle) {
        return;
    }
    
    [self clearAllTitles];

    if ([_egoList count] < 2) {
        [self drawMatrixPlaceholder];
        return;
    }
    
    [self removeMatrixPlaceholder];
    
    
    CGSize cellSize = CGSizeMake((self.frame.size.width - MATRIX_BORDER_WIDTH) / _currentDimension, (self.frame.size.height - MATRIX_BORDER_WIDTH) / _currentDimension);
    
    // Set Up Title Views
    for (int i = 0; i < _currentDimension; i++) {
        UILabel *labelForRow = [[UILabel alloc] initWithFrame:CGRectMake(i * cellSize.width + MATRIX_BORDER_WIDTH,
                                                                         0,
                                                                         cellSize.width,
                                                                         MATRIX_BORDER_WIDTH)];
        UILabel *labelForCol = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                         i * cellSize.height + MATRIX_BORDER_WIDTH,
                                                                        MATRIX_BORDER_WIDTH,
                                                                         cellSize.height)];
        
        [labelForRow setTextAlignment:NSTextAlignmentCenter];
        [labelForCol setTextAlignment:NSTextAlignmentCenter];

        
        [labelForRow setFont:[UIFont systemFontOfSize:8.0f]];
        [labelForCol setFont:[UIFont systemFontOfSize:8.0f]];

        
        [labelForRow setText:[[VAUtil util] thumbnailIconTextForEgoPerson:_egoList[i]]];
        [labelForCol setText:[[VAUtil util] thumbnailIconTextForEgoPerson:_egoList[i]]];
        
        [labelForRow setTextColor:[[VAUtil util] colorSchemaForMatrixIndex:i]];
        [labelForCol setTextColor:[[VAUtil util] colorSchemaForMatrixIndex:i]];

        [labelForCol setTransform:CGAffineTransformMakeRotation(M_PI_2 + M_PI)];
        
        [self addSubview: labelForRow];
        [self addSubview: labelForCol];
        
        [labelForCol setTag:999];
        [labelForRow setTag:999];

    }
}

- (void)pushValue:(NSInteger)value atPoint:(CGPoint)point
{
    VAMatrixCellView *view = [[_viewArray objectAtIndex:point.y] objectAtIndex:point.x];
    [view pushNewValue:value];
}


- (void)drawMatrixPlaceholder
{
    [UIView animateWithDuration:0.3f animations:^{
        [_matrixPlaceholder setAlpha:1];
    }];
}

- (void)removeMatrixPlaceholder
{
    [UIView animateWithDuration:0.3f animations:^{
        [_matrixPlaceholder setAlpha:0];
    }];
}


- (VAMatrixCellView *)getCellAtPoint:(CGPoint)point
{
    return _viewArray[(int)point.x][(int)point.y];
}

@end
