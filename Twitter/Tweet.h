//
//  Tweet.h
//  Twitter
//
//  Created by Charles Dong on 2/21/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *tweetID;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) User *user;

@property (nonatomic, assign) NSInteger favoriteCount;
@property (nonatomic, assign) BOOL favorited;
@property (nonatomic, assign) NSInteger retweetCount;
@property (nonatomic, assign) BOOL retweeted;
@property (nonatomic, strong) Tweet *retweet;
@property (nonatomic, strong) NSString *replyID;
@property (nonatomic, strong) Tweet *myRetweet; // if I've retweeted it, hold reference to my retweet

@property (nonatomic, strong) NSString *tweetPhotoURL;

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (NSArray *)tweetsWithArray:(NSArray *)array;
+ (Tweet *)createNewTweetWithText:(NSString *)text andReplyID: (Tweet *)replyToTweet;
- (NSDictionary *)convertToAPIDictionary;

@end
