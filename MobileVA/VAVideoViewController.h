//
//  VAVideoViewController.h
//  MobileVA
//
//  Created by Su Yijia on 3/16/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAViewController.h"
#import "VAEgoPerson.h"
#import "VADataModel.h"

@class VAVideoViewController;
@interface VAVideoViewController : VAViewController <VAViewControllerProtocol>

- (void)loadEgoPerson:(VAEgoPerson *)egoPerson;

@end
