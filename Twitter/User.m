//
//  User.m
//  Twitter
//
//  Created by Charles Dong on 2/21/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@interface User()

@property (nonatomic, strong) NSDictionary *dictionary; // helping us cheat to persist currentUser

@end

@implementation User

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.dictionary = dictionary;
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profileImageURL = dictionary[@"profile_image_url"];
        self.tagline = dictionary[@"description"];
        
        NSString *createdAtString = dictionary[@"created_at"];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        formater.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.createdAt = [formater dateFromString:createdAtString];
        self.favoritesCount = [dictionary[@"favourites_count"] integerValue];
        self.followersCount = [dictionary[@"followers_count"] integerValue];
        if ([dictionary[@"following"] integerValue] == 1) {
            self.following = YES;
        } else {
            self.following = NO;
        }
        self.followingCount = [dictionary[@"friends_count"] integerValue];
        self.userID = dictionary[@"id_str"];
        self.location = dictionary[@"location"];
        self.profileBannerImageURL = dictionary[@"profile_banner_url"];
    }
    
    return self;
}

+ (void)logout {
    [User setCurrentUser:nil]; // clear out NSUserDefaults
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken]; // clear current session's access token
    
    // tell anyone who might be interested that the user is logging out
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}


#pragma mark - setter / getter - faking class property

static User *_currentUser = nil;
NSString * const kCurrentUserKey = @"kCurrentUserKey";

+ (User *)currentUser {
    // NSUserDefaults good place to store sessions, etc. that would be stored in cookie
    // Normally you'd have to implement coding protocol to write this type of object to disk, but we're going to cheat and take advantage of the fact that it's easily de/serializable as JSON
    if (_currentUser == nil) { //either logged out or coming back from cold start
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey]; // check if there's a current user
        if (data != nil) {
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    
    return _currentUser;
}


+ (void)setCurrentUser:(User *)currentUser {
    _currentUser = currentUser;
    
    if (_currentUser != nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:NULL]; // NSUserDefaults can only contain things compatible with plist standard (NULL is how you represent 'nil' in dictionary)
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
    } else {
        // clear previous user
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize]; // tell it to write right now
    
}


@end
