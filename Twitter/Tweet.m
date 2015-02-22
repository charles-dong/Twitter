//
//  Tweet.m
//  Twitter
//
//  Created by Charles Dong on 2/21/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.text = dictionary[@"text"];
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        NSString *createdAtString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.createdAt = [formatter dateFromString:createdAtString];
        self.favoriteCount = [dictionary[@"favorite_count"] integerValue];
        self.favorited = [dictionary[@"favorited"] boolValue];
        self.tweetID = dictionary[@"id_str"];
        
        // retweets
        self.retweetCount = [dictionary[@"retweet_count"] integerValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        NSDictionary *retweetDictionary = dictionary[@"retweeted_status"];
        if (retweetDictionary != nil) {
            self.retweet = [[Tweet alloc] initWithDictionary:retweetDictionary];
            self.favoriteCount = self.retweet.favoriteCount;
        } else {
            self.retweet = nil;
        }
        
        // photos
        NSDictionary *entities = [dictionary valueForKeyPath:@"entities"];
        if (entities) {
            NSArray *media = [dictionary valueForKeyPath:@"entities.media"];
            if (media && media.count > 0) {
                self.tweetPhotoURL = [media[0] valueForKeyPath:@"media_url"];
            }
        }
    }
    
    return self;
}

+ (NSArray *)tweetsWithArray:(NSArray *)array{
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
    }
    
    return tweets;
}

@end
