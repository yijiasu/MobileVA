//
//  VAUtil.h
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAVideoViewController.h"
#import "VADataCoordinator.h"
#import "VADataModel.h"
#import <AVFoundation/AVFoundation.h>


@interface VAUtil : NSObject

+ (instancetype)util;

@property (nonatomic, strong) VADataModel *model;
@property (nonatomic, strong) VADataCoordinator *coordinator;
@property (nonatomic, strong) VAService *service;

- (VAViewController *)getViewController:(VAViewControllerType)vcType;
- (void)registerViewController:(VAViewController *)viewController withType:(VAViewControllerType)vcType;
- (UIColor *)colorSchemaForMatrixIndex:(NSInteger)index;
- (NSString *)thumbnailIconTextForEgoPerson:(VAEgoPerson *)egoPerson;
- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer; // Create a CGImageRef from sample buffer data

@end
