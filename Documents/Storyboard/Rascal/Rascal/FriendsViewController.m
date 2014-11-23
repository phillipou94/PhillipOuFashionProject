//
//  FriendsViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/8/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

//////bounties are being sent without recipients some times.

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"
#import "Reachability.h"
#import "InboxViewController.h"
@interface FriendsViewController ()

@end

@implementation FriendsViewController



- (void)viewDidLoad
{
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"back"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    self.navigationItem.backBarButtonItem.tintColor =[UIColor colorWithRed:51/255.0 green:70/255.0 blue:192/255.0 alpha:1.0];
   // [[self.parentViewController navigationItem] setBackBarButtonItem: newBackButton];
    //(@"calling viewdidload");
    [super viewDidLoad];
    
    
    
    [self.navigationController.navigationBar setHidden:NO];
    self.bountyCost = 10;
    self.recipientsOfBounties = [[NSMutableArray alloc] init];
    self.allFriends = [[NSMutableArray alloc] init];
    self.friends = [[NSArray alloc]init];
   
    
   
}
    
- (BOOL)connected{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

-(void) viewWillAppear:(BOOL)animated{
    
    if (![self connected]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"There is no network connection" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        // connected, do some internet stuff
    }
   
    [super viewWillAppear:animated];
    
   
    PFUser *currentUser = [PFUser currentUser];
    self.points = currentUser[@"Points"];
    //(@"Points:%@",self.points);
    [self.recipientsOfBounties removeAllObjects];
    self.clickCount = 0;
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    self.friendsList = [currentUser objectForKey:@"friendsList"];
    //(@"Friends:%@",self.friendsList);
    
    PFQuery *requestsQuery = [PFQuery queryWithClassName:@"FriendRequest"];
    [requestsQuery whereKey:@"status" containsString:@"Pending"];
    [requestsQuery whereKey:@"requestTo" containsAllObjectsInArray:@[currentUser.objectId]];
    
    
    
    //PFQuery *friendsQuery = [self.friendsRelation query];
    PFQuery *friendsQuery = [PFUser query];
    [friendsQuery whereKey:@"objectId" containedIn: currentUser[@"friendsList"]];
    //PFQuery *query = [PFQuery orQueryWithSubqueries:@[requestsQuery,friendsQuery]];
    
    
   PFQuery *query = [self.friendsRelation query]; //create query of our friends
    
    //PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"FriendRequest"];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            //(@"Error %@ %@", error,[error userInfo]);
        }
        else{
            self.friends=objects;   //self.friends array = objects array returned in findObjectsinBackgroundwithblock
            for(PFUser *friends in self.friends){
                [self.allFriends addObject:friends.objectId];
                
            }
            [self.tableView reloadData];
        }
    }];

}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showEditFriends"]){
        EditFriendsViewController *viewController = (EditFriendsViewController *)segue.destinationViewController;
        viewController.friends = [NSMutableArray arrayWithArray: self.friends];
    }
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
    return [self.friends count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

#pragma mark fix this later
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFUser *currentUser = [PFUser currentUser];
    PFUser *user = [self.friends objectAtIndex: indexPath.row];
    PFRelation *friendsRelation = [currentUser relationForKey: @"friendsRelation"];//adding friends
    //NSMutableArray *updateArray = self.friendsList;
    for (PFUser *friend in[self.friends copy] ){
        
        if([friend.objectId isEqualToString:user.objectId]){
            //(@"friendID:%@",friend.objectId);
            [friendsRelation removeObject:friend];
            [self.friends removeObject:friend];
            [currentUser setObject:self.friends forKey:@"friendsList"];
            if(![friend.objectId isEqualToString: currentUser.objectId]){
                //(@"deleting:%@",friend.objectId);
                if([self.friendsList containsObject:friend.objectId]){
                    
                        NSUInteger index = [self.friendsList indexOfObject: friend.objectId];
                                    
                        //(@"contains it: %@",self.friendsList);
                        //(@"at index: %d",index);
                    @try{
                        [self.friendsList removeObjectAtIndex:index];
                        }
                    @catch(NSException *exception){
                        //(@"caught error");
                        
                        
                        //HE'S REMOVED FROM THE FRIEND RELATION BUT NOT THE ACTUAL LIST OF FRIENDS.
                       
                    }
                    @finally{
                        //(@"cleaning up");
                    }
                }
            }
                                    
        
            NSArray *array = [NSArray arrayWithArray:self.friendsList];
            [currentUser setObject:array forKey:@"friendsList" ];
            //(@"Remove %@",user.username);
            
            [currentUser saveInBackground];
           
            
            
        }
        //3. remove from the backend
        

    }
        [self.tableView reloadData];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    

    [cell setBackgroundColor:[UIColor clearColor]];
    //refresh each time table loads so there are no check marks
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username.lowercaseString;
    [cell.textLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:14]];
    
    
    
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



-(void) reset{
    PFUser *currentUser = [PFUser currentUser];
    [self.recipientsOfBounties removeAllObjects];
    self.points=currentUser[@"Points"];
    [self.allFriends removeAllObjects];
    
    
    
    
}
- (IBAction)back:(id)sender {
   
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)segmentButton:(id)sender {
    if(self.segmentController.selectedSegmentIndex==0){
        self.section=0;
    }
    else{
        //(@"calling this!!!!");
        self.segmentController.selectedSegmentIndex=0;
        
       
    }
    
}



@end
