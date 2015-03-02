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
    
    // tap gesture
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickOnProfilePicture:)];
    [profileTapGestureRecognizer setNumberOfTouchesRequired:1];
    [profileTapGestureRecognizer setNumberOfTapsRequired:1];
    [self.profilePicture addGestureRecognizer:profileTapGestureRecognizer];
    self.userInteractionEnabled = YES;
    self.profilePicture.userInteractionEnabled = YES;

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
    self.favoriteCount.text = [NSString stringWithFormat:@"%ld", tweet.favoriteCount];
    self.retweetCount.text = [NSString stringWithFormat:@"%ld", tweetToDisplay.retweetCount];
    
    // if retweeted, updated retweetButton image
    if (tweet.retweeted) {
        self.retweetButton.selected = YES;
        self.retweetCount.textColor = [[TwitterClient sharedInstance] selectedColor];
    } else {
        self.retweetButton.selected = NO;
        self.retweetCount.textColor = [[TwitterClient sharedInstance] unselectedColor];
    }
    
    // if favorited, update favoriteButton image
    if (tweet.favorited) {
        self.favoriteButton.selected = YES;
        self.favoriteCount.textColor = [[TwitterClient sharedInstance] selectedColor];
    } else {
        self.favoriteButton.selected = NO;
        self.favoriteCount.textColor = [[TwitterClient sharedInstance] unselectedColor];
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

#pragma mark - User Actions

- (IBAction)didClickReply:(id)sender {
    
    if (self.delegate) {
        [self.delegate tweetCell:self didClickReply:self.tweet];
    }
}

- (IBAction)didClickRetweet:(id)sender {
    if (self.tweet.retweeted) {
        self.tweet.retweeted = false;
        self.tweet.retweet.retweetCount -= 1;
    } else {
        self.tweet.retweeted = true;
        self.tweet.retweet.retweetCount += 1;
    }
    
    // reload cell
    [self setTweet:self.tweet];
    if (self.delegate){
        [self.delegate tweetCell:self didClickRetweet:self.tweet];
    }
}

- (IBAction)didClickFavorite:(id)sender {
    if (self.tweet.favorited) {
        self.tweet.favorited = false;
        self.tweet.favoriteCount -= 1;
    } else {
        self.tweet.favorited = true;
        self.tweet.favoriteCount += 1;
    }
    
    [self setTweet:self.tweet];
    if (self.delegate){
        [self.delegate tweetCell:self didClickFavorite:self.tweet];
    }
}

- (void)didClickOnProfilePicture:(id)sender {
    
    User *user;
    if (self.tweet.retweet != nil) {
        user = self.tweet.retweet.user;
    } else { // not a retweet
        user = self.tweet.user;
    }

    [self.delegate tweetCell:self didTapProfilePicOfUser:user];
}


@end
