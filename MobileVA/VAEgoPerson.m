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

@end
