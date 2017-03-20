//
//  VADataModel.m
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VADataModel.h"
@interface VADataModel ()
@property (nonatomic, strong) UIImage *lastCaptureImage;

@end

@implementation VADataModel


#pragma mark Init & Singleton

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)sharedDataModel
{
    static VADataModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VADataModel alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (void)capturePersonImage:(UIImage *)image
{
    _lastCaptureImage = image;
    // TODO: 处理发送通知给VideoView
}


- (void)videoViewController:(VAVideoViewController *)videoVC donutDidScrollToIndex:(NSInteger)dountIndex
{
    NSString *yearOfSelection = [_currentEgoPerson.years objectAtIndex:dountIndex];
    NSLog(@"Did Scroll To Year = %@", yearOfSelection);
    [self setCurrentYear:[yearOfSelection integerValue]];
    
}



@end
