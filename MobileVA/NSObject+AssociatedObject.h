//
//  NSObject+AssociatedObject.h
//  Midia
//
//  Created by LIMIO on 14-8-7.
//  Copyright (c) 2014年 Midia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AssociatedObject)
@property (nonatomic, strong) id associatedObject;
- (void)removeAssociatedObject;
@end
