//
//  FDSmoother.h
//  FaceDetection
//
//  Created by Su Yijia on 2/26/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FDSmootherDataDelegate <NSObject>

- (void)smootherDidOutputSingleData:(CGRect)rectData;

@optional
- (void)smootherDidOutputDataArray:(NSArray *)rectData;

@end

@interface FDSmoother : NSObject

- (instancetype)initWithMAWindowSize:(NSUInteger)wSize;
- (instancetype)initWithMAWindowSizeForSize:(NSUInteger)sizeWindow location:(NSUInteger)locWindow;
- (void)inputData:(NSArray *)rectValueObjects;

@property (nonatomic, weak) id<FDSmootherDataDelegate> delegate;
@property BOOL enabled;

@end
