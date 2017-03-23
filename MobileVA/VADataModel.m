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
@property NSInteger videoInputIndex;

@end

@implementation VADataModel


#pragma mark Init & Singleton

- (instancetype)init
{
    self = [super init];
    if (self) {
        _selectedEgoPerson = [NSMutableArray new];
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
    NSString *yearOfSelection = [self.currentEgoPerson.years objectAtIndex:dountIndex];
    NSLog(@"Did Scroll To Year = %@", yearOfSelection);
    [self setCurrentYear:[yearOfSelection integerValue]];
    
}

- (VAEgoPerson *)currentEgoPerson
{
    
    __block VAEgoPerson *focusPerson;
    
    [self.selectedEgoPerson enumerateObjectsUsingBlock:^(VAEgoPerson * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj associatedObject] && [[obj associatedObject] boolValue] == YES) {
            focusPerson = obj;
        }
    }];
    if (focusPerson) {
        return focusPerson;
    }
    else
    {
        return [_selectedEgoPerson firstObject];
    }

}

- (NSArray<NSString *> *)egoPersonNameArray
{
    NSMutableArray *selectedName = [NSMutableArray new];
    [_selectedEgoPerson enumerateObjectsUsingBlock:^(VAEgoPerson * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [selectedName addObject:obj.name];
    }];
    return selectedName;
}

- (void)inputEgoPersonFromVideo:(VAEgoPerson *)egoPerson
{
    if (egoPerson) {
        if ([self.selectedEgoPerson containsObject:egoPerson]) {
            return;
        }
        
        [egoPerson setAssociatedObject:@(YES)];
        
        NSMutableArray *egoPersons = [self.selectedEgoPerson mutableCopy];
        [egoPersons addObject:egoPerson];
        
        if ([egoPersons count] > 5) {
            [egoPersons removeObjectAtIndex:0];
        }
        
        self.selectedEgoPerson = egoPersons;
    }
}

- (void)removeEgoPersonFromVideo
{
    __block NSInteger indexToRemove = -1;
    [self.selectedEgoPerson enumerateObjectsUsingBlock:^(VAEgoPerson * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj associatedObject] && [[obj associatedObject] boolValue] == YES) {
            indexToRemove = idx;
        }
    }];
    
    if (indexToRemove != -1) {
        NSMutableArray *egoPersons = [self.selectedEgoPerson mutableCopy];
        [egoPersons removeObjectAtIndex:indexToRemove];
        self.selectedEgoPerson = egoPersons;
    }
}

@end
