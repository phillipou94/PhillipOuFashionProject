//
//  FriendRequestTableViewController.h
//  Rascal
//
//  Created by Phillip Ou on 7/29/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface FriendRequestTableViewController : UITableViewController

@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSMutableArray *friendRequests;
@property (nonatomic, strong) NSArray *friendsToDisplay;

@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) PFUser *user;
@property(nonatomic, strong) NSMutableArray *allFriends;
@property (nonatomic, strong) NSMutableArray *friendsList;
@property (nonatomic, assign) int indexRow;


@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property int section;






@end
