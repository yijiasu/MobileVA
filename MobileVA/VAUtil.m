//
//  VAUtil.m
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAUtil.h"
#import "UIColor+Hex.h"
@interface VAUtil ()

@property (nonatomic, strong) NSMutableDictionary *viewControllerDictionary;
@property (nonatomic, strong) NSArray<UIColor *> *colorArray;

@end

@implementation VAUtil

+ (instancetype)util
{
    static VAUtil *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VAUtil alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _viewControllerDictionary = [NSMutableDictionary new];
        _colorArray = @[
                        [UIColor colorWithHex:0xa50026],
                        [UIColor colorWithHex:0x4575b4],  // was d73027
                        [UIColor colorWithHex:0xf46d43],
                        [UIColor colorWithHex:0xfdae61],
                        [UIColor colorWithHex:0xfee090],
                        [UIColor colorWithHex:0xffffbf],
                        [UIColor colorWithHex:0xe0f3f8],
                        [UIColor colorWithHex:0xabd9e9],
                        [UIColor colorWithHex:0x74add1],
                        [UIColor colorWithHex:0x4575b4],
                        [UIColor colorWithHex:0x313695]
                        ];
        
        

    }
    return self;
}


- (VAViewController *)getViewController:(VAViewControllerType)vcType
{
    return _viewControllerDictionary[@(vcType)];
}

- (void)registerViewController:(VAViewController *)viewController withType:(VAViewControllerType)vcType
{
    _viewControllerDictionary[@(vcType)] = viewController;
}

- (UIColor *)colorSchemaForMatrixIndex:(NSInteger)index
{
    return [_colorArray objectAtIndex:index];
}

- (NSString *)thumbnailIconTextForEgoPerson:(VAEgoPerson *)egoPerson
{
    NSString *name = egoPerson.name;
    NSArray *subnames = [name componentsSeparatedByString:@" "];
    NSMutableString *returnString = [NSMutableString new];
    [subnames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [returnString appendString:[obj substringWithRange:NSMakeRange(0, 1)]];
    }];
    return [[returnString substringWithRange:NSMakeRange(0, MIN(2, returnString.length))] uppercaseString];
                                                                
}

- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer // Create a CGImageRef from sample buffer data
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);        // Lock the image buffer
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);   // Get information of the image
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    CGContextRelease(newContext);
    
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    /* CVBufferRelease(imageBuffer); */  // do not call this!
    
    return newImage;
}

@end
