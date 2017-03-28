//
//  VAMDSMatrixView.m
//  MobileVA
//
//  Created by Su Yijia on 3/23/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAMDSMatrixView.h"
#import "UIColor+Hex.h"
@implementation VAMDSMatrixView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (self.dataModel) {
            [self.dataModel addObserver:self forKeyPath:@"currentYear" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
            [self.dataModel addObserver:self forKeyPath:@"selectedEgoPerson" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        }
    }
    return self;
}

- (void)redrawCompareMatrixViewForYear:(NSInteger)newYear compareOption:(VADonutSlideDirection)option
{
    VADataCoordinator *coordinator = [VAUtil util].coordinator;
    
    NSArray *egoList = [self.dataModel egoPersonNameArray];
    
    // Check Dimesion
    if (self.currentDimension != [self.dataModel.selectedEgoPerson count]) {
        [self setMatrixDimension:[self.dataModel.selectedEgoPerson count]];
    }
    
    NSInteger compareYear = newYear + (option == VADonutSlideDirectionAsceding ? -1 : 1);
    NSDictionary *firstResult = [coordinator queryEgoDistanceForYear:newYear egoList:egoList];
    NSDictionary *secondResult = [coordinator queryEgoDistanceForYear:compareYear egoList:egoList];

    NSArray *firstCalc = [[self calcMatrixWithQueryResult:firstResult egoList:egoList] mutableCopy];
//    NSArray *secondCalc = [self calcMatrixWithQueryResult:secondResult egoList:egoList];
    
//    [firstCalc enumerateObjectsUsingBlock:^(NSMutableArray *  _Nonnull subArray, NSUInteger idY, BOOL * _Nonnull stop) {
//        [subArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idX, BOOL * _Nonnull stop) {
//            if ([obj integerValue] == -1 || [secondCalc[idY][idX] integerValue] == -1)
//            {
//                [subArray setObject:@(-1) atIndexedSubscript:idX];
//            }
//            else
//            {
//                [subArray setObject:@([obj integerValue] - [secondCalc[idY][idX] integerValue]) atIndexedSubscript:idX];
//            }
//        }];
//    }];
    
    [firstCalc enumerateObjectsUsingBlock:^(NSMutableArray *  _Nonnull subArray, NSUInteger idY, BOOL * _Nonnull stop) {
        [subArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idX, BOOL * _Nonnull stop) {
            VAMatrixCellView *cell = [self getCellAtPoint:CGPointMake(idX, idY)];
            NSInteger value = [obj integerValue];
            if (value > 0) {
                [cell setBaseColor:[UIColor colorWithHex:0xfeb958]];
                [cell pushNewValue: 1.0 / (value) * 10000 ];
                NSLog(@"%lf",  1.0 / (value));
            }
            else
            {
                [cell pushNewValue:value];
            }

            //            else if(value == -1)
//            {
//                [cell setBaseColor:[UIColor blueColor]];
//            }
//            else
//            {
//                [cell setBaseColor:[UIColor whiteColor]];
//            }
            
        }];
    }];

//    [array enumerateObjectsUsingBlock:^(NSArray * _Nonnull subArray, NSUInteger idY, BOOL * _Nonnull stop) {
//        [subArray enumerateObjectsUsingBlock:^(NSNumber  * _Nonnull value, NSUInteger idX, BOOL * _Nonnull stop) {
//            [self pushValue:[value integerValue] atPoint:CGPointMake(idX, idY)];
//        }];
//    }];
    
    [self refreshEgoTitle];
    
}

- (NSArray *)calcMatrixWithQueryResult:(NSDictionary *)result egoList:(NSArray *)egoList
{
    
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
    return array;
}

- (void)dealloc
{
    [self.dataModel removeObserver:self forKeyPath:@"selectedEgoPerson"];
    [self.dataModel removeObserver:self forKeyPath:@"currentYear"];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedEgoPerson"]) {
        self.egoList = change[NSKeyValueChangeNewKey];
        self.shouldRefreshTitle = YES;
        [self redrawCompareMatrixViewForYear:self.dataModel.currentYear compareOption:self.dataModel.slidingDirection];
        
    }
    else if ([keyPath isEqualToString:@"currentYear"]) {
        [self redrawCompareMatrixViewForYear:self.dataModel.currentYear compareOption:self.dataModel.slidingDirection];
    }
    
}


@end
