//
//  ImageViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/9/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    PFUser *currentUser = [PFUser currentUser];
    PFFile *imageFile = [self.message objectForKey: @"file"];
    
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageFile.url]];
    
   
    self.imageView.image = [UIImage imageWithData:imageData];
    
    
    UIColor *borderColor = [UIColor whiteColor];
    [self.imageView.layer setBorderColor:borderColor.CGColor];
    [self.imageView.layer setBorderWidth:3.0];
    
   
    
    //handles landscape
    int orientation = self.imageView.image.imageOrientation;
    //(@"%d",orientation);
    if(orientation ==0 || orientation ==1){
        //(@"landscape");
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;}
    
    
    
   
    if(![self.message[@"readUsers"] containsObject: currentUser.objectId]){
        NSMutableArray *readUsersArray = [NSMutableArray arrayWithArray:self.message[@"readUsers"]];
        [readUsersArray addObject:currentUser.objectId];
        [self.message  setObject:[NSArray arrayWithArray:readUsersArray]forKey:@"readUsers"];
        [self.message saveInBackground];
       
    }
    
    

}
-(void) viewWillAppear:(BOOL)animated{
    
    
    
    //who sent it?
   
    NSString *senderName = [self.message objectForKey:@"senderName"];
    NSString *caption = [self.message objectForKey:@"caption"];
    
    self.senderLabel.text=[NSString stringWithFormat:@"by %@",senderName];
    self.captionLabel.text = [NSString stringWithFormat:@" %@",caption];
    self.captionLabel.numberOfLines = 1;
    self.captionLabel.minimumFontSize =10.;
    self.captionLabel.adjustsFontSizeToFitWidth = YES;
    
   
    if([self.message[@"listOfLikers"] containsObject: [[PFUser currentUser]objectId]]){
        self.likeButton.selected = YES;
    
    }
    
}
-(IBAction)ButtonReleased:(id)sender
{
    PFUser *currentUser = [PFUser currentUser];
    self.likeButton.selected=YES;
    // Send push notification to our query
    
    //send push notification that someone liked your photo if they haven't liked it already.
    if(![self.message[@"listOfLikers"] containsObject:currentUser.username]){
   /* PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"installationUser" containsString:[self.message objectForKey:@"senderId"]];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setMessage:[NSString stringWithFormat:@"%@ liked \"%@\"", currentUser.username,[self.message objectForKey:@"caption"]]];
    
    
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error)
        {
            //(@"Push notification sent!");
        }
    }];*/
    }
    /*[self.likeButton setBackgroundImage:[UIImage imageNamed:@"ImageWhenReleased.png"] forState:UIControlStateNormal];*/
}

- (IBAction)Like:(id)sender {
    //(@"Like Button Pressed");
    
    PFUser *currentUser  =[PFUser currentUser];
    [self ButtonReleased:self];
    self.listOfLikers = [NSMutableArray array];
   // NSString *user = [self.message objectForKey:@"senderName"];
   
    //ask benji whyit keeps adding users of hte same username
    //also ask why label doesn't update instantaneously
    if(![self.message[@"listOfLikers"] containsObject: currentUser.objectId]){
        [self.message addObject:currentUser.objectId forKey:@"listOfLikers"];
        NSNumber *numberOfLikes = [self.message objectForKey:@"numberOfLikes"];
        int numlikes = [numberOfLikes intValue];
        numberOfLikes = [NSNumber numberWithInteger: numlikes+1];
        [self.message setObject:numberOfLikes forKey:@"numberOfLikes"];
        self.likeButton.selected=YES;
        [self.message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error){
                //NSLog(@"saved!");
            }
        }];
    

    }
    
   
}

- (IBAction)flagButton:(id)sender {
    //NSLog(@"flagged");
    [self.message setObject:@"FLAGGED" forKey:@"flag"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Photo Flagged As Inappropriate" message:@"We Will Review This Content Immediately" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [self.message saveInBackground];
}





@end
