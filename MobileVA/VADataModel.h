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

- (void)capturePersonImage:(UIImage *)image;



@property (nonatomic, strong) VAEgoPerson *currentEgoPerson;
@property NSInteger currentDonutIndex;
@property NSInteger currentYear;
@property VAViewControllerType activeViewType;

@end
