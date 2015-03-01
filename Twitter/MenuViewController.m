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
#import "ProfileViewController.h"
#import "User.h"
#import "MenuCell.h"
#import "TwitterClient.h"

typedef NS_ENUM(NSInteger, MenuIndex) {
    MenuIndexProfile    = 0,
    MenuIndexTimeline = 1,
    MenuIndexLogout = 2,
    MenuIndexMax = 3
};

@interface MenuViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) ContainerViewController *containerViewController;
@property (strong, nonatomic) UINavigationController *nvc;

@property (strong, nonatomic) HomeViewController *homeViewController;
@property (strong, nonatomic) ProfileViewController *profileViewController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.backgroundColor = [[TwitterClient sharedInstance] twitterColor];
    
    self.homeViewController = [[HomeViewController alloc] initWithContainerViewController:self.containerViewController];
    self.profileViewController = [[ProfileViewController alloc] initWithContainerViewController:self.containerViewController];
    [self.profileViewController setUser:[User currentUser]];
    
    // start with home timeline
    self.nvc = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    [self.containerViewController displayContentController:self.nvc];
    
    // table view
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MenuCell" bundle:nil] forCellReuseIdentifier:@"MenuCell"];
    self.tableView.rowHeight = 80;
}

#pragma mark - Table Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MenuIndexMax + 1; // + 1 for empty cell
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    cell.backgroundColor = [[TwitterClient sharedInstance] twitterColor];
    
    switch (indexPath.row - 1) {
        case -1:
            cell.menuLabel.text = @"";
            break;
        case MenuIndexProfile:
            cell.menuLabel.text = @"Me";
            break;
        case MenuIndexTimeline:
            cell.menuLabel.text = @"Timelines";
            break;
        case MenuIndexLogout:
            cell.menuLabel.text = @"Logout";
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:[self.nvc viewControllers]];
    
    switch (indexPath.row - 1) {
        case MenuIndexProfile:
            [viewControllers replaceObjectAtIndex:0 withObject:self.profileViewController];
            [self.nvc setViewControllers:viewControllers];
            [self.nvc popToRootViewControllerAnimated:YES];
            [self.containerViewController toggleMenu];
            break;
        case MenuIndexTimeline:
            [viewControllers replaceObjectAtIndex:0 withObject:self.homeViewController];
            [self.nvc setViewControllers:viewControllers];
            [self.nvc popToRootViewControllerAnimated:YES];
            [self.containerViewController toggleMenu];
            break;
        case MenuIndexLogout:
            [User logout];
            break;
        default:
            break;
    }
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
