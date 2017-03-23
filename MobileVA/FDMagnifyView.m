//
//  FDMagnifyView.m
//  FaceDetection
//
//  Created by Su Yijia on 3/2/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "FDMagnifyView.h"

const NSUInteger CROSS_SIZE = 10;
const NSUInteger VIEW_SIZE = 64 * 2 + 1;

@interface FDMagnifyView () <CALayerDelegate>

@property (strong, nonatomic) CALayer *contentLayer;
@property (strong, nonatomic) UIImageView *imageView;
@property CGFloat scale;

@end

@implementation FDMagnifyView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 129, 129);
        self.backgroundColor = [UIColor clearColor];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 129, 129)];
        self.imageView.contentMode = UIViewContentModeTopLeft;
        
        [self addSubview:_imageView];
        
        [self drawRedCross];
        
        _scale = [UIScreen mainScreen].scale;
        
        _imageView.layer.transform = CATransform3DMakeScale(2.0, 2.0, 1.0);
        
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 64;
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 64;
        
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];

    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/
//
//
//- (id)init
//{
//    self = [super init];
//    if (self) {
//        self.frame = CGRectMake(0, 0, 129, 129);
//        self.backgroundColor = [UIColor clearColor];
//        self.layer.borderWidth = 1;
//        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//        self.layer.cornerRadius = 60;
//        self.layer.masksToBounds = YES;
////        self.windowLevel = UIWindowLevelAlert;
//        
//        self.contentLayer = [CALayer layer];
//        self.contentLayer.frame = self.bounds;
//        self.contentLayer.delegate = self;
//        self.contentLayer.contentsScale = [[UIScreen mainScreen] scale];
//        [self.layer addSublayer:self.contentLayer];
//    }
//    
//    return self;
//}
//
- (void)drawRect:(CGRect)rect {
    
    
    self.layer.cornerRadius = 64.0f;
    self.layer.masksToBounds = YES;
    [self.layer setBorderColor:[UIColor redColor].CGColor];
    [self.layer setBorderWidth:1.0f];
    
//    [self.layer setShadowColor:[UIColor blackColor].CGColor];
//    [self.layer setShadowOpacity:0.8];
//    [self.layer setShadowRadius:3.0];
//    [self.layer setShadowOffset:CGSizeMake(2.0, 2.0)];


    // Drawing code
    [[UIColor redColor] set];
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(currentContext,1.0f);
    CGContextMoveToPoint(currentContext,64.0f - CROSS_SIZE, 64.0f);
    CGContextAddLineToPoint(currentContext,64.0f + CROSS_SIZE, 64.0f);

    CGContextMoveToPoint(currentContext,64.0f, 64.0f - CROSS_SIZE);
    CGContextAddLineToPoint(currentContext,64.0f, 64.0f + CROSS_SIZE);
    CGContextStrokePath(currentContext);

    /* Step5 从起始点绘制线条到终点 */
    
    /* Step6 提交绘制 */

}

- (void)drawRedCross
{
    UIView *redCrossView = [[UIView alloc] initWithFrame:CGRectMake((VIEW_SIZE - CROSS_SIZE) / 2,
                                                                    (VIEW_SIZE - CROSS_SIZE) / 2,
                                                                    CROSS_SIZE,
                                                                    CROSS_SIZE)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0, CROSS_SIZE / 2)];
    [path addLineToPoint:CGPointMake(CROSS_SIZE, CROSS_SIZE / 2)];
    
    [path moveToPoint:CGPointMake(CROSS_SIZE / 2, 0)];
    [path addLineToPoint:CGPointMake(CROSS_SIZE / 2, CROSS_SIZE)];
    
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    
    [redCrossView.layer addSublayer:shapeLayer];
    
    [self addSubview:redCrossView];
    
    
}

- (void)moveCenterPointTo:(CGPoint)centerPoint
{
    NSLog(@"Center Point X = %f, Y = %f", centerPoint.x, centerPoint.y);
    
    CGRect cropRect = CGRectMake((centerPoint.x - VIEW_SIZE / 2 ) * _scale ,(centerPoint.y - VIEW_SIZE / 2) * _scale , VIEW_SIZE  * _scale, VIEW_SIZE  * _scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([_snapshotImage CGImage],cropRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    _imageView.image = image;
}

- (void)setPointToMagnify:(CGPoint)pointToMagnify
{
    _pointToMagnify = pointToMagnify;
    
    CGPoint center = CGPointMake(pointToMagnify.x, self.center.y);
    if (pointToMagnify.y > CGRectGetHeight(self.bounds) * 0.5) {
        center.y = pointToMagnify.y -  CGRectGetHeight(self.bounds) / 2;
    }
    
    self.center = center;
    [self.contentLayer setNeedsDisplay];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 
 }
 */

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextTranslateCTM(ctx, self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    CGContextScaleCTM(ctx, 1.2, 1.2);
    CGContextTranslateCTM(ctx, -1 * self.pointToMagnify.x, -1 * self.pointToMagnify.y);
    [self.viewToMagnify.layer renderInContext:ctx];
}

- (void)setSnapshotImage:(UIImage *)snapshotImage
{
    _snapshotImage = snapshotImage;
    _imageView.image = snapshotImage;
//    _imageView.alpha = 0;
}


@end
