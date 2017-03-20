//
//  NSDictionary+JSON.m
//  MobileVA
//
//  Created by Su Yijia on 3/17/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

- (NSString *)toJSONString
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

}

@end
