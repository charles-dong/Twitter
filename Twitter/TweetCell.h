//
//  TweetCell.h
//  Twitter
//
//  Created by Charles Dong on 2/22/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "User.h"
@class TweetCell;

@protocol TweetCellDelegate <NSObject>

-(void)tweetCell:(TweetCell *)tweetCell didClickReply: (Tweet *) tweet;
-(void)tweetCell:(TweetCell *)tweetCell didClickRetweet: (Tweet *) tweet;
-(void)tweetCell:(TweetCell *)tweetCell didClickFavorite: (Tweet *) tweet;
-(void)tweetCell:(TweetCell *)tweetCell didTapProfilePicOfUser:(User *)user;


@end



@interface TweetCell : UITableViewCell

@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, weak) id<TweetCellDelegate> delegate;

@end
