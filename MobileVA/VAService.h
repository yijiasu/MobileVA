//
//  VAService.h
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAEgoPerson.h"

typedef void (^ImageRecognizeBlock)(BOOL isSuccess, VAEgoPerson* egoPerson, NSInteger imageID);
@interface VAService : NSObject

+ (instancetype)defaultService;

- (BOOL)startHTTPServer;
- (void)stopHTTPServer;

- (NSString *)getBaseURL;
- (NSString *)URLWithComponent:(NSString *)component;
- (NSString *)URLWithComponent:(NSString *)component width:(NSInteger)width height:(NSInteger)height;
- (NSString *)URLWithComponent:(NSString *)component width:(NSInteger)width height:(NSInteger)height params:(NSDictionary *)params;

- (void)imageRecoginzeForImage:(UIImage *)imageToRecoginze imageID:(NSInteger)imageID completionBlock:(ImageRecognizeBlock)block;

@end
