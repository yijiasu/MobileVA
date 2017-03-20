//
//  NSString+JSON.m
//  MobileVA
//
//  Created by Su Yijia on 3/17/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@implementation NSString (NSString_NSJSONSerialization)
-(id)toArray {
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id array = [NSJSONSerialization JSONObjectWithData:jsonData
                                               options:NSJSONReadingAllowFragments
                                                 error:&error];
    return array;
}

-(id)toDict {
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    id dict = [NSJSONSerialization JSONObjectWithData:jsonData
                                              options:NSJSONReadingAllowFragments
                                                error:&error];
    return dict;
}
@end
