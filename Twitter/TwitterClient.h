//
//  TwitterClient.h
//  Twitter
//
//  Created by Charles Dong on 2/21/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

@property (strong, nonatomic) UIColor *twitterColor;

+ (TwitterClient *)sharedInstance;

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion;
- (void)openURL:(NSURL *)url;
- (void)homeTimelineWithParams:(NSDictionary *)params completionBlock:(void (^)(NSArray *tweets, NSError *error))completion;

- (void)tweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)retweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)deleteTweet:(NSString *)tweetID completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)favorite:(NSString *)tweetID completion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)unfavorite:(NSString *)tweetID completion:(void (^)(Tweet *tweet, NSError *error))completion;


- (UIColor *)twitterColor;
- (UIColor *)twitterSecondaryColor;
- (UIColor *)selectedColor;
- (UIColor *)unselectedColor;

@end
