//
//  InboxViewController.m
//  Rascal
//
//  Created by Phillip Ou on 7/9/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//


#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "InboxViewController.h"
#import "ImageViewController.h"
#import "CameraViewController.h"
#import "HomeViewController.h"


@interface InboxViewController ()

@end


@implementation InboxViewController



-(id) initWithCoder:(NSCoder *)aCoder{
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        self.parseClassName = @"Messages";
        
        
        // Whether the built-in pull-to-refresh is enabled
       self.pullToRefreshEnabled = YES;
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        self.objectsPerPage = 50;
        
        // The number of objects to show per page
        
    }
    ////(@"%@",self.objects);
    return self;
}
-(void) objectsDidLoad: (NSError *)error{
    //(@"objects did load");
    [super objectsDidLoad: error];
    if(![PFUser currentUser] && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        //(@"ByPass");
    }
    else{
        
        
       
    //(@"call1");
        
        //PFUser *currentUser = [PFUser currentUser];
        
        
        //(@"%@",[self.currentUser objectForKey:@"friendsList"]);
        

        
       [self.sections removeAllObjects];
       [self.sectionFileType removeAllObjects];
    
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    
    for (PFObject *object in self.objects){
        // //(@"%@",self.sections);
        NSString *fileType = [object objectForKey:@"fileType"];
        
        NSMutableArray *objectsInSection = [self.sections objectForKey: fileType];
        
        //(@"sections:%@",self.sections);
        
        
        
        //all objects of a particular file type go in that section ^
        
        if (!objectsInSection){
            objectsInSection = [NSMutableArray array];
            //this is the first time we see this sportType
            
            //increment section index
            [self.sectionFileType setObject:fileType forKey: [NSNumber numberWithInt: section++]]; //{0 : fileType, 1: fileType}
            
            // //(@"%@", [self.sectionFileType objectForKey:0]);
            //check which sports type belongs to section 0
            //use section number to get
        }
        
        
        [objectsInSection addObject: [NSNumber numberWithInt: rowIndex++]]; //[0,1,2];
        ////(@"filetypeeee:%@",objectsInSection);
        [self.sections setObject: objectsInSection forKey:fileType];
        
        ////(@"%@",self.sections);
        //{fileType:[0,1,2], fileType:[0,1]} <--row
        
    }
        PFRelation *relation = [self.currentUser relationforKey:@"friendsRelation"];
        self.allFriends = [[NSArray alloc]init];
        
        [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //(@"relation query!");
            self.allFriends = objects;
        }];
    
    ////(@"%@",self.sections);
}
    
    

   
}
- (BOOL)connected{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}
#pragma mark - header font
- (void)viewDidLoad
{
    
    
    //NSLog(@"%@",self.currentUser.username);
    self.bountyButton.selected=NO;
    
    self.currentUser=[PFUser currentUser];
    NSString *profilePictureID = [self.currentUser objectForKeyedSubscript:@"facebookId"];
    NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",profilePictureID];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    
    //[self.tableView reloadData];
    //PFUser *currentUser = [PFUser currentUser];
    /*PFFile *profilePicture = [currentUser objectForKey:@"profilePicture"];*/
    
    
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = 20;
    
    //self.profileImageView.file = profilePicture;
    //[self.profileImageView loadInBackground];
    
    self.profileImageView.image= image;
    
    
    self.userNameLabel.adjustsFontSizeToFitWidth=YES;
    
    self.userNameLabel.text = self.currentUser.username;
    
    
    self.marquee =[UIImage imageNamed:@"image-big"];
   
    self.unseenPhotoImage = [UIImage imageNamed:@"colorImage"];
    
    
    self.currentUser = [PFUser currentUser];
    self.bountyUserLogo = [UIImage imageNamed:@"user-3-big"];
    
    
   

    
    [UIButton buttonWithType: UIButtonTypeCustom];
    //[photoUnread setBackgroundImage:icon forState:UIControlStateNormal];
    //photoUnread.backgroundColor = [UIColor clearColor];
    
    
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:@"reloadTheTable" object:nil];

    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"     "
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    //(@"viewdidload is happening");
   
    //(@"state:%@",self.currentUser[@"newUser"]);
    if(![self.currentUser[@"newUser"] isEqualToString:@"No"]){
               [self.tabBarController setSelectedIndex:6];
        [self.currentUser setObject:@"No" forKey:@"newUser"];
        [self.currentUser saveInBackground];
    }
   
    

    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIFont fontWithName:@"Raleway-Thin" size:25.0], NSFontAttributeName, nil]];
    
    self.sectionFileType = [[NSMutableDictionary alloc] init];
    self.sections = [[NSMutableDictionary alloc]init];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    
    [self.tableView insertRowsAtIndexPaths: 0 withRowAnimation:NO];
    
    
    self.tabBarController.tabBar.hidden = YES; //!!!this hides the tab bar!!!


    
        [super viewDidLoad];
    
}

