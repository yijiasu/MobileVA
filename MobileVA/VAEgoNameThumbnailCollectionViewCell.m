//
//  VAEgoNameThumbnailCollectionViewCell.m
//  MobileVA
//
//  Created by Su Yijia on 3/21/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import "VAEgoNameThumbnailCollectionViewCell.h"

@implementation VAEgoNameThumbnailCollectionViewCell

- (void)configureCellWithEgoPerson:(VAEgoPerson *)egoPerson index:(NSInteger)index
{
    if (egoPerson) {
        _nameLabel.text = [NSString stringWithFormat:@"%@", egoPerson.name];
        _avatarBackgroundView.backgroundColor = [[VAUtil util] colorSchemaForMatrixIndex:index];
        _avatarLabel.text = [[VAUtil util] thumbnailIconTextForEgoPerson:egoPerson];
    }
}


@end
