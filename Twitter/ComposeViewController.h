//
//  ComposeViewController.h
//  Twitter
//
//  Created by Charles Dong on 2/22/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class ComposeViewController;

@protocol ComposeViewControllerDelegate <NSObject>

- (void)ComposeViewController:(ComposeViewController *)composeViewController tweeted:(Tweet *)tweet;

@end

@interface ComposeViewController : UIViewController

@property (strong, nonatomic) Tweet *replyToTweet;
@property (nonatomic, weak) id<ComposeViewControllerDelegate> delegate;

@end
