//
//  EditFriendsViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/8/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "EditFriendsViewController.h"
#import <Parse/Parse.h>
#import<AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>

@interface EditFriendsViewController ()


@end

@implementation EditFriendsViewController



- (void)viewDidLoad
{
    
    self.searchResults = [NSMutableArray arrayWithCapacity:[self.allUsers count]];
    self.allUsernames = [[NSMutableArray alloc]init];
    self.userDict = [[NSMutableDictionary alloc]init];
    self.friendsList = [[PFUser currentUser] objectForKey:@"friendsList"];
    
    PFQuery *query = [PFUser query];//get query of all users in this app
    [super viewDidLoad];
    [query orderByAscending: @"username"]; //alphabetize list
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            //(@"Error:%@ %@", error, [error userInfo]);
        }
        else{
            self.allUsers = objects;
            for (PFObject *obj in self.allUsers) {
                // access the username key of the PFObject and add it to the array we created.
                [self.allUsernames addObject:[obj objectForKey:@"username"]];
                NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
                NSString *trimmedReplacement = [[obj[@"username"] componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
                [self.userDict setObject:obj forKey:trimmedReplacement];
                
                
            }
            [self.tableView reloadData];
        }
        //(@"%@", self.userDict);
    }];
    self.currentUser = [PFUser currentUser];
    
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return [self.searchResults count];}
    
    
    // Return the number of rows in the section.
    return [self.allUsers count]; //number of rows = number of users
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    //slows down search a lot getting profile picture
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        
        NSString *username= [self.searchResults objectAtIndex:indexPath.row];
        cell.textLabel.text = username;
        [cell.textLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:14]];
        NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSString *trimmedReplacement = [[username componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];

        PFUser *user = [self.userDict objectForKey:trimmedReplacement];
        
        NSString *profilePictureID = [user objectForKeyedSubscript:@"facebookId"];
        NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",profilePictureID];
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
        
        cell.imageView.image = image;
        cell.imageView.frame = CGRectMake(0, 0, 5, 5);
        //cell = [self.userDict objectForKey:username];
    }
    else{
        cell.hidden=YES;
        cell.textLabel.text = user.username;
        
        //if user is a friend then have a check mark
        if([self isFriend:user]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType= UITableViewCellAccessoryNone;
        }
    }
    return cell;
}
#pragma mark - Helper Methods
-(BOOL) isFriend:(PFUser *)user{
    for(PFUser *friend in self.friends){
        if([friend.objectId isEqualToString:user.objectId]){ //found friend
            return YES;
        }
    }
    return NO;
    
}


