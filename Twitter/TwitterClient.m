//
//  TwitterClient.m
//  Twitter
//
//  Created by Charles Dong on 2/21/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "TwitterClient.h"

NSString * const kTwitterConsumerKey = @"C4sneppAfTEG5PLLH1sjoJfTn";
NSString * const kTwitterConsumerSecret = @"ezXOjqEf7TAwU49nhZ8xn9sm2PmxhYN5voF9V3oH3XRhzMBeC8";
NSString * const kTwitterBaseURL = @"https://api.twitter.com";
NSString *const kTwitterAPIVerifyCredentials = @"1.1/account/verify_credentials.json";
NSString *const kTwitterAPIHomeTimeLine = @"1.1/statuses/home_timeline.json";
NSString *const kTwitterAPIRetweet = @"1.1/statuses/retweet/%@.json";
NSString *const kTwitterAPIFavorite = @"1.1/favorites/create.json";
NSString *const kTwitterAPIUnFavorite = @"1.1/favorites/destroy.json";
NSString *const kTwitterAPIDelete = @"1.1/statuses/destroy/%@.json";
NSString *const kTwitterAPIUpdate = @"1.1/statuses/update.json";
NSString *const kTwitterAPIUserTimeline = @"1.1/statuses/user_timeline.json";

@interface TwitterClient ()

@property (nonatomic, strong) void (^loginCompletionBlock)(User *user, NSError *error);

@end

@implementation TwitterClient


// singleton Twitter client to communicate with API
+ (TwitterClient *)sharedInstance {
    static TwitterClient *instance = nil; // this =nil will only be set once b/c static
    
    // make singleton threadsafe
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ // only run once; blocks other threads; similar to @synchronize but more performant
        if (instance == nil) {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseURL] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
        }
    });
    
    return instance;
}

- (void)loginWithCompletion:(void (^)(User *user, NSError *error))completion {
    
    // save completion block
    self.loginCompletionBlock = completion;
    
    // clear out token
    [self.requestSerializer removeAccessToken];
    
    // fetch request token
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"twitter://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSLog(@"Got request token!");
        
        // get authorization URL and pass oauth token we just got
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        
        // have singleton global application object open authURL
        [[UIApplication sharedApplication] openURL:authURL];
        
    } failure:^(NSError *error) {
        NSLog(@"Failed to get request token :(");
        self.loginCompletionBlock(nil, error);
    }];

}

- (void)openURL:(NSURL *)url {
    
    // get access token
    [[TwitterClient sharedInstance] fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        
        NSLog(@"Got the access token!");
        [self.requestSerializer saveAccessToken:accessToken];
        
        // get current user
        [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // get and persist user
            User *user = [[User alloc] initWithDictionary:responseObject];
            [User setCurrentUser:user];
            
            // succesfully got user - run login completion block
            self.loginCompletionBlock(user, nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to get current user :(");
        }];
        
        
    } failure:^(NSError *error) {
        
        NSLog(@"Failed to get the access token :(");
        
    }];
}

- (void)homeTimelineWithParams:(NSDictionary *)params completionBlock:(void (^)(NSArray *tweets, NSError *error))completion{
    
    // get 100 if no params specified
    NSMutableDictionary *finalParams = [params mutableCopy];
    if (finalParams == nil) {
        finalParams = [[NSMutableDictionary alloc] init];
        [finalParams setObject:@(100) forKey:@"count"];
    }
    
    // get tweets
    [self GET:kTwitterAPIHomeTimeLine parameters:finalParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // TODO: check to make sure responseObject is in fact an NSArray
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to get tweets :(");
        completion(nil, error);
    }];
}

- (void)userTimelineWithParams:(NSDictionary *)params forUser:(User *)user completion:(void (^)(NSArray *tweets, NSError *error))completion {
    
    NSMutableDictionary *finalParams = [params mutableCopy];
    if (finalParams == nil) {
        finalParams = [[NSMutableDictionary alloc] init];
        [finalParams setObject:@(100) forKey:@"count"];
        [finalParams setObject:@([user.userID integerValue]) forKey:@"user_id"];
    }
    
    [self GET:@"1.1/statuses/user_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed to get user timeline tweets with error %@", error);
        completion(nil, error);
    }];
}

#pragma mark - API Actions

- (void)tweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion {
    [self POST:kTwitterAPIUpdate parameters:[tweet convertToAPIDictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion([[Tweet alloc] initWithDictionary:responseObject], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        completion(nil, error);
    }];
}

- (void)retweet:(Tweet *)tweet completion:(void (^)(Tweet *tweet, NSError *error))completion {
    [self POST:[NSString stringWithFormat:kTwitterAPIRetweet, tweet.tweetID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tweet.myRetweet = [[Tweet alloc] initWithDictionary:responseObject];
        completion(tweet.myRetweet, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        completion(nil, error);
    }];
}

- (void)deleteTweet:(NSString *)tweetID completion:(void (^)(Tweet *tweet, NSError *error))completion {
    if (tweetID==nil) {
        //NSError *error = [[NSError alloc] init];
        // TODO: Write error
        completion(nil, nil);
        return;
    }
    [self POST:[NSString stringWithFormat:kTwitterAPIDelete, tweetID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion([[Tweet alloc] initWithDictionary:responseObject], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        completion(nil, error);
    }];

}
- (void)favorite:(NSString *)tweetID completion:(void (^)(Tweet *tweet, NSError *error))completion {
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:tweetID, @"id", nil];
    [self POST:kTwitterAPIFavorite parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion([[Tweet alloc] initWithDictionary:responseObject], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        completion(nil, error);
    }];

}
- (void)unfavorite:(NSString *)tweetID completion:(void (^)(Tweet *tweet, NSError *error))completion {
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:tweetID, @"id", nil];
    [self POST:kTwitterAPIUnFavorite parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion([[Tweet alloc] initWithDictionary:responseObject], nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        completion(nil, error);
    }];
}



#pragma mark - Colors

- (UIColor *)twitterColor {
    return [UIColor colorWithRed:85.0f/255.0f green:172.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
}

- (UIColor *)twitterSecondaryColor {
    return [UIColor  colorWithRed:245.0f/255.0f green:248.0f/255.0f blue:250.0f/255.0f alpha:1.0f];
}

- (UIColor *)selectedColor {
    return [UIColor colorWithRed:253.0f/255.0f green:160.0f/255.0f blue:65.0f/255.0f alpha:1.0f];
}

- (UIColor *)unselectedColor {
    return [UIColor lightGrayColor];
}

@end
