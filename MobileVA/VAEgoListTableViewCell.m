//
//  VAEgoListTableViewCell.m
//  MobileVA
//
//  Created by Su Yijia on 3/20/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAEgoListTableViewCell.h"

@implementation VAEgoListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithEgoPerson:(VAEgoPerson *)egoPerson
{
    if (egoPerson) {
        _nameLabel.text = [NSString stringWithFormat:@"%@", egoPerson.name];
        _startEndYearLabel.text = [NSString stringWithFormat:@"Start/End Year: %ld-%ld", egoPerson.startYear, egoPerson.endYear];
        _degreeLabel.text = [NSString stringWithFormat:@"Deg: %ld", egoPerson.neighborLen];
        _pubLabel.text = [NSString stringWithFormat:@"Pub: %ld", egoPerson.publication];
    }
}

@end
