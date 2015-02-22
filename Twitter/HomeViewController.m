//
//  HomeViewController.m
//  Twitter
//
//  Created by Charles Dong on 2/22/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "HomeViewController.h"
#import "TwitterClient.h"
#import "Tweet.h"

NSString *const Tweet_Cell_ID = @"TweetCell";

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;
@property (nonatomic, strong) UIActivityIndicatorView *infiniteLoadingView;

@property (nonatomic, strong) NSMutableArray *tweets;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIColor *twitterColor = [UIColor  colorWithRed:85.0f/255.0f green:172.0f/255.0f blue:238.0f/255.0f alpha:1.0f];
    UIColor *twitterSecondaryColor = [UIColor  colorWithRed:245.0f/255.0f green:248.0f/255.0f blue:250.0f/255.0f alpha:1.0f];
     // navigation bar
    [self setupNavigationBarWithBarTintColor:twitterColor andTintColor:twitterSecondaryColor];
    
    // table view setup
    [self.tableView registerNib:[UINib nibWithNibName:Tweet_Cell_ID bundle:nil] forCellReuseIdentifier:Tweet_Cell_ID];
    [self setupTableView];
    
    // show background to begin with
    self.backgroundView.backgroundColor = twitterColor;
    self.tableView.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    
    // initialize stuff
    self.tweets = [NSMutableArray array];
    
    //get tweets 
    [self homeTimelineWithParams:nil];
}


#pragma mark - User Actions

- (void)onLogout:(id)sender {
    [User logout];
}

- (void)onTableRefresh:(id)sender {
    [self homeTimelineWithParams:nil];
}

- (void)onCompose:(id)sender {
    
}

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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"Logout"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onLogout:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"new_tweet"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onCompose:)];self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = barTintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName:tintColor}];
}

- (void)homeTimelineWithParams:(NSDictionary *)params {
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completionBlock:^(NSArray *tweets, NSError *error) {
        self.tweets = [tweets mutableCopy];
        
        // show timeline
        self.backgroundView.hidden = YES;
        self.tableView.hidden = NO;
        self.navigationController.navigationBarHidden = NO;
        [self.tableRefreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
