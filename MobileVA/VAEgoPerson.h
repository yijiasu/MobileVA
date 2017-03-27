//
//  VAEgoPerson.h
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VAEgoPerson : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, strong) NSString *name;
@property NSInteger startYear;
@property NSInteger endYear;
@property NSInteger publication;
@property NSInteger neighborLen;

@property (readonly) NSDictionary *yearDict;
@property (readonly) NSArray *years;


@property (readonly) NSDictionary *dictData;

- (NSDictionary *)alterChangeForYear:(NSInteger)year;
- (CGFloat)densityForYear:(NSInteger)year;
- (NSInteger)secLevelAlterCountForYear:(NSInteger)year;
- (NSInteger)publicationCountForYear:(NSInteger)year;

@end
