//
//  VAMatrixView.m
//  MobileVA
//
//  Created by Su Yijia on 3/19/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAMatrixView.h"
#import "VAMatrixCellView.h"
@interface VAMatrixView ()

@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic, strong) NSArray<VAEgoPerson *> *egoList;
@property (nonatomic, strong) VADataModel *dataModel;
@property (nonatomic, strong) UIView *matrixPlaceholder;
@property BOOL shouldRefreshTitle;

@end

@implementation VAMatrixView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.dataModel = [VAUtil util].model;
        if (self.dataModel) {
            [self.dataModel addObserver:self forKeyPath:@"currentYear" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
            [self.dataModel addObserver:self forKeyPath:@"selectedEgoPerson" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        }
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

- (void)dealloc
{
    [self.dataModel removeObserver:self forKeyPath:@"selectedEgoPerson"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedEgoPerson"]) {
        _egoList = change[NSKeyValueChangeNewKey];
        _shouldRefreshTitle = YES;
        [self redrawMatrixViewForYear:self.dataModel.currentYear];

    }
    else if ([keyPath isEqualToString:@"currentYear"]) {
        [self redrawMatrixViewForYear:self.dataModel.currentYear];
    }
    
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


- (void)redrawMatrixViewForYear:(NSInteger)newYear
{
    VADataCoordinator *coordinator = [VAUtil util].coordinator;
    
    NSArray *egoList = [self.dataModel egoPersonNameArray];
    
    // Check Dimesion
    if (self.currentDimension != [self.dataModel.selectedEgoPerson count]) {
        [self setMatrixDimension:[self.dataModel.selectedEgoPerson count]];
    }
    
    NSDictionary *result = [coordinator queryEgoDistanceForYear:newYear egoList:egoList];
    
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i < [egoList count]; i++) {
        NSString *yValue = result[egoList[i]];
        if (!yValue) {
            NSMutableArray *tmpArray = [NSMutableArray new];
            for (int k = 0; k < [egoList count]; k++) {
                [tmpArray addObject:@(-1)];
            }
            [array addObject:tmpArray];
        }
        else
        {
            NSMutableArray *rowArray = [NSMutableArray new];
            for (int j = 0; j < [egoList count]; j++) {
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
            [self pushValue:[value integerValue] atPoint:CGPointMake(idX, idY)];
        }];
    }];
    
    [self refreshEgoTitle];

}


@end
