//
//  FeedViewController.m
//  Storyboard
//
//  Created by Phillip Ou on 8/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "FeedViewController.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "ViewStoryViewController.h"
#import "Reachability.h"
#import "MapViewController.h"

@interface FeedViewController  ()
@property (strong, nonatomic) IBOutlet UILabel *usernamelabel;
@property float searchRadius;
@property (strong, nonatomic) NSMutableArray *initialArray;


@end
static PFGeoPoint *geoPoint;

//extern int searchRadius;
@implementation FeedViewController





- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //NSLog(@"This is called first");
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            
            //NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            self.selfLocation=geoPoint;
            [self.currentUser setObject:geoPoint forKey:@"currentLocation"];
            [self.currentUser saveInBackground];
        }];
        
        
       /* // This table displays items in the Todo class
        self.parseClassName = @"Messages";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES; //allows scrolling down to load more pages*/
        
       
    }
    
    return self;
}
//receive data from Settings View Controller (delegate called MyDataDelegate)
- (void)recieveData:(float)searchRadius {
    //NSLog(@"SEARCH RADIUS: %.01f",self.searchRadius);
    self.searchRadius = searchRadius;
    
    //Do something with data here
}
-(void) receivePreference: (NSInteger) indexNum{
   // NSLog(@"%d",indexNum);
    self.preferenceIndex = indexNum;
}

-(void)receiveDataFromMap: (float)searchRadius{
   // NSLog(@"%f",searchRadius);
    self.searchRadius = searchRadius;
}
- (void)viewDidLoad
{
    
    self.objectsPerPage=100;
   /* self.discoverButton.layer.borderWidth=1.0f;
    self.discoverButton.layer.borderColor=[[UIColor blackColor] CGColor];*/
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:45/255.0 green:67/255.0  blue:101/255.0  alpha:1]]; //45,67,101
    //[[UITabBar appearance] setBarTintColor:[UIColor yellowColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIFont fontWithName:@"AvenirNext-Regular" size:22.0], NSFontAttributeName, nil]];
    
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"    "
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    
   
    
        self.searchRadius =1.0;

    self.currentUser=[PFUser currentUser];
    self.usernamelabel.text = self.currentUser.username;
    self.tabBarController.tabBar.hidden=NO;
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        //NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
        self.selfLocation=geoPoint;
        [self.currentUser setObject:geoPoint forKey:@"currentLocation"];
        [self.currentUser saveInBackground];
        
    }];
    [super viewDidLoad];
    
    self.preferenceIndex=[self.currentUser[@"preferencesIndex"] intValue];
    
    self.messagesNear=[[NSMutableArray alloc]init];
    

    
}
- (IBAction)segmentChanged:(id)sender {
    
   
    //Refresh Objects in TableView
    
    [self loadObjects];
}

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden=NO;
    if(self.objects.count==0){
        
    }
    
    if (![self connected]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"There is no network connection" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        // connected, do some internet stuff
    }
   
   
}

- (BOOL)connected{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CLLocationManager *)locationManager {
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDelegate:self];
    // [_locationManager setPurpose:@"Your current location is used to demonstrate PFGeoPoint and Geo Queries."];
    
    return self.locationManager;
}




-(PFQuery*)queryForTable{
   // NSLog(@"search radius: %f",self.searchRadius);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    
    if(self.selfLocation!=nil){
        //NSLog(@"%d",self.segmentControl.selectedSegmentIndex);
        switch (self.segmentControl.selectedSegmentIndex) {
        //NSLog(@"searching");
            case 0:
                [query whereKey:@"location" nearGeoPoint:self.selfLocation withinMiles:self.searchRadius];
                [query orderByDescending:@"createdAt"];
                //NSLog(@"%@",self.messagesNear);
                query.limit=100;
               // return query;
                break;
            case 1:
                [query whereKey:@"location" nearGeoPoint:self.selfLocation withinMiles:self.searchRadius];
                [query orderByDescending:@"numberOfLikes"];
                [query addDescendingOrder:@"createdAt"];
                //[query orderByDescending:@"createdAt"];
                //NSLog(@"%@",self.messagesNear);
                query.limit=100;
                //return query;
                
                break;
            case 2:
                
                    [query whereKey:@"whoTookId" equalTo:[[PFUser currentUser] objectId]];
                
                
                
                if(self.preferenceIndex==0){
                    [query orderByDescending:@"createdAt"];
                }
                else{
                    [query orderByDescending:@"numberOfLikes"];
                }
        
                query.limit=100;
               // return query;
                break;
            
        }
    
    }
    else{
       
        [query orderByDescending:@"createdAt"];
      
        //NSLog(@"called!!");
        query.limit=250;
    }
 
    
    return query;
}