- (void)reloadTable:(NSNotification *)notification
{
    [self loadObjects];
    //(@"refresh!");
}
-(void) viewWillAppear:(BOOL)animated{
    //NSLog(@"view will appear");
    
    self.currentUser = [PFUser currentUser];
  
    
    self.bountyButton.selected=NO;
    
    NSString *profilePictureID = [self.currentUser objectForKeyedSubscript:@"facebookId"];
    NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",profilePictureID];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    
   
    
    
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = 20;
   
    
    self.profileImageView.image= image;
    
    
    self.userNameLabel.adjustsFontSizeToFitWidth=YES;
    
    self.userNameLabel.text = self.currentUser.username;


    
   
    

    
    
    
    self.pointsLabel.text = [NSString stringWithFormat:@"Credits: %@", self.currentUser[@"Points"]];
    
    if (![self connected]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"There is no network connection" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        // connected, do some internet stuff
    }
    
    
    [super viewWillAppear:animated];
    
    [self loadObjects];
    //[self.tableView reloadData];

}



- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
   
    
    NSString *fileType = [self fileTypeForSection:indexPath.section];
    ////(@"files:%@",fileType);
    
    NSArray *rowIndecesInSection = [self.sections objectForKey:fileType];
    
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    return [self.objects objectAtIndex:[rowIndex intValue]];
}
//load up messages sent to you

- (PFQuery *)queryForTable {
   // NSLog(@"querying!");
  
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
   
  
        if(self.currentUser !=nil){
            NSArray *array = [self.currentUser objectForKey:@"friendsList"];
            self.friendsList=[NSMutableArray arrayWithArray:array];
        [query whereKey:@"recipientIds" containsAllObjectsInArray:@[self.currentUser.objectId]];
        [query whereKey:@"fileType" containedIn:@[@"image",@"bountyNotice"]];
        //comment out below to allow strangers to send photos
        //[query whereKey:@"senderId" containedIn:self.friendsList];
        
        
        [query orderByAscending:@"fileType"];
        [query addDescendingOrder:@"createdAt"];
        
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
   
   
  
    }
        else{
            [query whereKey:@"fileType" containedIn:@[@"AAAAA"]];
        }
    
    return query;
}

-(NSString *) fileTypeForSection: (NSInteger) section{
    
    return [self.sectionFileType objectForKey: [NSNumber numberWithInt: section]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    //return self.sections.allKeys.count;
    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSString *fileType = [self fileTypeForSection:section];
    ////(@"section:%d",section);
    NSArray *rowIndecesInSection = [self.sections objectForKey:fileType];
    // Return the number of rows in the section.
    ////(@"using %@:",rowIndecesInSection);
   
    return rowIndecesInSection.count; //this is some times too much
    
}

-(NSString *)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *fileType = [self fileTypeForSection:section];
   
    if([fileType isEqualToString:@"bountyNotice"]){
        return @"Active Bounties";
    }
    
    else{
        return @"Photos";
    }
    //return fileType;
}
static int rowNumber;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    //[self loadObjects];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
  
    
    self.bountyLogo = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 16, 16)];
    
    self.icon2 = [UIImage imageNamed:@"camera-2"];
    
  
    
    self.bountyLogo.backgroundColor = [UIColor clearColor];
    [self.bountyLogo setBackgroundImage:self.icon2 forState:UIControlStateNormal];
    
    
    
    
    
    cell.textLabel.adjustsFontSizeToFitWidth=YES;
    
    cell.accessoryType=UITableViewCellAccessoryNone;
    
    
    
    
    if (indexPath.section == self.objects.count) { //if we're at the end (the last section)
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath]; //get that cell(LoadMoreCell)
        return cell;
    }
    
  
    rowNumber = 0;
  
    
    
    for (NSInteger i = 0; i < indexPath.section; i++) {
        rowNumber += [self tableView:tableView numberOfRowsInSection:i];
        
    }
    rowNumber += indexPath.row;
    
    
    if(self.objects==nil){
        //(@"waiting!!!!!");
        //[self loadObjects];
    }
    
    
    
   
    @try{
        PFObject *message = [self.objects objectAtIndex:rowNumber];
        
    
    
        cell.accessoryType =UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Raleway-Medium" size:14]];
     NSString *fileType = [message objectForKey:@"fileType"];
        //(@"%@",fileType);
    
    if([fileType isEqualToString:@"bountyNotice"]){
        
        
        //if([listOfRecipients containsObject:currentUser.objectId]){
        cell.imageView.image =self.bountyUserLogo;
        cell.accessoryView=self.bountyLogo;
        
        cell.textLabel.text = [[NSString stringWithFormat:@"%@", [message objectForKey:@"recipientUsername"]] lowercaseString];
        }
    
     //if message is an image
     if ([fileType isEqualToString:@"image"]) {
         
        
         
         cell.textLabel.text= [NSString stringWithFormat:@"%@ ",[[message objectForKey:@"senderName"]lowercaseString]];
         cell.accessoryView=nil;
         cell.imageView.image = self.unseenPhotoImage;
         
         
         //for read messages

        
         if([[message objectForKey:@"readUsers"] containsObject:self.currentUser.objectId]){
             UIImage *marquee =self.marquee;
             
             
             
             cell.imageView.image =marquee;
             
         }
        
     }
    else{
        cell.accessoryType =UITableViewCellAccessoryNone;
         }
    
     
    
    

        
    
   
    }
    
    @catch(NSException *exception){
        //NSLog(@"caught error");
        [self loadObjects];
    }
    @finally {
        //(@"Cleaning up");
        
    }
    
    
        return cell;




}

