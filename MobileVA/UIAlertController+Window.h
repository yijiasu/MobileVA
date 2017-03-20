//
//  UIAlertController+Window.h
//  AliSight
//
//  Created by Su Yijia on 9/4/16.
//
//

#include <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIAlertController (Window)

- (void)show;
- (void)show:(BOOL)animated;

@end

@interface UIAlertController (Private)

@property (nonatomic, strong) UIWindow *alertWindow;

@end

