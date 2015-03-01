//
//  ProfileViewController.m
//  Twitter
//
//  Created by Charles Dong on 3/1/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "ProfileViewController.h"
#import "TwitterClient.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeViewController.h"


@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *coverPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, assign) BOOL isCurrentlyLoading;
@property (nonatomic, weak) ContainerViewController *containerViewController;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIColor *twitterColor = [[TwitterClient sharedInstance] twitterColor];
    UIColor *twitterSecondaryColor = [[TwitterClient sharedInstance] twitterSecondaryColor];
    // navigation bar
    [self setupNavigationBarWithBarTintColor:twitterColor andTintColor:twitterSecondaryColor];
    
    // table view setup
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    [self setupTableView];
    
    // profile picture
    [self.profilePic setImageWithURL:[NSURL URLWithString:self.user.profileImageURL] placeholderImage:[UIImage imageNamed:@"twitter_profile_pic_48x48"]];
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2;
    self.profilePic.clipsToBounds = YES;
    
    
}

#pragma mark - User Actions

- (void)onMenuButton:(id)sender {
    [self.containerViewController toggleMenu];
}

- (void)onCompose:(id)sender {
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    cvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - Table Methods



#pragma mark - Utils

- (void)setupTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(onTableRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.tableRefreshControl atIndex:0];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 100)];
    [self.tableView.tableFooterView addSubview:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
}

- (void)setupNavigationBarWithBarTintColor:(UIColor *)barTintColor andTintColor:(UIColor *)tintColor{
    self.title = @"Home";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"menuIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onMenuButton:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"new_tweet"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onCompose:)];self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = barTintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName:tintColor}];
}

- (ProfileViewController *)initWithContainerViewController:(ContainerViewController *)containerViewController {
    self = [super init];
    if (self) {
        self.containerViewController = containerViewController;
    }
    return self;
}

@end
