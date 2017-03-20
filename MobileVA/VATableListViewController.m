//
//  VATableListViewController.m
//  MobileVA
//
//  Created by Su Yijia on 3/18/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VATableListViewController.h"

@interface VATableListViewController ()

@end

@implementation VATableListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.type = VAViewControllerTypeTable;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark VAViewController View Size Control

- (void)becomeThumbnailView
{
    NSLog(@"%@ becomeThumbnailView", self);
}

- (void)becomeMainView
{
    NSLog(@"%@ becomeMainView", self);
    
}


@end
