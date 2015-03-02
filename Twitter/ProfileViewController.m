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
#import "TweetCell.h"
#import "ProfileCell.h"
#import "DetailViewController.h"

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate, TweetCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *coverPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, assign) BOOL isCurrentlyLoading;
@property (nonatomic, assign) BOOL isInfiniteLoading;
@property (nonatomic, weak) ContainerViewController *containerViewController;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // table view setup
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
    [self setupTableView];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIColor *twitterColor = [[TwitterClient sharedInstance] twitterColor];
    UIColor *twitterSecondaryColor = [[TwitterClient sharedInstance] twitterSecondaryColor];
    // navigation bar
    [self setupNavigationBarWithBarTintColor:twitterColor andTintColor:twitterSecondaryColor];
    
    // profile picture
    [self.profilePic setImageWithURL:[NSURL URLWithString:self.user.profileImageURL] placeholderImage:[UIImage imageNamed:@"twitter_profile_pic_48x48"]];
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2;
    self.profilePic.clipsToBounds = YES;
    
    // cover photo
    if (self.user.profileBannerImageURL != nil) {
        [self.coverPhoto setImageWithURL:[NSURL URLWithString:self.user.profileBannerImageURL]];
    } else {
        [self.coverPhoto setImage:[UIImage imageNamed:@"default_cover_photo"]];
    }
    
    [self loadTimelineWithParams:nil];
}

#pragma mark - User Actions

-(void)tweetCell:(TweetCell *)tweetCell didTapProfilePicOfUser:(User *)user {
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    pvc.user = user;
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)onMenuButton:(id)sender {
    [self.containerViewController toggleMenu];
}

- (void)onBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onCompose:(id)sender {
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    cvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - Table Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + self.tweets.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
        cell.user = self.user;
        return cell;
    }
    
    Tweet *tweet = self.tweets[indexPath.row - 1];
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    cell.tweet = tweet;
    cell.delegate = self;
    
    // Infinite loading
    if (indexPath.row == self.tweets.count && !self.isCurrentlyLoading) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSInteger max_id = [tweet.tweetID integerValue] - 1;
        [params setObject:@(max_id) forKey:@"max_id"];
        self.isInfiniteLoading = YES;
        [self loadTimelineWithParams:params];
    }
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DetailViewController *dvc = [[DetailViewController alloc] init];
    dvc.tweet = self.tweets[indexPath.row];
    dvc.indexPath = indexPath;
    dvc.delegate = self;
    [self.navigationController pushViewController:dvc animated:YES];
}

#pragma mark - Utils

- (void)loadTimelineWithParams:(NSMutableDictionary *)params {
    self.isCurrentlyLoading = YES;
    
    [[TwitterClient sharedInstance] userTimelineWithParams:nil forUser:self.user completion:^(NSArray *tweets, NSError *error) {
        if (!error) {
            if (self.isInfiniteLoading) {
                [self.tweets addObjectsFromArray:tweets];
            } else {
                self.tweets = [tweets mutableCopy];
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"Failed to get user timeline in profile vc");
        }
        self.isCurrentlyLoading = NO;
        self.isInfiniteLoading = NO;
    }];
}

- (void)setupTableView {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //self.tableRefreshControl = [[UIRefreshControl alloc] init];
    //[self.tableRefreshControl addTarget:self action:@selector(onTableRefresh:) forControlEvents:UIControlEventValueChanged];
    //[self.tableView insertSubview:self.tableRefreshControl atIndex:0];
    
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 100)];
    //[self.tableView.tableFooterView addSubview:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
}

- (void)setupNavigationBarWithBarTintColor:(UIColor *)barTintColor andTintColor:(UIColor *)tintColor{
    self.title = @"";
    if (self.containerViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"menuIconBlue"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onMenuButton:)];
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onBackButton:)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"new_tweet"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onCompose:)];self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor];
    self.navigationController.navigationBar.tintColor = [UIColor clearColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    //    self.allowDefaultTableScroll = YES;
}

- (ProfileViewController *)initWithContainerViewController:(ContainerViewController *)containerViewController {
    self = [super init];
    if (self) {
        self.containerViewController = containerViewController;
    }
    return self;
}

@end
