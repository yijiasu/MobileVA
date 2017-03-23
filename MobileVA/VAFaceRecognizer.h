//
//  VAFaceRecognizer.h
//  MobileVA
//
//  Created by Su Yijia on 3/23/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VAFaceRecognizerDelegate <NSObject>

- (void)didRecognizeImageID:(NSInteger)imageID withEgoPerson:(VAEgoPerson *)egoPerson;

@end

@interface VAFaceRecognizer : NSObject

- (void)recognizeImage:(UIImage *)image withImageID:(NSInteger)imageID;
@property id<VAFaceRecognizerDelegate> delegate;

@end
