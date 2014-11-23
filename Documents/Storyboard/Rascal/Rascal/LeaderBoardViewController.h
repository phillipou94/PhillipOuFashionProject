//
//  LeaderBoardViewController.h
//  Rascal
//
//  Created by Phillip Ou on 7/21/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface LeaderBoardViewController : UITableViewController
@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSArray *friends;
@property(nonatomic, strong) NSMutableArray *allFriends;
@end
