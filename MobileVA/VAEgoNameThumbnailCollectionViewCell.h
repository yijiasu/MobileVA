//
//  VAEgoNameThumbnailCollectionViewCell.h
//  MobileVA
//
//  Created by Su Yijia on 3/21/17.
//  Copyright © 2017 Su Yijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VAEgoNameThumbnailCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *avatarBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *avatarLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (void)configureCellWithEgoPerson:(VAEgoPerson *)egoPerson index:(NSInteger)index;

@end
