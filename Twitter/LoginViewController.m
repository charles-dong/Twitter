//
//  LoginViewController.m
//  Twitter
//
//  Created by Charles Dong on 2/21/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"
#import "HomeViewController.h"

@interface LoginViewController ()
- (IBAction)onLogin:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIColor *twitterColor = [[TwitterClient sharedInstance] twitterColor];
    self.view.backgroundColor = twitterColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Login

- (IBAction)onLogin:(id)sender {
    
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (user != nil) {
            // modally present tweets view
            NSLog(@"Welcome to %@", user.name);
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:[[HomeViewController alloc] init]];
            [self presentViewController:nvc animated:YES completion:nil];
        } else {
            // present error
        }
    }];
}

@end
