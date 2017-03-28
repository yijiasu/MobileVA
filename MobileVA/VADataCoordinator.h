//
//  VADataCoordinator.h
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAEgoPerson.h"

@interface VADataCoordinator : NSObject

- (instancetype)initWithJSONFile:(NSString *)pathForJSONFile;
- (void)loadOverviewDataFile:(NSString *)pathForOVDataFile;
- (NSDictionary *)egoPersonDataWithName:(NSString *)egoName;
- (VAEgoPerson *)egoPersonWithName:(NSString *)egoName;
- (NSDictionary *)queryEgoDistanceForYear:(NSInteger)year egoList:(NSArray<NSString *> *)egoList;
- (NSDictionary *)queryTieStrengthForYear:(NSInteger)year egoList:(NSArray<NSString *> *)egoList;
- (NSArray<VAEgoPerson *> *)allEgoPersons;
- (BOOL)isEgoPersonExisted:(NSString *)egoName;

// HTTP Server
- (void)retrieveEgoPersonDataViaRequest:(RouteRequest *)request withResponse:(RouteResponse *)response;
- (void)retrieveOverviewDataViaRequest:(RouteRequest *)request withResponse:(RouteResponse *)response;

@end
