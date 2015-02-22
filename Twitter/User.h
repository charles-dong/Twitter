//
//  User.h
//  Twitter
//
//  Created by Charles Dong on 2/21/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const UserDidLoginNotification; //extern = variable exists but is allocated elsewhere
extern NSString * const UserDidLogoutNotification;

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *profileImageURL;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, assign) NSInteger favoritesCount;
@property (nonatomic, assign) NSInteger followersCount;
@property (nonatomic, assign) BOOL following;
@property (nonatomic, assign) NSInteger followingCount;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *profileBannerImageURL;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (void)logout;

// setter / getter - faking class property
+ (User *)currentUser;
+ (void)setCurrentUser:(User *)currentUser;

@end