//allows right swiping

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    //prevents you from deleting last row of sections array
    //innocent by standers
    NSMutableArray *bountyNoticeArray =[self.sections objectForKey:@"bountyNotice"];
    if(indexPath.section==0){
    if(indexPath.row==[bountyNoticeArray count]-1){
        return NO;}}
    return YES;     }

#pragma mark end
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  
    
    
        
    //add code here for when you hit delete
    //(@"Delete");
        NSInteger rowNumber = 0;
        
        for (NSInteger i = 0; i < indexPath.section; i++) {
            rowNumber += [self tableView:tableView numberOfRowsInSection:i];
        }
        
        rowNumber += indexPath.row;
    self.selectedMessage = [self.objects objectAtIndex:rowNumber];
        NSString *fileType = self.selectedMessage[@"fileType"];
    
   /* if([fileType isEqualToString:@"image"]){
        NSLog(@"IMAGE");
        [self.selectedMessage deleteInBackground];
        
        [self loadObjects];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You've Flagged This As Inappropriate"
                                                            message:@"Photo Has Been Deleted off the Server"
                                                           delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
        [alertView show];
        
    }
    else{*/
       
       //delete form sections
        NSArray *updateArray =[self.sections objectForKey:fileType];
        NSMutableArray *newArray = [NSMutableArray arrayWithArray:updateArray];
        [newArray removeObjectAtIndex:indexPath.row];
       
        [self.sections removeObjectForKey:fileType];
        [self.sections setObject:newArray forKey:fileType];
        
        
        
       
        //(@"New Dict: %@", self.sections);
       
        NSMutableArray *deleteArray = [NSMutableArray arrayWithArray:self.selectedMessage[@"recipientIds"]] ;
        

        [deleteArray removeObject:self.currentUser.objectId];
        ////(@"RecipientIds:%@",deleteArray);
        NSArray *arrayUpdate = [NSArray arrayWithArray:deleteArray];
       
        [self.selectedMessage setObject:arrayUpdate forKey:@"recipientIds"];
        [self.selectedMessage saveInBackground]; //ensures array gets updated before there is index error after delete
        
      
        //[self queryForTable];0
        [self loadObjects]; // life saver. updates after change in query
    
    
    //animate disappearing cell
  
    
    
        
        
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger rowNumber = 0;
    
   // self.count = [NSNumber numberWithInt:0];
    
    for (NSInteger i = 0; i < indexPath.section; i++) {
        rowNumber += [self tableView:tableView numberOfRowsInSection:i];
    }
    
    rowNumber += indexPath.row;
    self.selectedMessage = [self.objects objectAtIndex:rowNumber];
   
    
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];
    
    if([fileType isEqualToString:@"image"]) {
       
        
         [self performSegueWithIdentifier:@"showImage" sender:self];
    }
  
     
    if([fileType isEqualToString:@"bountyNotice"]){
            //(@"show camera");
        /*NSString *bountyMessage = [NSString stringWithFormat:@"Bounty set by %@", self.selectedMessage[@"senderName"]];*/

        if([self.selectedMessage[@"placeholder"] isEqualToString:@"placeholder"]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bounty Set by a Higher Power"
                                                                message:@"Be Responsible"
                                                               delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
            [alertView show];
            //[self performSegueWithIdentifier:@"transferBountyData" sender:self];

        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Complete This Bounty"
                                                                message:@"You Will Be Rewarded 1 Credit"
                                                               delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
            [alertView show];
            
            

        }
        [self performSegueWithIdentifier:@"transferBountyData" sender:self];
        
    
        
        
        
        
        
        
        
        
    }
}


 
    // Delete it!
    /*NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];
    //(@"Recipients: %@", recipientIds);
    
    if ([recipientIds count] == 1) {
        // Last recipient - delete!
     
    }
    else {
        // Remove the recipient and save
        [recipientIds removeObject:[[PFUser currentUser] objectId]];
        [self.selectedMessage setObject:recipientIds forKey:@"recipientIds"];
        [self.selectedMessage saveInBackground];
    }*/