- (IBAction)discoverButton:(id)sender {
    //get user location
    //NSLog(@"button Pressed");
    self.loadCount++;
    
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
            //NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
        self.selfLocation=geoPoint;
            [self.currentUser setObject:geoPoint forKey:@"currentLocation"];
            [self.currentUser saveInBackground];
        
    }];
    
    [self loadObjects];
    
    //prevents user from spamming discover button
    //disables it for 4 seconds
    [self.discoverButton setEnabled:NO];
    [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(setButtonEnabled) userInfo:nil repeats:NO];
    
 
    
   
}

-(void)setButtonEnabled{
    [self.discoverButton setEnabled:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    //return self.sections.allKeys.count;
    return 1;
    
}
static int newLoadCount;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.objects count]!=0 && newLoadCount<1){
        self.initialArray = [NSMutableArray arrayWithArray:self.objects];
        newLoadCount++;
    }
     
   
    return [self.objects count];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
     PFObject *message= self.objects[indexPath.row];
    if(self.segmentControl.selectedSegmentIndex==2){
        [message deleteInBackground];
        [self loadObjects];
        NSLog(@"deleted");
    }
    else{
    [message setObject:@"FLAGGED" forKey:@"Flag"];
   
    NSLog(@"flagged");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Story Flagged As Inappropriate" message:@"We Will Review This Content Immediately" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    
    [message saveInBackground];
    }
    //[self loadObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.hidden = YES;
    if(self.loadCount!=0){
        
        cell.hidden=NO;
    }
  
    PFObject *message= self.objects[indexPath.row];
    
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:3];
    
    
    titleLabel.text= message[@"title"];
    titleLabel.adjustsFontSizeToFitWidth=YES;
    
    
    nameLabel.text = message[@"whoTookName"];
    
   
    nameLabel.adjustsFontSizeToFitWidth=YES;
    
    
    UILabel *dateLabel = (UILabel*) [cell viewWithTag:4];
    UILabel *likeLabel = (UILabel*)[cell viewWithTag:5];
    
    
    
    
    
    NSNumber *numLikes = message[@"numberOfLikes"];
    likeLabel.text = [NSString stringWithFormat:@"%@",numLikes];
    if(numLikes==nil){
        likeLabel.text = @"0";
    }
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
    
    
    
    
    return cell;
}

-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"%d",indexPath.row);
    self.selectedMessage= self.objects[indexPath.row];
    //NSLog(@"%@",self.selectedMessage.objectId);
    [self performSegueWithIdentifier:@"transition" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"transition"]){
        ViewStoryViewController *viewController = [segue destinationViewController];
        //WritingViewController *viewController = [[WritingViewController alloc]init];
       
        viewController.selectedMessage = self.selectedMessage;
           }
     if([segue.identifier isEqualToString:@"settingsTransition"]){
        //NSLog(@"called");
        SettingsViewController *other = segue.destinationViewController;
        
        other.searchRadius = self.searchRadius;
        
        //allows access to delegate from freeviewcontroller
        if ([other isKindOfClass:[SettingsViewController class]]) {
            other.delegate = self;
            other.preferenceDelegate=self;
            
        }
       
        
    }
     if([segue.identifier isEqualToString:@"mapTransition"]){
         MapViewController *map =[segue destinationViewController];
         map.objects = self.initialArray;
         map.userLocation = self.selfLocation;
         map.searchRadius=self.searchRadius;
         map.delegate =self;
     }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.segmentControl.selectedSegmentIndex==2){
        return @"Remove";
    }
    else{
        return @"  Flag  ";}
}






@end
