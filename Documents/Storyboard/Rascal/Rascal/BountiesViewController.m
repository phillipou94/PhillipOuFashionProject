//
//  BountiesViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/20/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "BountiesViewController.h"
#import "EditFriendsViewController.h"
@interface BountiesViewController ()

@end

@implementation BountiesViewController



- (void)viewDidLoad
{
    [self.navigationController.navigationBar setHidden:NO];
    [super viewDidLoad];
    self.bountyCost = 5;
    self.bountyValue = 1;
    self.currentUser = [PFUser currentUser];
    self.recipientsOfBounties = [[NSMutableArray alloc] init];
    self.allFriends = [[NSMutableArray alloc] init];
    self.friends = [[NSArray alloc]init];
}







-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.bountyButton.selected=NO;
    
    self.points = self.currentUser[@"Points"];
    //(@"Points:%@",self.points);
    [self.recipientsOfBounties removeAllObjects];
    self.clickCount = 0;
    self.friendsRelation = [self.currentUser objectForKey:@"friendsRelation"];
    
    PFQuery *query = [self.friendsRelation query]; //create query of our friends
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //refresh each time table loads so there are no check marks
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username.lowercaseString;
    [cell.textLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:14]];
   
    
    return cell;
}

/*
-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    if(self.clickCount==0){
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if(cell.accessoryType==UITableViewCellAccessoryNone){
            cell.accessoryType = UITableViewCellAccessoryCheckmark; //put check mark
            self.user = [self.friends objectAtIndex: indexPath.row];
            //(@"bounty on %@",self.user.objectId);
            
            [self.recipientsOfBounties addObject:self.user.objectId];
            [self.allFriends addObject:self.user.objectId];
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.clickCount = 1;
            
            
        }
        
        
        
    }
    else{
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.user = [self.friends objectAtIndex: indexPath.row];
        if(cell.accessoryType==UITableViewCellAccessoryCheckmark ){
            //1. remove check mark
            cell.accessoryType = UITableViewCellAccessoryNone;
            //2. remove from the array of friends
            [self.recipientsOfBounties removeObject: self.user.objectId];
            self.clickCount=0;
            
        }
        
        
        
        
    }
    //(@"Click Count:%d",self.clickCount);
    //(@"RecipientsofBounties:%@",self.recipientsOfBounties);
    //(@"%@",self.user.username);
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath

{
    
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView cellForRowAtIndexPath:indexPath].selected=NO;
    self.user = [self.friends objectAtIndex: indexPath.row];
    //(@"bounty on %@",self.user.objectId);
    
    
    [self.recipientsOfBounties addObject:self.user.objectId];
    [self.allFriends addObject:self.user.objectId];
    //(@"RecipientsofBounties:%@",self.recipientsOfBounties);
    //(@"%@",self.user.username);
    
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}
-(BOOL) isFriend:(PFUser *)user{
    for(PFUser *friend in self.friends){
        if([friend.objectId isEqualToString:user.objectId]){ //found friend
            return YES;
        }
    }
    return NO;
    
}
#pragma mark - TO DO
- (void)uploadMessage {
   
    
    
    
    
        if ([self.recipientsOfBounties count] !=0){
            
            //PFObject *bounty = [PFObject objectWithClassName:@"Messages"];
            PFObject *bountyNotice = [PFObject objectWithClassName:@"Messages"];
            
            //self.allFriends addObjectsFromArray:currentUser[@"]
            PFACL *readAccess = [[PFACL alloc]init];
            //PFACL *readAccess2 = [[PFACL alloc]init];
            [readAccess setReadAccess:YES forUserId:self.user.objectId];
            
            
            PFQuery *pushQuery = [PFInstallation query];
            NSMutableArray *friendsListMinusVictimAndSelf = [NSMutableArray arrayWithArray:self.allFriends];
            //create this array so that the victim doesn't get two push notifications when bounty is set on him.
            //so the sender doesn't get user id as well.
            [friendsListMinusVictimAndSelf removeObject: self.user.objectId];
            [friendsListMinusVictimAndSelf removeObject: self.currentUser.objectId];
            [pushQuery whereKey:@"installationUser" containedIn:friendsListMinusVictimAndSelf]; //allFriends except for user
            
            NSDictionary *data = @{
                                   @"badge": @"Increment",
                                   @"alert": [NSString stringWithFormat:@"%@ set a bounty on %@!", self.currentUser.username,self.user.username],
                                   @"sound": @""
                                   };
            
          
            // Send push notification to our query
            PFPush *push = [[PFPush alloc] init];
            [push setData:data];
            [push setQuery:pushQuery];
            
            
            
            

           // [push setMessage:[NSString stringWithFormat:@"%@ set a bounty on %@!", self.currentUser.username,self.user.username]];
            
            
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error)
                {
                    //(@"Push notification sent!");
                }
            }];
            
            
            PFQuery *pushQuery2 = [PFInstallation query];
            [pushQuery2 whereKey:@"installationUser" containsString:self.user.objectId]; //allFriends is array of user ids
            
            // Send push notification to our query
            PFPush *push2 = [[PFPush alloc] init];
            NSDictionary *data2 = @{
                                   @"badge": @"Increment",
                                   @"alert": [NSString stringWithFormat:@"%@ set a bounty on you!", self.currentUser.username],
                                   @"sound": @""
                                   };
            [push2 setQuery:pushQuery2];
            [push2 setData:data2];
        
            //[push2 setMessage:[NSString stringWithFormat:@"%@ set a bounty on you!", self.currentUser.username]];
            
            
            [push2 sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error)
                {
                    //(@"Push2 notification sent!");
                }
            }];

            
            
            UIAlertView *bountyAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You Have Set a Bounty on %@!",self.user.username]
                                                                  message:@"Now We Wait"
                                                                 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [bountyAlert show];

            //[readAccess2 setReadAccess:NO forUserId:self.user.objectId];
         /*   [bounty setObject:@"bounty" forKey:@"fileType"];
            [bounty setObject:self.recipientsOfBounties forKey:@"recipientIds"];
            [bounty setACL: readAccess];
            [bounty setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            
          
            [bounty setObject:currentUser.username forKey:@"senderName"];
            [bounty saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try sending your message again."
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                    
                }
            }];*/
            [self.allFriends removeObject:self.user.objectId]; //so guy receiving bounty won't get duplicate notification
            [self.allFriends removeObject: self.currentUser.objectId]; //so current user doesn't get notifications (might have crash if current user isn't in the array but we'll see)
            self.friends = [NSArray arrayWithArray: self.allFriends];
            //(@"Receiving Bounty Notice: %@",self.friends);
            [bountyNotice setObject:@"bountyNotice" forKey:@"fileType"];
            //[bountyNotice setACL: readAccess2];
            [bountyNotice setObject:self.friends forKey:@"recipientIds"];//notification goes to all friends
            [bountyNotice setObject:self.user.username forKey:@"recipientUsername"];
            [bountyNotice setObject:self.currentUser.username forKey:@"senderName"];
            [bountyNotice setObject:self.currentUser.objectId forKey:@"senderId"];
            [bountyNotice setObject: self.user.objectId forKey: @"victimId"];
            [bountyNotice setObject: [NSNumber numberWithInt:self.bountyValue] forKey:@"bountyValue"];
            
            [bountyNotice saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An error occurred!"
                                                                        message:@"Please try sending your message again."
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                
            }];
            
            [self reset];}
        
    
    // (@"No Bounties Set");
}


