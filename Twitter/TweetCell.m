//
//  TweetCell.m
//  Twitter
//
//  Created by Charles Dong on 2/22/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "TweetCell.h"
#import "NSDate+DateTools.h"
#import "TwitterClient.h"

@interface TweetCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;
@property (weak, nonatomic) IBOutlet UILabel *retweetCount;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCount;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;


// may be hidden
@property (weak, nonatomic) IBOutlet UILabel *retweetedStatus;
@property (weak, nonatomic) IBOutlet UIImageView *retweetedStatusIcon;
@property (weak, nonatomic) IBOutlet UIImageView *tweetPhoto;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *profilePictureDistanceFromTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tweetPhotoHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tweetPhotoDistanceFromTextConstraint;



@end

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
    
    self.tweetText.preferredMaxLayoutWidth = self.tweetText.frame.size.width; // to fix text-wrapping bug
    
    // circular profile picture
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
    self.profilePicture.clipsToBounds = YES;
    
    // rounded tweet photo
    self.tweetPhoto.layer.cornerRadius = 3;
    self.tweetPhoto.clipsToBounds = YES;
    
    // set button images for different states
    [self.replyButton setImage:[UIImage imageNamed:@"reply_light"] forState:UIControlStateNormal];
    [self.retweetButton setImage:[UIImage imageNamed:@"retweet_light"] forState:UIControlStateNormal];
    [self.retweetButton setImage:[UIImage imageNamed:@"retweet_selected"] forState:UIControlStateSelected];
    [self.favoriteButton setImage:[UIImage imageNamed:@"fav_light"] forState:UIControlStateNormal];
    [self.favoriteButton setImage:[UIImage imageNamed:@"fav_selected"] forState:UIControlStateSelected];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - TweetCell Configuration

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    Tweet *tweetToDisplay = tweet;
    
    // if this is a retweet, change the tweet to display
    if (self.tweet.retweet != nil) {
        tweetToDisplay = self.tweet.retweet;
        
        // show retweeted status at top of cell
        self.retweetedStatusIcon.hidden = NO;
        self.retweetedStatus.hidden = NO;
        self.retweetedStatus.text = [NSString stringWithFormat:@"%@ retweeted", self.tweet.user.name];
        
        // update constraints
        self.profilePictureDistanceFromTopLayoutConstraint.constant = 26.0;
        
    } else { // not a retweet

        // hide retweeted status
        self.retweetedStatusIcon.hidden = YES;
        self.retweetedStatus.hidden = YES;
        
        // update constraints
        self.profilePictureDistanceFromTopLayoutConstraint.constant = 8.0;
    }
    
    // set tweet information
    [self.profilePicture setImageWithURL:[NSURL URLWithString:tweetToDisplay.user.profileImageURL] placeholderImage:[UIImage imageNamed:@"twitter_profile_pic_48x48"]];
    self.username.text = tweetToDisplay.user.name;
    self.screenName.text = [NSString stringWithFormat:@"@%@", tweetToDisplay.user.screenName];
    self.timeStamp.text = tweetToDisplay.createdAt.shortTimeAgoSinceNow;
    self.tweetText.text = tweetToDisplay.text;
    [self.tweetText sizeToFit];
    self.favoriteCount.text = [NSString stringWithFormat:@"%ld", tweetToDisplay.favoriteCount];
    self.retweetCount.text = [NSString stringWithFormat:@"%ld", tweetToDisplay.retweetCount];
    
    // if retweeted, updated retweetButton image
    if (tweetToDisplay.retweeted) {
        self.retweetButton.selected = YES;
        self.retweetCount.textColor = [[TwitterClient sharedInstance] selectedColor];
    }
    
    // if favorited, update favoriteButton image
    if (tweetToDisplay.favorited) {
        self.favoriteButton.selected = YES;
        self.favoriteCount.textColor = [[TwitterClient sharedInstance] selectedColor];
    }
    
    // if there's a photo, load it and update constraints accordingly
    if (tweetToDisplay.tweetPhotoURL != nil) {
        self.tweetPhoto.backgroundColor =  [[TwitterClient sharedInstance] twitterColor];
        self.tweetPhotoHeightConstraint.constant = 150.0; // Lowered the priority of this constraint to 999 from 1000 to avoid constraint confliction involving UIView-Encapsulated-Layout-Height.
        self.tweetPhotoDistanceFromTextConstraint.constant = 6.0;
        [self.tweetPhoto setImageWithURL:[NSURL URLWithString:tweetToDisplay.tweetPhotoURL] placeholderImage:[UIImage imageNamed:@"TwitterLogo_Big"]];
        
    } else {
        [self.tweetPhoto setImage:nil];
        self.tweetPhotoHeightConstraint.constant = 0.0;
        self.tweetPhotoDistanceFromTextConstraint.constant = 0.0;
        //NSLog(@"Set distance constraint to %f for %@", self.tweetPhotoDistanceFromTextConstraint.constant, tweetToDisplay.user.name);
    }
}

#pragma mark - Utils

@end
