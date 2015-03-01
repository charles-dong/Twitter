//
//  ProfileCell.m
//  Twitter
//
//  Created by Charles Dong on 3/1/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "ProfileCell.h"

@interface ProfileCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *followerCount;


@end

@implementation ProfileCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setUser:(User *)user {
    _user = user;
    
    self.nameLabel.text = self.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName];
    self.followerCount.text = [NSString stringWithFormat:@"%ld", self.user.followersCount];
    self.followingCount.text = [NSString stringWithFormat:@"%ld", self.user.followingCount];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
