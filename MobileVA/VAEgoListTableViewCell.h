//
//  VAEgoListTableViewCell.h
//  MobileVA
//
//  Created by Su Yijia on 3/20/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VAEgoListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *startEndYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *degreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pubLabel;
- (void)configureCellWithEgoPerson:(VAEgoPerson *)egoPerson;
@end
