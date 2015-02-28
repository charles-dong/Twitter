//
//  ContainerViewController.m
//  Twitter
//
//  Created by Charles Dong on 2/28/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "ContainerViewController.h"
#import "MenuViewController.h"

@interface ContainerViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftContentViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightContentViewConstraint;

@property (strong, nonatomic) UINavigationController *menuNavigationViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) UIViewController *contentViewController;

@property (assign, nonatomic) BOOL menuIsVisible;

- (IBAction)onPanContentView:(id)sender;

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // setup menu view controller and push
    self.menuViewController = [[MenuViewController alloc] initWithContainerViewController:self];
    //self.menuNavigationViewController = [[UINavigationController alloc] initWithRootViewController:self.menuViewController];
    [self displayContentController:self.menuViewController];
    
}


#pragma mark - Navigation between child views


- (void)toggleMenu {
    CGFloat newLeadingConstraint;
    CGFloat newScale;
    
    if (self.menuIsVisible) {
        // close menu, show content view controller
        newLeadingConstraint = 0;
        newScale = 1;
        self.menuIsVisible = NO;
    } else {
        // open menu
        newLeadingConstraint = self.view.frame.size.width - 200;
        newScale = 0.8;
        self.menuIsVisible = YES;
    }
    
    // move left/right constraints appropriately
    self.leftContentViewConstraint.constant = newLeadingConstraint;
    self.rightContentViewConstraint.constant = 0 - newLeadingConstraint;
    
    // animate scale change
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.transform = CGAffineTransformMakeScale(newScale, newScale);
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        // completion block
    }];

    
}

- (void)displayContentController:(UIViewController *) contentViewController {
    
    // if there's a child content view controller, hide it
    if (self.contentViewController != nil) {
        [self hideChildController:self.contentViewController];
    }
    
    self.contentViewController = contentViewController;
    // toggle menu from showing to not
    self.menuIsVisible = YES;
    [self toggleMenu];
    
    // display new child content view controller
    [self addChildViewController:self.contentViewController]; // 1
    self.contentViewController.view.frame = self.contentView.frame; // 2
    self.contentViewController.view.center = CGPointMake(self.contentView.center.x, self.contentView.center.y);
    [self.contentView addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self]; //3
}

- (void) hideChildController:(UIViewController*) child
{
    [child willMoveToParentViewController:nil];  // 1
    [child.view removeFromSuperview];            // 2
    [child removeFromParentViewController];      // 3
}


- (IBAction)onPanContentView:(id)sender {
    // TODO
}

@end
