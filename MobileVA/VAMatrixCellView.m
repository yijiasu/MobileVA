//
//  VAMatrixCellView.m
//  MobileVA
//
//  Created by Su Yijia on 3/19/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAMatrixCellView.h"

@interface VAMatrixCellView ()

@property NSInteger level;
@property (nonatomic, strong) NSMutableArray *viewArray; // 0-Top N-Bottom
@property (nonatomic, strong) NSMutableArray *valueArray; // 0-Top N-Bottom

@end

@implementation VAMatrixCellView

- (instancetype)initWithFrame:(CGRect)frame level:(NSInteger)level
{
    self = [self initWithFrame:frame];
    if (self) {

        
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        _level = level;
        _viewArray = [NSMutableArray new];
        _valueArray = [NSMutableArray new];
        NSInteger smallCellNumber = level * 2 - 1;
        CGSize smallSize = CGSizeMake(self.frame.size.width / smallCellNumber, self.frame.size.height / smallCellNumber);
        
        for (int i = 1; i <= level; i++) {
            NSInteger distance = level - i;
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(distance * smallSize.width,
                                                                 distance * smallSize.height,
                                                                 (2 * i - 1) * smallSize.width,
                                                                 (2 * i - 1) * smallSize.height)];
            [v setBackgroundColor:[UIColor clearColor]];
            [self insertSubview:v atIndex: distance];
            
            [_viewArray addObject:v];
        }
        
    }
    return self;
}

- (void)pushNewValue:(NSInteger)value
{
    [_valueArray insertObject:@(value) atIndex:0];
    if ([_valueArray count] > _level) {
//        while ([_valueArray count] > _level) {
            [_valueArray removeObjectAtIndex:_valueArray.count -1];
//        }
    }
    
    [self refreshViewLevel];
}

- (void)refreshViewLevel
{
    [_viewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > _valueArray.count - 1) {
            return ;
        }
        NSInteger value = [[_valueArray objectAtIndex:idx] integerValue];
        if (value == -1) {
            [view setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3]];
        }
        else
        {
            [view setBackgroundColor:[_baseColor colorWithAlphaComponent:value / 255.0]];
        }
    }];
}
@end
