//
//  VAEgoPerson.m
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAEgoPerson.h"

@interface VAEgoPerson ()

@property (nonatomic, strong) NSMutableDictionary *egoDict;
@property (nonatomic, strong) NSArray *yearsArray;

@end

@implementation VAEgoPerson


@dynamic yearDict;

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _egoDict = [dict mutableCopy];
        
        _name = dict[@"name"];
        _startYear = [dict[@"startYear"] integerValue];
        _endYear = [dict[@"endYear"] integerValue];
        _neighborLen = [dict[@"neighborLen"] integerValue];
        _publication = [dict[@"publication"] integerValue];
        _yearsArray = [[dict[@"yearDict"] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return NSOrderedAscending;
            }
            else if ([obj1 integerValue] > [obj2 integerValue]) {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedSame;
            }
        }];
        
    }
    return self;
}

- (NSDictionary *)yearDict
{
    return _egoDict[@"yearDict"];
}

- (NSArray *)years
{
    return _yearsArray;
}

- (NSDictionary *)dictData
{
    return _egoDict;
}

- (NSDictionary *)tieStrengthForYear:(NSInteger)year
{
    NSDictionary *yearDict = [self yearDict][[NSString stringWithFormat:@"%ld", year]];
    if (yearDict) {
        return yearDict[@"tieStrength"];
    }
    return nil;
}
- (NSDictionary *)alterChangeForYear:(NSInteger)year
{
    NSDictionary *beforeYearDict;
    NSDictionary *thisYearDict = [self tieStrengthForYear:year];
    if (year == _startYear) {
        beforeYearDict = @{};
    }
    else
    {
        beforeYearDict = [self tieStrengthForYear:year-1];
    }
    
    NSInteger thisYearAlterCount = [[thisYearDict allKeys] count];
    NSMutableArray *newAlters = [NSMutableArray new];
    NSMutableArray *weakerAlters = [NSMutableArray new];
    NSMutableArray *sameAlters = [NSMutableArray new];
    NSMutableArray *strongerAlters = [NSMutableArray new];
    
    [thisYearDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (!beforeYearDict[key]) {
            [newAlters addObject:key];
        }
        else
        {
            NSInteger beforeValue = [beforeYearDict[key] integerValue];
            NSInteger currentValue = [obj integerValue];
            if (beforeValue < currentValue) {
                [strongerAlters addObject:key];
            }
            else if (beforeValue == currentValue) {
                [sameAlters addObject:key];
            }
            else
            {
                [weakerAlters addObject:key];
            }
        }
    }];
    
    return @{
             @"count"    : @(thisYearAlterCount),
             @"new"      : newAlters,
             @"same"     : sameAlters,
             @"weaker"   : weakerAlters,
             @"stronger" : strongerAlters
             };
    
}
- (CGFloat)densityForYear:(NSInteger)year
{
    NSDictionary *yearDict = [self yearDict][[NSString stringWithFormat:@"%ld", year]];
    return [yearDict[@"density"] floatValue];
}
- (NSInteger)secLevelAlterCountForYear:(NSInteger)year
{
    NSDictionary *yearDict = [self yearDict][[NSString stringWithFormat:@"%ld", year]];
    return [yearDict[@"secondDegreeNeighborList"] count];

}
- (NSInteger)publicationCountForYear:(NSInteger)year
{
    NSDictionary *yearDict = [self yearDict][[NSString stringWithFormat:@"%ld", year]];
    return [yearDict[@"publication"] integerValue];
}
@end
