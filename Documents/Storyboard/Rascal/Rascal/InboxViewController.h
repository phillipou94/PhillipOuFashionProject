//
//  InboxViewController.h
//  Rascal
//
//  Created by Phillip Ou on 7/9/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ImageViewController.h"
@class Reachability;

@interface InboxViewController : PFQueryTableViewController
- (BOOL)connected;

@property(nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) PFObject *selectedMessage;
@property(nonatomic, strong) NSArray *bounties;
@property(nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) UIImage *bountyUserLogo;
@property (nonatomic, strong) UIButton *bountyLogo;
@property (nonatomic, strong) UIButton *moneyLogo;
@property (nonatomic, strong) UIImage *unseenPhotoImage;
@property (nonatomic, strong) UIImage *marquee;
@property (nonatomic, retain) UIImage *icon2;

@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionFileType;

@property (strong, nonatomic) IBOutlet PFImageView *profileImageView;

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property int loadcount;
@property (strong, nonatomic) NSArray *allFriends;
@property (strong, nonatomic) NSMutableArray* friendsList;
@property (nonatomic, strong) PFUser *currentUser;

@property (strong, nonatomic) IBOutlet UIButton *bountyButton;


@end
