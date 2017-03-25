//
//  VATimeLineMatrixView.m
//  MobileVA
//
//  Created by Su Yijia on 3/23/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VATimeLineMatrixView.h"

@implementation VATimeLineMatrixView

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

    NSDictionary *queryResult = [coordinator queryTieStrengthForYear:newYear egoList:egoList];

    
    NSArray *calcArray = [self calcMatrixWithQueryResult:queryResult egoList:egoList];


    
    [calcArray enumerateObjectsUsingBlock:^(NSMutableArray *  _Nonnull subArray, NSUInteger idY, BOOL * _Nonnull stop) {
        [subArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idX, BOOL * _Nonnull stop) {
            VAMatrixCellView *cell = [self getCellAtPoint:CGPointMake(idX, idY)];
            NSInteger value = [obj integerValue];
            if (value != -1) {
                value = value * 40;
            }

            [cell setBaseColor:[[VAUtil util] colorSchemaForMatrixIndex:2]];
            [cell pushNewValue:value];
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

        NSMutableArray *rowArray = [NSMutableArray new];
        for (int j = 0; j < [egoList count]; j++) {
            NSString *keyName = [NSString stringWithFormat:@"%@,%@", egoList[i], egoList[j]];
            if (!result[keyName]) {
                [rowArray addObject:@(-1)];
            }
            else
            {
                [rowArray addObject:result[keyName]];
            }
        }
        [array addObject:rowArray];

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
