//
//  VAMatrixCellView.h
//  MobileVA
//
//  Created by Su Yijia on 3/19/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VAMatrixCellView : UIView

- (instancetype)initWithFrame:(CGRect)frame level:(NSInteger)level;
- (void)pushNewValue:(NSInteger)value;

@property (nonatomic, strong) UIColor *baseColor;

@end