///PUT PUSH NOTIFICATION FOR ALL CURRENT USERS FRIENDS

-(void) reset{
    
    [self.recipientsOfBounties removeAllObjects];
    self.points=self.currentUser[@"Points"];
    [self.allFriends removeAllObjects];
    
    
    
    
}

- (IBAction)question:(id)sender {
    UIAlertView *answer = [[UIAlertView alloc] initWithTitle:@"Bounty"
                                                          message:@"[boun-tee] noun - a request for a funny photo of someone sent to all friends"
                                                         delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [answer show];
    
}


- (IBAction)setBounty:(id)sender {
    
    self.bountyButton.selected=YES;
    
    int points = [self.points intValue];
    if([self.points intValue] < self.bountyCost){
        //if users don't have enough points, don't let them set bounties
        
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You Don't Have Enough Points"
                                                            message:@"Send More Photos!"
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //(@"you actually have %@",self.points);
        [alertView show];
        [self reset];
        [self.tabBarController setSelectedIndex:0];
    }
   // if ([self.points intValue] >=self.bountyCost){
    else{
        if ([self.recipientsOfBounties count] !=0){
            [self uploadMessage];
            self.points = [NSNumber numberWithInt:points-self.bountyCost];
            [self.currentUser setObject: self.points forKey:@"Points" ];
            [self.currentUser saveInBackground];
        [self.tabBarController setSelectedIndex:0];}
        
            else{
                UIAlertView *warning = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You didn't pick a user"]
                                                                  message:@"Please select one"
                                                                 delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [warning show];
            }
    }
    
    
    
    //(@"%@",self.points);
    
    
}
- (IBAction)back:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}








@end
