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


@end

@implementation VAMatrixView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setMatrixDimension:(NSInteger)dim
{
    _viewArray = [NSMutableArray new];
    CGSize cellSize = CGSizeMake(self.frame.size.width / dim, self.frame.size.height / dim);
    
    for (int i = 0; i < dim; i++) {
        NSMutableArray *rowArray = [[NSMutableArray alloc] init];
        for (int j = 0; j < dim; j++) {
            VAMatrixCellView *cellView = [[VAMatrixCellView alloc] initWithFrame:CGRectMake(j * cellSize.width,
                                                                        i * cellSize.height,
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
    
    
}

- (void)pushValue:(NSInteger)value atPoint:(CGPoint)point
{
    VAMatrixCellView *view = [[_viewArray objectAtIndex:point.y] objectAtIndex:point.x];
    [view pushNewValue:value];
}

@end
