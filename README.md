## Twitter

Basic twitter app to read, retweet, favorite, and compose tweets: see the [Twitter API](https://apps.twitter.com/).

Time spent: `27 hours`

### Features

#### Required

- [x] User can sign in using OAuth login flow
- [x] User can view last 20 tweets from their home timeline
- [x] The current signed in user will be persisted across restarts
- [x] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.  In other words, design the custom cell with the proper Auto Layout settings.  You will also need to augment the model classes.
- [x] User can pull to refresh
- [x] User can compose a new tweet by tapping on a compose button.
- [ ] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [x] User can retweet and favorite to the tweet directly from the timeline feed.
- [x] Dragging anywhere in the view should reveal the menu.
- [x] The menu should include links to your profile, the home timeline, and the mentions view.
- [x] The menu can look similar to the LinkedIn menu below or feel free to take liberty with the UI.
- [x] Profile page contains the user header view
- [x] Profile page contains a section with the users basic stats: # tweets, # following, # followers
- [x] Tapping on a user image should bring up that user's profile page

#### Optional

- [x] When composing, you should have a countdown in the upper right for the tweet limit.
- [x] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [x] Retweeting and favoriting should increment the retweet and favorite count.
- [x] User should be able to unfavorite and should decrement favorite count.
- [ ] Replies should be prefixed with the username and the reply_id should be set when posting the tweet,
- [x] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.
- [x] In the timeline, show first photo alongside the text if the tweet contains photos
- [ ] In detail tweet view, show all photos and also provide photo gallery view 

### Walkthrough

![Alt text](https://github.com/charles-dong/Twitter/blob/master/yayTwitter2.gif)
