//
//  HomeViewController.m
//  Twitter
//
//  Created by Charles Dong on 2/22/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "HomeViewController.h"
#import "DetailViewController.h"
#import "ComposeViewController.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TweetCell.h"


@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, TweetCellDelegate, ComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *infiniteLoadingView;

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, assign) BOOL isCurrentlyLoading;
@property (nonatomic, assign) BOOL isInfiniteLoading;
@property (nonatomic, assign) BOOL isPullDownRefreshing;

@property (nonatomic, weak) ContainerViewController *containerViewController;

@end

@implementation HomeViewController

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
    
    // show background to begin with
    self.backgroundView.backgroundColor = twitterColor;
    self.tableView.hidden = YES;
    //self.navigationController.navigationBarHidden = YES;
    
    // initialize stuff
    self.tweets = [NSMutableArray array];
    self.isCurrentlyLoading = NO;
    self.isInfiniteLoading = NO;
    self.isPullDownRefreshing = NO;
    
    //get tweets 
    [self homeTimelineWithParams:nil];
}


#pragma mark - User Actions

- (void)onMenuButton:(id)sender {
    [self.containerViewController toggleMenu];
}

//- (void)onLogout:(id)sender {
//    [User logout];
//}

- (void)onTableRefresh:(id)sender {
    if (!self.isCurrentlyLoading){
        self.isPullDownRefreshing = YES;
        [self homeTimelineWithParams:nil];
    } else {
        NSLog(@"Tried to pullDownRefresh whilst already loading.");
    }
}

- (void)onCompose:(id)sender {
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    cvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onReply:(Tweet *)tweet {
    ComposeViewController *cvc = [[ComposeViewController alloc] init];
    cvc.delegate = self;
    cvc.replyToTweet = tweet;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:cvc];
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - Delegate Methods

- (void)ComposeViewController:(ComposeViewController *)composeViewController tweeted:(Tweet *)tweet {
    
    [[TwitterClient sharedInstance] tweet:tweet completion:^(Tweet *tweet, NSError *error) {
        // Insert the new tweet to the top
        NSMutableArray *newTweets = [NSMutableArray arrayWithObject:tweet];
        [self.tweets replaceObjectsInRange:NSMakeRange(0,0)
                      withObjectsFromArray:newTweets];
        [self.tableView reloadData];
    }];
}

#pragma mark - User Actions

-(void)tweetCell:(TweetCell *)tweetCell didClickReply: (Tweet *) tweet {
    [self onReply:tweet];
}

-(void)tweetCell:(TweetCell *)tweetCell didClickRetweet: (Tweet *) tweet {
    // tweet.retweeted was set to !tweet.retweeted prior to getting here
    if (!tweet.retweeted) {
        [[TwitterClient sharedInstance] deleteTweet:tweet.tweetID completion:^(Tweet *tweet, NSError *error) {
            // completion block
            if (error) {
                NSLog(@"Error: %@", error);
            } else {
                NSLog(@"Successfully deleted tweet %@", tweet.text);
            }
        }];
    } else {
        [[TwitterClient sharedInstance] retweet:tweet completion:^(Tweet *tweet, NSError *error) {
            // completion block
            if (error) {
                NSLog(@"Error: %@", error);
            } else {
                NSLog(@"Successfully retweeted tweet %@", tweet.text);
            }
        }];
    }
    
    // reload the cell
    [self.tableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[self.tableView indexPathForCell:tweetCell], nil] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)tweetCell:(TweetCell *)tweetCell didClickFavorite: (Tweet *) tweet {
    // tweet.favorited was set to !tweet.favorited prior to getting here
    if (!tweet.favorited) {
        [[TwitterClient sharedInstance] unfavorite:tweet.tweetID completion:^(Tweet *tweet, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
            } else {
                NSLog(@"Successfully unfavorited tweet %@", tweet.text);
            }
        }];
    } else {
        [[TwitterClient sharedInstance] favorite:tweet.tweetID completion:^(Tweet *tweet, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
            } else {
                NSLog(@"Successfully favorited tweet %@", tweet.text);
            }
        }];
    }
    // reload the cell
    [self.tableView reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[self.tableView indexPathForCell:tweetCell], nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = self.tweets[indexPath.row];
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    cell.tweet = tweet;
    cell.delegate = self;
    
    // Infinite loading
    if (indexPath.row == self.tweets.count - 1 && !self.isCurrentlyLoading) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSInteger max_id = [tweet.tweetID integerValue] - 1;
        [params setObject:@(max_id) forKey:@"max_id"];
        self.isInfiniteLoading = YES;
        [self homeTimelineWithParams:params];
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

- (HomeViewController *)initWithContainerViewController:(ContainerViewController *)containerViewController {
    self = [super init];
    if (self) {
        self.containerViewController = containerViewController;
    }
    return self;
}

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

- (void)homeTimelineWithParams:(NSDictionary *)params {
    self.isCurrentlyLoading = YES;
    // get tweets
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completionBlock:^(NSArray *tweets, NSError *error) {
        if (self.isInfiniteLoading) {
            [self.tweets addObjectsFromArray:tweets];
        } else {
            self.tweets = [tweets mutableCopy];
        }
        
        if (self.isPullDownRefreshing) {
            [self.tableRefreshControl endRefreshing];
        } else if (self.isInfiniteLoading) {
            [self.infiniteLoadingView stopAnimating];
        }
        
        // show timeline
        self.backgroundView.hidden = YES;
        self.tableView.hidden = NO;
        self.navigationController.navigationBarHidden = NO;
        self.isCurrentlyLoading = NO;
        self.isInfiniteLoading = NO;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
