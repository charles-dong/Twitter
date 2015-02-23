//
//  ComposeViewController.m
//  Twitter
//
//  Created by Charles Dong on 2/22/15.
//  Copyright (c) 2015 Charles Dong. All rights reserved.
//

#import "ComposeViewController.h"
#import "TwitterClient.h"
#import "UIImageView+AFNetworking.h"

@interface ComposeViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (weak, nonatomic) IBOutlet UILabel *characterCount;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIColor *twitterColor = [[TwitterClient sharedInstance] twitterColor];
    UIColor *twitterSecondaryColor = [[TwitterClient sharedInstance] twitterSecondaryColor];
    
    // navigation bar
    [self setupNavigationBarWithBarTintColor:twitterColor andTintColor:twitterSecondaryColor];
    
    // setup user
    User *currentUser = User.currentUser;
    [self.profilePicture setImageWithURL:[NSURL URLWithString:currentUser.profileImageURL] placeholderImage:[UIImage imageNamed:@"twitter_profile_pic_48x48"]];
    self.profilePicture.layer.cornerRadius = 3;
    self.profilePicture.clipsToBounds = YES;
    self.username.text = currentUser.name;
    self.screenName.text = currentUser.screenName;
    
    // other setup
    self.textField.delegate = self;
    //self.backgroundView.backgroundColor = twitterColor;
    
    // reply
    if (self.replyToTweet != nil) {
        self.textField.text = [NSString stringWithFormat:@"@%@ ", self.replyToTweet.user.screenName];
        // Move the cursor to the end
        self.textField.selectedRange = NSMakeRange([self.textField.text length], 0);
        self.characterCount.text = [NSString stringWithFormat:@"%ld", 140 - self.textField.text.length];
        [self.textField becomeFirstResponder];
    }
    
}


#pragma mark - User Actions

- (void)textViewDidChange:(UITextView *)textView {
    self.characterCount.text = [NSString stringWithFormat:@"%ld", 140 - textView.text.length];
}

- (void) onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onSend:(id)sender {
    
    Tweet *newTweet = [Tweet createNewTweetWithText:self.textField.text andReplyID:self.replyToTweet];

    if (self.delegate) {
        [self.delegate ComposeViewController:self tweeted:newTweet];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utils

- (void)setupNavigationBarWithBarTintColor:(UIColor *)barTintColor andTintColor:(UIColor *)tintColor{
    self.title = @"Compose";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onCancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"new_tweet"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(onSend:)];self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.barTintColor = barTintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName:tintColor}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