//Customize header view section


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /// Create custom view to display section header...
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    
   
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    //NSString *string =[self.messages objectAtIndex:section];
    if (section==0 ){
        NSString *string = @"active bounties";
        [label setText:string];
        [label setTextColor: [UIColor whiteColor] ];
        
        [label setFont:[UIFont fontWithName:@"Raleway-Medium" size:15]];
        [view addSubview:label];
        [view setAlpha: 0.9];
        [view setBackgroundColor:[UIColor colorWithRed:41.0/255.0 green:166.0/255.0 blue:121.0/255.0 alpha:1.0]]; //your background color...
            return view;}

    else{
        NSString  *string = @"completed bounties";
        [label setText:string];
        [label setTextColor: [UIColor whiteColor] ];
        [label setFont:[UIFont fontWithName:@"Raleway-Medium" size:15]];
        [view addSubview:label];
        [view setAlpha: 0.9];
        [view setBackgroundColor:[UIColor colorWithRed:51/255.0 green:70/255.0 blue:192/255.0 alpha:1.0]]; //your background color...
        
        
        
        return view;

        }
    // Section header is in 0th index...
   }

//heights of section headers
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   
    return 30.f;
}





- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"transferBountyData"]){
            //(@"Passing to Camera");
            [segue.destinationViewController setHidesBottomBarWhenPushed:NO];
            CameraViewController *cameraViewController = (CameraViewController *)segue.destinationViewController;
            cameraViewController.message = self.selectedMessage;
           
            
        }
    else {
        [segue.destinationViewController setHidesBottomBarWhenPushed:NO];
        ImageViewController *imageViewController = (ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.selectedMessage;
    }
    //passing variables to cameraViewController (sender & recipient of bounties)

}

- (IBAction)setBounties:(id)sender {
  
    
    [self.tabBarController setSelectedIndex:5];
}

- (IBAction)profileButton:(id)sender {
    UIView * fromView = self.tabBarController.selectedViewController.view;
    UIView * toView = [[self.tabBarController.viewControllers objectAtIndex:3] view];
    
    // Transition using a page curl.
    
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:^(BOOL finished) {
                        if (finished) {
                            self.tabBarController.selectedIndex = 3;
                        }
                    }];

    
    //[self.tabBarController setSelectedIndex:3];
    
}

- (IBAction)topButton:(id)sender {
    // Get views. controllerIndex is passed in as the controller we want to go to.
    UIView * fromView = self.tabBarController.selectedViewController.view;
    UIView * toView = [[self.tabBarController.viewControllers objectAtIndex:1] view];
    
    // Transition using a page curl.
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:^(BOOL finished) {
                        if (finished) {
                            self.tabBarController.selectedIndex = 1;
                        }
                    }];
   
    //[self.tabBarController setSelectedIndex:1];
}


- (IBAction)editFriends:(id)sender {
    
   
   
     [self.tabBarController setSelectedIndex:4];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNumber = 0;
    
    for (NSInteger i = 0; i < indexPath.section; i++) {
        rowNumber += [self tableView:tableView numberOfRowsInSection:i];
    }
    
    rowNumber += indexPath.row;
    self.selectedMessage = [self.objects objectAtIndex:rowNumber];
    NSString *fileType = self.selectedMessage[@"fileType"];
    
    if([fileType isEqualToString:@"image"]){
    
        return @"Remove";}
    else{
        return @"Refuse";
    }
    
}

@end

