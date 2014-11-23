//
//  LeaderBoardViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/21/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "LeaderBoardViewController.h"

@interface LeaderBoardViewController ()

@end

@implementation LeaderBoardViewController
-(void) viewDidLoad{
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    PFUser *currentUser = [PFUser currentUser];
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];
    PFQuery *friendsQuery= [self.friendsRelation query]; //create query of our friends
    PFQuery *selfQuery = [PFUser query];
    [selfQuery whereKey:@"username" containedIn:@[currentUser.username]];
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[friendsQuery,selfQuery]];
    [query orderByDescending:@"Points"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            //NSLog(@"Error %@ %@", error,[error userInfo]);
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
    PFUser *currentUser = [PFUser currentUser];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //need to initialize cell
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //refresh each time table loads so there are no check marks
    
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:1];
    UILabel *pointsLabel = (UILabel*) [cell viewWithTag:2];
    UILabel *rankLabel = (UILabel*) [cell viewWithTag:3];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    nameLabel.text = user.username.lowercaseString;
    nameLabel.adjustsFontSizeToFitWidth=YES;
    [nameLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:14]];
    //highlight current user
    if([user.username isEqualToString:currentUser.username]){
        nameLabel.highlighted = YES;
        rankLabel.highlighted =YES;
        pointsLabel.highlighted=YES;
    }
    pointsLabel.text =[ NSString stringWithFormat: @"%@",[user objectForKey:@"Points"]];
    [pointsLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:14]];
    rankLabel.text = [NSString stringWithFormat: @"#%ld", indexPath.row+1];
    [rankLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:14]];
    
    //profile picture..might slow down game.
    
   /* NSString *profilePictureID = [user objectForKeyedSubscript:@"facebookId"];
    NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",profilePictureID];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    
    cell.imageView.image = image;
    
    [cell.imageView setFrame:CGRectMake(0, 0, 5, 5)];
    [cell addSubview:cell.imageView];*/
    //cell.imageView.frame = CGRectMake(50.0, 0, 5, 5);
    //cell.textLabel.text = user.username;
    
    
    
    //profile picture..might slow down game.
    /*
    NSString *profilePictureID = [user objectForKeyedSubscript:@"facebookId"];
    NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",profilePictureID];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    
    cell.imageView.image = image;
    cell.imageView.frame = CGRectMake(0, 0, 5, 5);*/
    //cell.imageView.layer.masksToBounds = YES;
    //cell.imageView.layer.cornerRadius = 20;
    
    return cell;
}



@end
