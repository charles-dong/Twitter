//
//  MenuViewController.m
//  Twitter
//
//  Created by Charles Dong on 2/28/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "MenuViewController.h"
#import "HomeViewController.h"
#import "ComposeViewController.h"

@interface MenuViewController ()

@property (weak, nonatomic) ContainerViewController *containerViewController;

@property (strong, nonatomic) HomeViewController *homeViewController;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.homeViewController = [[HomeViewController alloc] init];
    [self.containerViewController displayContentController:[[ComposeViewController alloc]init]];
    
    NSLog(@"End of MenuViewController ViewDidLoad");
}



#pragma mark - Utils

- (MenuViewController *)initWithContainerViewController:(ContainerViewController *)containerViewController {
    self = [super init];
    if (self) {
        self.containerViewController = containerViewController;
    }
    return self;
}


@end
