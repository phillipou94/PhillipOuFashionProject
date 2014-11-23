//
//  ProfileTableViewController.m
//  Storyview
//
//  Created by Phillip Ou on 8/10/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "ViewStoryViewController.h"


@interface ProfileTableViewController ()

@end

@implementation ProfileTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.currentUser = [PFUser currentUser];
        // Custom initialization
    }
    return self;
}
-(void) viewWillAppear:(BOOL)animated{
    
    self.tabBarController.tabBar.hidden = NO;
    self.currentUser = [PFUser currentUser];
    //NSLog(@"%@",self.currentUser.objectId);
    [super viewWillAppear:animated];
    NSLog(@"%@",self.currentUser.objectId);
   /* if (![self connected]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"There is no network connection" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        // connected, do some internet stuff
    }*/
    
}

- (void)viewDidLoad
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tabBarController.tabBar.hidden = NO;
    
    [super viewDidLoad];
    
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"back"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
  }
-(void) viewDidAppear:(BOOL)animated{
    
    
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(PFQuery*)queryForTable{
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    // Interested in locations near user.
    
    if(self.loadCount==0){
        NSLog(@"this is being called by query");
        [query whereKey:@"whoTookId" containsString:@"whotookiddddd"];
        query.limit=0;
        self.loadCount++;
        return query;
    }
    else{
        self.loadCount++;
        //NSLog(@"searching");
        [query whereKey:@"whoTookId" containsString: self.currentUser.objectId];
        [query orderByDescending:@"createdAt"];
        query.limit=20;
        self.showStoryButton.hidden=YES;
        self.showStoryIcon.hidden=YES;
        
        return query;}
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
    return [self.objects count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.hidden = YES;
    if(self.loadCount!=0){
        cell.hidden=NO;
    }
    
    UILabel *titleLabel = (UILabel*) [cell viewWithTag:3];
    
    
    PFObject *message= self.objects[indexPath.row];
    titleLabel.text = message[@"title"];
    if([message[@"title"] length]==0){
        titleLabel.text = @"Untitled";
    }
    titleLabel.adjustsFontSizeToFitWidth=YES;
    
    
    
    
    UILabel *dateLabel = (UILabel*) [cell viewWithTag:2];
    
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM/dd 'at' HH mm" options:0 locale:nil];
    
    [formatter setDateFormat:dateFormat];
    
    dateLabel.text= [formatter stringFromDate:message.createdAt];
    
    
    
    PFImageView *photo = (PFImageView *)[cell viewWithTag:1];
    
    photo.file = [message objectForKey:@"file"]; //save photo.file in key image
    //handles landscape
    int orientation = photo.image.imageOrientation;
    if(orientation ==0 || orientation ==1){
        photo.contentMode = UIViewContentModeScaleAspectFit;}
    [photo loadInBackground];
    
    
    cell.selected=NO;
    
    return cell;
}

-(void) tableView: (UITableViewCell *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"%d",indexPath.row);
    self.selectedMessage= self.objects[indexPath.row];
    [self performSegueWithIdentifier:@"fromProfile" sender:self];
    
    
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //NSLog(@"deleting");
        PFObject *objectToDelete = self.objects[indexPath.row];
        
        [objectToDelete deleteInBackground];
        [self loadObjects];
        
        //add code here for when you hit delete
        
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"fromProfile"]){
        ViewStoryViewController *viewController = [segue destinationViewController];
        //WritingViewController *viewController = [[WritingViewController alloc]init];
        
        viewController.selectedMessage = self.selectedMessage;
    }
    
}



- (IBAction)showStories:(id)sender {
    [self loadObjects];
}


@end
