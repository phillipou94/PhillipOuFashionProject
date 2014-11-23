//
//  FriendsViewController.h
//  Rascal
//
//  Created by Phillip Ou on 7/8/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsViewController : UITableViewController

@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *targettedFriends;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSMutableArray *recipientsOfBounties;
@property (nonatomic, strong) NSNumber *points;
@property(nonatomic, strong) NSMutableArray *allFriends;
@property (nonatomic, strong) NSMutableArray *friendsList;
@property (nonatomic, assign) int clickCount;
@property (nonatomic,assign) int bountyCost;


@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentController;
@property int section;
@property int test;





@end
