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
    
    self.homeViewController = [[HomeViewController alloc] initWithContainerViewController:self.containerViewController];
    self.profileViewController = [[ProfileViewController alloc] initWithContainerViewController:self.containerViewController];
    [self.profileViewController setUser:[User currentUser]];
    
    // start with home timeline
    self.nvc = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    [self.containerViewController displayContentController:self.nvc];
    
    // table view
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MenuCell" bundle:nil] forCellReuseIdentifier:@"MenuCell"];
    self.tableView.rowHeight = 80;
}

#pragma mark - Table Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MenuIndexMax;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    
    switch (indexPath.row) {
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
    
    
    switch (indexPath.row) {
        case MenuIndexProfile:
            [self.containerViewController displayContentController:self.profileViewController];
            break;
        case MenuIndexTimeline:
            [self.containerViewController displayContentController:self.homeViewController];
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
