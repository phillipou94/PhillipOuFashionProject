//
//  FriendRequestTableViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/29/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "FriendRequestTableViewController.h"
#import "EditFriendsViewController.h"

@interface FriendRequestTableViewController ()

@end

@implementation FriendRequestTableViewController
- (void)viewDidLoad
{
    [self.tabBarController.tabBar setHidden:YES];
    
    [super viewDidLoad];
    
    self.segmentController.selectedSegmentIndex=1;
    
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationItem setHidesBackButton:YES];
    
       self.allFriends = [[NSMutableArray alloc] init];
    self.friendRequests = [[NSMutableArray alloc]init];
    self. friendsToDisplay = [[NSArray alloc]init];
    
    
    
}



-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self isViewLoaded]) {
        self.view=nil;
        [self viewDidLoad];
    }
    
    
    PFUser *currentUser = [PFUser currentUser];
    
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    self.friendsList = [currentUser objectForKey:@"friendsList"];
    //@"Friends:%@",self.friendsList);
    
   /* PFQuery *requestsQuery = [PFQuery queryWithClassName:@"FriendRequest"];
    [requestsQuery whereKey:@"status" containsString:@"Pending"];
    [requestsQuery whereKey:@"requestToObject" containsAllObjectsInArray:@[currentUser]];*/
    
    
    //PFQuery *friendsQuery = [self.friendsRelation query];
   // PFQuery *friendsQuery = [PFUser query];
   // [friendsQuery whereKey:@"objectId" containedIn: currentUser[@"friendsList"]];
    //PFQuery *query = [PFQuery orQueryWithSubqueries:@[requestsQuery,friendsQuery]];
    //@"List:%@",self.friendsList);
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query whereKey:@"status" containsString:@"Pending"];
    [query whereKey:@"requestTo" containedIn:@[currentUser.objectId]];
    [query whereKey:@"requestFrom" notContainedIn:self.friendsList];
    
    //PFQuery *query = [self.friendsRelation query]; //create query of our friends
    
    //PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"FriendRequest"];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            //@"Error %@ %@", error,[error userInfo]);
        }
        else{
            self.friendRequests=objects;   //self.friendRequests = array of friendRequest objects
            for(PFUser *friends in self.friendRequests){
                if(![self.allFriends containsObject:friends.objectId]){
                    [self.allFriends addObject:friends.objectId];}
                
            }
            [self.tableView reloadData];
        }
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [self.friendRequests count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.accessoryType=UITableViewCellAccessoryNone;
    
    
   // PFUser *currentUser = [PFUser currentUser];
   // PFUser *user = [self.friendRequests objectAtIndex: indexPath.row];
    PFObject *requestObject = [self.friendRequests objectAtIndex: indexPath.row];
    [requestObject setObject:@"Denied" forKey:@"status"];
    
    [requestObject save];
    
   
  /*  [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationFade];*/
    
        //3. remove from the backend
    
    
    [tableView reloadData];
    
    
    //[self.tableView reloadData];
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    
    
    UIImage *icon = [UIImage imageNamed: @"user-2-add"];
     UIButton *requestImage = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 16, 16)];
    [UIButton buttonWithType: UIButtonTypeCustom];
    [requestImage setBackgroundImage:icon forState:UIControlStateNormal];
    requestImage.backgroundColor = [UIColor clearColor];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //refresh each time table loads so there are no check marks
    cell.accessoryView = requestImage;
    
    PFObject *requestObject = [self.friendRequests objectAtIndex:indexPath.row];
    
  
  //  PFUser *user =requestObject[@"requestFromObject"];
    cell.textLabel.text = requestObject[@"requestFromName"];
    [cell.textLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:14]];
    
    
    //PFUser *user = [self.friendsToDisplay objectAtIndex:indexPath.row];
    ////@"username:%@",user.username);
    
    //profile picture..might slow down game.
    
  /* NSString *profilePictureID = [user objectForKeyedSubscript:@"facebookId"];
    NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",profilePictureID];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    
    cell.imageView.image = image;
    cell.imageView.frame = CGRectMake(0, 0, 5, 5);*/
    //cell.imageView.layer.masksToBounds = YES;
    //cell.imageView.layer.cornerRadius = 20;
    
    return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UIImage *icon = [UIImage imageNamed: @"user-4-addb"];
    UIButton *approveImage = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 16, 16)];
    [UIButton buttonWithType: UIButtonTypeCustom];
    [approveImage setBackgroundImage:icon forState:UIControlStateNormal];
    approveImage.backgroundColor = [UIColor clearColor];
   
    PFObject *requestObject = [self.friendRequests objectAtIndex:indexPath.row];
    PFUser *user =requestObject[@"requestFromObject"];
    if(![self.friendsList containsObject:user.objectId]){
        //@"userId:%@",user.objectId);
        @try{
            [self.friendsList addObject:user.objectId];}
        @catch(NSException *exception){
            //@"caught error");
        }
        @finally{
            //@"cleaning");
        }
        cell.accessoryView = approveImage;
        NSArray *array = [NSArray arrayWithArray:self.friendsList];
        PFUser *currentUser = [PFUser currentUser];
        PFRelation *friendsRelation = [currentUser relationForKey: @"friendsRelation"];
        [currentUser setObject:array forKey:@"friendsList"];
        [friendsRelation addObject:user];
        [currentUser saveInBackground];
    
        [requestObject setObject:@"Approved" forKey:@"status"];
        [requestObject saveInBackground];
        
    
    
    
    }
    
    //@"updated: %@",self.friendsList);
    
}
-(void) reset{
    
   
    [self.allFriends removeAllObjects];
    
    
    
    
}/*
  
  - (IBAction)setBounty:(id)sender {
  PFUser *currentUser = [PFUser currentUser];
  [self uploadMessage];
  int points = [self.points intValue];
  if ([self.points doubleValue] >[@10.0f doubleValue]){
  self.points = [NSNumber numberWithInt:points-self.bountyCost];
  [currentUser setObject: self.points forKey:@"Points" ];
  [currentUser saveInBackground];}
  //@"%@",self.points);
  [self.tabBarController setSelectedIndex:0];
  
  }
  */
- (IBAction)back:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)segmentButton:(id)sender {
    if (self.segmentController.selectedSegmentIndex==0){
        [ self.segmentController setSelectedSegmentIndex:1];
    }
   
    
}



@end