-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *username = cell.textLabel.text;
        NSCharacterSet *charactersToRemove = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSString *trimmedReplacement = [[username componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];

        
        //cell.accessoryType = UITableViewCellAccessoryCheckmark; //put check mark
        //PFUser *user = [self.allUsers objectAtIndex: indexPath.row];
        
        PFUser *user = [self.userDict objectForKey:trimmedReplacement];
        PFRelation *friendsRelation = [self.currentUser relationForKey: @"friendsRelation"];//adding friends
        
        
        
        //(@"Id:%@",trimmedReplacement);
        
        if([self.friends containsObject:user.username]){
            
            //1. remove check mark
            cell.accessoryType = UITableViewCellAccessoryNone;
            //2. remove from the array of friends
            for (PFUser *friend in self.friends){
                if([friend.objectId isEqualToString:user.objectId]){
                    [self.friends removeObject:friend];
                    [self.friendsList removeObject:friend.objectId];
                    
                }
                //3. remove from the backend
                
                
                
                
                [friendsRelation removeObject:user];
                
            }
            
        }
        ///else add them
        
        
        else{
            //(@"Here's this list: %@",self.friendsList);
            NSMutableArray *updateArray = [NSMutableArray arrayWithArray:self.friendsList];
            //(@"above:%@",user);
            //(@"Testing this: %@", user.objectId);
            PFUser *currentUser = [PFUser currentUser];
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark; //add checkmark
            cell.selected =NO;
            
           self.friendsList=updateArray;
            if(![self.friendsList containsObject:user.objectId]){
                //(@"adding");
                [self.friends addObject:user];
                [updateArray addObject:user.objectId];
                //(@"running?");
                PFObject *friendRequest = [PFObject objectWithClassName:@"FriendRequest"];
                [friendRequest setObject:[[PFUser currentUser]objectId] forKey:@"requestFrom"];
                [friendRequest setObject: user.objectId forKey:@"requestTo"];
                [friendRequest setObject:[[PFUser currentUser]username] forKey:@"requestFromName"];
                [friendRequest setObject:user.username forKey:@"requestToName"];
                [friendRequest setObject:@"Pending" forKey:@"status"];
                [friendRequest setObject:[PFUser currentUser] forKey:@"requestFromObject"];
                [friendRequest setObject:user forKey:@"requestToObject"];
                [friendRequest saveInBackground];
                
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"installationUser" containsString:user.objectId];
                
                
                // Send push notification to our query
                PFPush *push = [[PFPush alloc] init];
                [push setQuery:pushQuery];
                NSDictionary *data = @{
                                       @"badge": @"Increment",
                                       @"alert": [NSString stringWithFormat:@"%@ sent you a friend request!", currentUser.username],
                                       @"sound": @""
                                       };
                
                [push setData:data];
                
                
                [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error)
                    {
                        //(@"Push notification sent!");
                    }
                }];

                
            }
            
            
            
            
            [friendsRelation addObject: user ];
            
            
            
        }
        NSArray *arrayUpdate = [NSArray arrayWithArray:self.friendsList];
        //(@"saving this list:%@",arrayUpdate);
        [self.currentUser setObject:arrayUpdate forKey:@"friendsList"];
        
        [self.currentUser saveInBackground];
        [self.tableView reloadData];
    }
    else{
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        //cell.accessoryType = UITableViewCellAccessoryCheckmark; //put check mark
        PFUser *user = [self.allUsers objectAtIndex: indexPath.row];
        PFRelation *friendsRelation = [self.currentUser relationForKey: @"friendsRelation"];//adding friends
        
        
        
        //if user tapped is a friend remove them
        if([self isFriend:user]){
            //1. remove check mark
            cell.accessoryType = UITableViewCellAccessoryNone;
            //2. remove from the array of friends
            for (PFUser *friend in[self.friends copy] ){
                if([friend.objectId isEqualToString:user.objectId]){
                    [self.friends removeObject:friend];
                    
                }
                //3. remove from the backend
                [friendsRelation removeObject:user];
                
            }
            
        }
        ///else add them
        
        
        else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark; //add checkmark
            [self.friends addObject:user];
            //(@"running?");
            
            /*PFObject *friendRequest = [PFObject objectWithClassName:@"FriendRequest"];
             [friendRequest setObject:currentUser forKey:@"requestFrom"];
             [friendRequest setObject: user forKey:@"requestTo"];
             [friendRequest setObject:user.username forKey:@"requestToName"];
             [friendRequest setObject:currentUser.username forKey:@"requestFromName"];
             
             [friendRequest setObject:@"Pending" forKey:@"status"];
             [friendRequest saveInBackground];*/
            
            [friendsRelation addObject: user ];
            
            
        }
    }
    /*[self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
     {
     if(error){
     //(@"Error %@ %@, error", [error userInfo]);
     }
     }
     }];
     
     
     
     }*/
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        {
            if(error){
                //(@"Error %@, error", [error userInfo]);
            }
        }
    }];
    [self.tableView reloadData];
    
    
    
    
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{[self.searchResults removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] %@", searchText];
    self.searchResults = [NSMutableArray arrayWithArray: [self.allUsernames filteredArrayUsingPredicate:resultPredicate]];
    
    //(@"searches:%@",self.searchResults);
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (IBAction)sendSMS:(id)sender {
    MFMessageComposeViewController *textComposer = [[MFMessageComposeViewController alloc] init];
    textComposer.messageComposeDelegate = self;
    //[textComposer setMessageComposeDelegate:self];
    //if there is a thing to send texts
    if([MFMessageComposeViewController  canSendText]){
        [textComposer setRecipients:[NSArray arrayWithObjects:nil]];
        [textComposer setBody:@"Download Rascal to get rewarded for embarassing your friends! https://itunes.apple.com/us/app/rascal/id906539832?ls=1&mt=8"];
        //send to iMessage
        [self presentViewController:textComposer animated:YES completion:nil];
        
    }
    else{
        //(@"unable to load iMessage");
    }
}
//dismiss sms view controller when we're done with it.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [controller dismissModalViewControllerAnimated:YES];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end