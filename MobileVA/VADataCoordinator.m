//
//  VADataCoordinator.m
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VADataCoordinator.h"

@interface VADataCoordinator ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *egoArray;
@property (nonatomic, strong) NSMutableArray *egoNameArray;
@property (nonatomic, strong) NSArray *ovRawArray;

@property (nonatomic, strong) NSMutableDictionary *ovDataDict;

@end

@implementation VADataCoordinator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _egoArray = [NSMutableArray new];
    }
    return self;
}

- (instancetype)initWithJSONFile:(NSString *)pathForJSONFile
{
    self = [self init];
    if (self) {
        
        NSData *jsonFileData = [NSData dataWithContentsOfFile:pathForJSONFile];
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:jsonFileData options:kNilOptions error:NULL];
        if (jsonData) {
            _dataArray = jsonData;
        }
        
        NSLog(@"Load Database Success! Record = %d", _dataArray.count);
        [self initAllEgoPerson];
    }
    return self;
}

- (void)loadOverviewDataFile:(NSString *)pathForOVDataFile
{
    NSData *jsonFileData = [NSData dataWithContentsOfFile:pathForOVDataFile];
    NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:jsonFileData options:kNilOptions error:NULL];
    if (jsonData) {
        _ovRawArray = jsonData;
    }
    
    NSLog(@"Load OVData Success! Record = %d", _ovRawArray.count);
    [self initAllOvData];

}

- (NSDictionary *)egoPersonDataWithName:(NSString *)egoName
{
    NSDictionary *returnDict;
    returnDict = Underscore.find(_dataArray, ^BOOL (NSDictionary *dict){
        return [dict[@"name"] isEqualToString:egoName];
    });
    return returnDict;
}

- (void)initAllEgoPerson
{
    [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull egoData, NSUInteger idx, BOOL * _Nonnull stop) {
        VAEgoPerson *egoPerson = [[VAEgoPerson alloc] initWithDictionary:egoData];
        if (egoPerson) {
            [_egoArray addObject:egoPerson];
        }
    }];
}

- (void)initAllOvData
{
    NSMutableDictionary *totalDict = [NSMutableDictionary new];
    for (NSDictionary *dict in _ovRawArray) {
        NSInteger yearOfData = [dict[@"key"] integerValue];
        NSDictionary *dataDict = dict[@"value"];
        
        NSMutableDictionary *myDict = [NSMutableDictionary new];
        [dataDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *posString = [NSString stringWithFormat:@"%f,%f", [obj[@"x"] floatValue], [obj[@"y"] floatValue]];
            myDict[key] = posString;
        }];
        
        totalDict[@(yearOfData)] = myDict;
    }
    
    _ovDataDict = totalDict;
}
- (VAEgoPerson *)egoPersonWithName:(NSString *)egoName
{
    VAEgoPerson *returnPerson;
    returnPerson = Underscore.find(_egoArray, ^BOOL(VAEgoPerson *person){
        return [person.name isEqualToString:egoName];
    });
    return returnPerson;
}

- (NSDictionary *)getOverviewDataForYear:(NSInteger)year
{
    __block NSDictionary *selectedData;
    [_ovRawArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"key"] isEqualToString:[NSString stringWithFormat:@"%ld", year]]) {
            selectedData = obj;
        }
    }];
    return selectedData;
}

- (NSDictionary *)queryEgoDistanceForYear:(NSInteger)year egoList:(NSArray<NSString *> *)egoList
{
    NSMutableDictionary *queryResult = [NSMutableDictionary new];
    NSDictionary *selectedDict = _ovDataDict[@(year)];
    [selectedDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([egoList containsObject:key]) {
            queryResult[key] = obj;
        }
    }];
    
    return queryResult;
    
}

- (NSDictionary *)queryTieStrengthForYear:(NSInteger)year egoList:(NSArray<NSString *> *)egoList
{
    NSMutableDictionary *returnResult = [NSMutableDictionary new];
    NSDictionary *yearDict = [self getOverviewDataForYear:year][@"value"];
    
    for (int i = 0; i < egoList.count; i++) {
        
        for (int k = i+1; k < egoList.count; k++) {
            NSString *primaryEgoName = egoList[i];
            NSString *compareEgoName = egoList[k];
            NSDictionary *tsArray = yearDict[primaryEgoName][@"info"][@"tieStrength"];
            if (tsArray[compareEgoName]) {
                returnResult[[NSString stringWithFormat:@"%@,%@", primaryEgoName, compareEgoName]] = tsArray[compareEgoName];
            }
        }
    }
    
    NSMutableDictionary *reverseDict = [NSMutableDictionary new];
    
    [returnResult enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSArray *tmpArray =  [key componentsSeparatedByString:@","];
        NSString *newKey = [NSString stringWithFormat:@"%@,%@", tmpArray[1], tmpArray[0]];
        reverseDict[newKey] = obj;
    }];
    
    [returnResult addEntriesFromDictionary:reverseDict];
    return returnResult;
    
}

- (NSArray<VAEgoPerson *> *)allEgoPersons
{
    return _egoArray;
}


- (void)retrieveEgoPersonDataViaRequest:(RouteRequest *)request withResponse:(RouteResponse *)response
{
    
    NSString *key = [request.params[@"wildcards"] firstObject];
    NSDictionary *returnDict = [self egoPersonDataWithName:key];
    if (returnDict) {
        [response setHeader:@"Content-Type" value:@"application/json"];
        [response respondWithString:[returnDict toJSONString]];
    }
    else
    {
        [response setStatusCode:404];
        [response respondWithString:@"Object Not Found"];
    }
    
}

- (void)retrieveOverviewDataViaRequest:(RouteRequest *)request withResponse:(RouteResponse *)response
{
    
    NSString *key = [request.params[@"wildcards"] firstObject];
    NSDictionary *returnDict = [self getOverviewDataForYear:[key integerValue]];
    if (returnDict) {
        [response setHeader:@"Content-Type" value:@"application/json"];
        [response respondWithString:[@[returnDict] toJSONString]];
    }
    else
    {
        [response setStatusCode:404];
        [response respondWithString:@"Object Not Found"];
    }
    
}

- (BOOL)isEgoPersonExisted:(NSString *)egoName
{
    if (!_egoNameArray) {
        _egoNameArray = [NSMutableArray new];
        [self.allEgoPersons enumerateObjectsUsingBlock:^(VAEgoPerson * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_egoNameArray addObject:obj.name];
        }];
    }
    
    if ([_egoNameArray containsObject:egoName]) {
        return YES;
    }
    else
    {
        return NO;
    }
    
}


@end
