//
//  UIWebView+ScreenShot.m
//  FaceDetection
//
//  Created by Su Yijia on 3/10/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "UIWebView+ScreenShot.h"

@implementation UIWebView (Screenshot)

- (UIImage *)screenshot {
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(self.scrollView.contentSize, self.scrollView.opaque, 0.0);
    {
        CGPoint savedContentOffset = self.scrollView.contentOffset;
        CGRect savedFrame = self.scrollView.frame;
        
        self.scrollView.contentOffset = CGPointZero;
        self.scrollView.frame = CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
        [self.scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        img = UIGraphicsGetImageFromCurrentImageContext();
        
        self.scrollView.contentOffset = savedContentOffset;
        self.scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    return img;
}

@end


