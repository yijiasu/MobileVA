//
//  FDSmoother.m
//  FaceDetection
//
//  Created by Su Yijia on 2/26/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDSmoother.h"

@interface FDSmoother ()

@property (nonatomic, strong) NSMutableArray *sizeArray;
@property (nonatomic, strong) NSMutableArray *locArray;

@property NSUInteger sizeWindow;
@property NSUInteger locWindow;

@end

@implementation FDSmoother

- (instancetype)initWithMAWindowSizeForSize:(NSUInteger)sizeWindow location:(NSUInteger)locWindow
{
    self = [super init];
    if (self) {
        _enabled = YES;
        _sizeWindow = sizeWindow;
        _locWindow = locWindow;
        _sizeArray = [[NSMutableArray alloc] init];
        _locArray = [[NSMutableArray alloc] init];
    }
    
    return self;

}
- (instancetype)initWithMAWindowSize:(NSUInteger)wSize
{
    return [self initWithMAWindowSizeForSize:wSize location:wSize];
}

- (void)inputData:(NSArray *)rectValueObjects
{
    // TO-DO: implement multi-frame logic
    if ([rectValueObjects count] != 1) {
        return;
    }
    
    if (!_enabled) {
        
        if ([_sizeArray count] != 0 || [_locArray count] != 0) {
            [_sizeArray removeAllObjects];
            [_locArray removeAllObjects];
        }
        
        CGRect rect = [[rectValueObjects firstObject] CGRectValue];
        [self.delegate smootherDidOutputSingleData:rect];

        
    }
    else
    {
        [_sizeArray addObject:[rectValueObjects firstObject]];
        [_locArray addObject:[rectValueObjects firstObject]];
        if (_sizeArray.count >= _sizeWindow + 1) {
            [_sizeArray removeObjectAtIndex:0];
        }
        
        if (_locArray.count >= _locWindow + 1) {
            [_locArray removeObjectAtIndex:0];
        }
        
        if (_sizeArray.count >= _sizeWindow  && _locArray.count >= _locWindow ) {
            [self outputData];
        }

    }
    
    
}

- (void)outputData
{
    // Calc MA Value
    float x = 0, y = 0, w = 0, h = 0;
    
    
    for (NSValue *rectValue in _locArray) {
        CGRect rect = [rectValue CGRectValue];
        x += rect.origin.x;
        y += rect.origin.y;
    }
    

    for (NSValue *rectValue in _sizeArray) {
        CGRect rect = [rectValue CGRectValue];
        w += rect.size.width;
        h += rect.size.height;
    }
    
    x = x / _locWindow;
    y = y / _locWindow;
    w = w / _sizeWindow;
    h = h / _sizeWindow;
    
    [self.delegate smootherDidOutputSingleData:CGRectMake(x, y, w, h)];
}

@end
