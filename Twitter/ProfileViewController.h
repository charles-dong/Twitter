//
//  ProfileViewController.h
//  Twitter
//
//  Created by Charles Dong on 3/1/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContainerViewController.h"
#import "User.h"

@interface ProfileViewController : UIViewController

@property (nonatomic, strong) User *user;

- (ProfileViewController *)initWithContainerViewController:(ContainerViewController *)containerViewController;

@end
