//
//  DetailViewController.h
//  Twitter
//
//  Created by Charles Dong on 2/22/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class DetailViewController;

@protocol DetailViewControllerDelegate <NSObject>

- (void)DetailViewController:(DetailViewController *)detailVC didClickFavorite:(Tweet *)tweet;
- (void)DetailViewController:(DetailViewController *)detailVC didClickReply:(Tweet *)tweet;
- (void)DetailViewController:(DetailViewController *)detailVC didClickRetweet:(Tweet *)tweet;

@end


@interface DetailViewController : UIViewController

@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id<DetailViewControllerDelegate> delegate;

@end
