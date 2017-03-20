//
//  VAViewController.m
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAViewController.h"
@interface VAViewController ()


@end

@implementation VAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isMinimized = YES;
    _dataModel = [VAUtil util].model;
    if (_dataModel) {
        [_dataModel addObserver:self
                     forKeyPath:@"activeViewType"
                        options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                        context:NULL];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)setIsMinimized:(BOOL)isMinimized
{
    if (_isMinimized == isMinimized) {
        return;
    }
    
    _isMinimized = isMinimized;
    if (isMinimized) {
        [self becomeThumbnailView];
    }
    else
    {
        [self becomeMainView];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"changed %@", self);
    if ([keyPath isEqualToString:@"activeViewType"]) {
        if ([[change valueForKey:NSKeyValueChangeNewKey] integerValue] == self.type) {
            // I am becoming the Active
            [self setIsMinimized:NO];
        }
        else
        {
            [self setIsMinimized:YES];
        }
//
//        if ([[change valueForKey:NSKeyValueChangeOldKey] integerValue] == self.type) {
//            <#statements#>
//        }
        
//        if ([[change valueForKey:NSKeyValueChangeOldKey] integerValue] == self.type) {
//            // I am becoming the Inactive
//            [self setIsMinimized:YES];
//        }
    }
}

@end
