//
//  NSObject+AssociatedObject.m
//  Midia
//
//  Created by LIMIO on 14-8-7.
//  Copyright (c) 2014年 Midia. All rights reserved.
//

#import "NSObject+AssociatedObject.h"
#import <objc/runtime.h>

@implementation NSObject (AssociatedObject)
@dynamic associatedObject;

- (void)setAssociatedObject:(id)object {
    objc_setAssociatedObject(self, @selector(associatedObject), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)associatedObject {
    return objc_getAssociatedObject(self, @selector(associatedObject));
}


- (void)removeAssociatedObject {
    objc_setAssociatedObject(self, @selector(associatedObject), nil, OBJC_ASSOCIATION_ASSIGN);
}

@end