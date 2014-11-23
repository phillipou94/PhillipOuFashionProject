//
//  EditFriendsViewController.h
//  Rascal
//
//  Created by Phillip Ou on 7/8/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h>
@interface EditFriendsViewController : UITableViewController<MFMessageComposeViewControllerDelegate>
@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) NSMutableArray *allUsernames;
@property (nonatomic, strong) NSMutableDictionary *userDict;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *friends; //array of friends we can edit
@property (nonatomic, strong) NSMutableArray *friendsList;
-(BOOL) isFriend:(PFUser*) user;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
