//
//  VATypeDefine.h
//  MobileVA
//
//  Created by Su Yijia on 3/18/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#ifndef VATypeDefine_h
#define VATypeDefine_h

typedef NS_ENUM(NSInteger, VAViewControllerType) {
    VAViewControllerTypeVideo,
    VAViewControllerTypeMDS,
    VAViewControllerTypeTimeLine,
    VAViewControllerTypeTable
};

typedef NS_ENUM(NSUInteger, VAThumbnailPosition) {
    VAThumbnailPositionLeft,
    VAThumbnailPositionMid,
    VAThumbnailPositionRight
};


typedef NS_ENUM(NSUInteger, VADonutSlideDirection) {
    VADonutSlideDirectionAsceding,
    VADonutSlideDirectionDesceding
};




#endif /* VATypeDefine_h */
