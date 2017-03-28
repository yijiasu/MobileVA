//
//  VADataModel.h
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAEgoPerson.h"
@interface VADataModel<VAVideoViewControllerDelegate> : NSObject

+ (instancetype)sharedDataModel;


@property (nonatomic, strong) NSArray<VAEgoPerson *> *selectedEgoPerson;
@property (readonly) VAEgoPerson *currentEgoPerson;
@property NSInteger currentDonutIndex;
@property NSInteger currentYear;
@property VAViewControllerType activeViewType;
@property (nonatomic, strong) UIImage *croppedVideoImage;
@property (nonatomic, strong) UIImage *MDSEgoPersonImage;
@property VADonutSlideDirection slidingDirection;                               // 1-> sliding to bottom, -1 -> sliding to top
@property (nonatomic, strong) NSArray *currentMDSMatrixData;

- (void)inputEgoPersonFromVideo:(VAEgoPerson *)egoPerson;
- (void)removeEgoPersonFromVideo;
- (void)capturePersonImage:(UIImage *)image;
- (NSArray<NSString *> *)egoPersonNameArray;
- (BOOL)isSelectedEgoPersonWithName:(NSString *)egoPersonName;
- (void)submitLastImageToMDS;

@end
