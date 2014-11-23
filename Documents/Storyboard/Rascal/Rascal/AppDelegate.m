//
//  AppDelegate.m
//  Rascal
//
//  Created by Phillip Ou on 6/28/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"
#import "ParseLoginViewController.h"
#import "TutorialViewController.h"

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [Parse setApplicationId:@"yKPQyCref89CL3WLX8umBba2YEqanTcuNVVTQ8GA"
                  clientKey:@"CHT2hRkuerq5JOId4DpgvdEVYrgaDmYV68AlVri9"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    /*[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];*/
    
    //for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
  
    
    
    self.window.autoresizesSubviews=YES;
    //self.window.backgroundColor=[UIColor blueColor];
   
    [self.window makeKeyAndVisible];
    
    
    // !!!!!
    if (![FBSession defaultAppID]) {
        [FBSession setDefaultAppID:@"773713522660443"];
        [PFFacebookUtils initializeFacebook];
    }
   /*
    [PFFacebookUtils initializeFacebook];
    if(![PFUser currentUser] && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){  //if user not logged in, show logincontroller
        
        [self presentLoginControllerAnimated: NO];
    }*/
    if(![PFUser currentUser] && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        [self presentLoginControllerAnimated:NO];
        return YES;
    }
    [PFFacebookUtils initializeFacebook];
    
    
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    //PFInstallation *currentInstallation = [PFInstallation currentInstallation];
   /* if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }*/
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        //save the installation
        //(@"calling this now!!");
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        //get current user id
        currentInstallation[@"installationUser"] = [[PFUser currentUser]objectId];
        // here we add a column to the installation table and store the current user’s ID
        // this way we can target specific users later
        
        // while we’re at it, this is a good place to reset our app’s badge count
        // you have to do this locally as well as on the parse server by updating
        // the PFInstallation object
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0;
            [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    // Handle error here with an alert…
                }
                else {
                    // only update locally if the remote update succeeded so they always match
                    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                    //(@"updated badge");
                }
            }];
        }
    } else {
        
        [PFUser logOut];
        // show the signup screen here....
    }
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //NSLog(@"%@",userInfo);
    [PFPush handlePush:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTheTable" object:nil];
    [UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    //[UIApplication sharedApplication].applicationIconBadgeNumber=10;
}



- (void)presentLoginControllerAnimated:(BOOL)animated {
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //UINavigationController *loginNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"loginNav"];
    //[self.window.rootViewController presentViewController:loginNavigationController animated:animated completion:nil];
    ParseLoginViewController *loginViewController = [[ParseLoginViewController alloc] init];
    loginViewController.delegate = self;
    
    //[loginViewController setFields:PFLogInFieldsDefault]; //this is for testing
    
    [loginViewController setFields:PFLogInFieldsFacebook];
    
    [self.window.rootViewController presentViewController:loginViewController animated:animated completion:nil];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}



- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (!error) {
            UIAlertView *EULA = [[UIAlertView alloc] initWithTitle:@"By Using This App You Agree to:" message:@"1. Not posting nude partially nude, or sexually suggestive photos. \n 2. Be responsible for any activity that occurs under your screen name. \n 3. Not abuse harass, threaten, or intimidate other users. \n 4. Not use Rascal for any illegal or unauthorized purpose \n 5. Be responsible for any data, text, information, graphics, photos, profiles that you submit, post and display to users on Rascal. \n Photos that violate these terms will be banned from the app along with the users who post them."
                                                          delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil];
            [EULA show];
            PFUser *currentUser = [PFUser currentUser];
            // handle result
            if(![currentUser[@"newUser"] isEqualToString:@"No"]){
                //(@"New User");
                [currentUser setObject:@"No" forKey:@"newUser"];
                
                [currentUser setObject:[NSNumber numberWithInt:20] forKey:@"Points"];
            //(@"calling this from app delegate!!");
            PFObject *bountyNotice = [PFObject objectWithClassName:@"Messages"];
            [bountyNotice setObject:@"bountyNotice" forKey:@"fileType"];
            //[bountyNotice setACL: readAccess2];
            [bountyNotice setObject:@"placeholder" forKey:@"placeholder"];
            [bountyNotice setObject:@[currentUser.objectId] forKey:@"recipientIds"];//notification goes to all friends
            [bountyNotice setObject:@"Innocent Bystander" forKey:@"recipientUsername"];
            [bountyNotice setObject:@"Anonymous" forKey:@"senderName"];
            [bountyNotice setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [bountyNotice setObject:[[PFUser currentUser] objectId] forKey:@"victimId"];
            [bountyNotice setObject:[NSNumber numberWithInt:0] forKey:@"bountyValue"];
            [bountyNotice setObject: @"A" forKey:@"payForId"];
             //add anonymous to friendsList (list of friends ids);
            
            [bountyNotice saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    //(@"saving array");
                    [currentUser setObject:@[currentUser.objectId] forKey:@"friendsList"]; //add yourself to frends list so you can see yourself as victim Id. also for innocent bystander
                    [currentUser saveInBackground];
                    
                 
                    
                    
                 
                   
                }
            }];
            
                
           
           
            
            }
            [self facebookRequestDidLoad:result];
        }
        else {
            [self showErrorAndLogout];
        }
    }];
}



- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    // show error and log out
    [self showErrorAndLogout];
}

- (void)showErrorAndLogout {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login failed" message:@"It appears you do not have a network connection. Please Try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [PFUser logOut];
}

- (void)facebookRequestDidLoad:(id)result {
    PFUser *user = [PFUser currentUser];
    if (user) {
        // update current user with facebook name and id
        ////(@"YOLO");
        NSString *facebookName = result[@"name"];
        user.username = facebookName;
        NSString *facebookId = result[@"id"];
        user[@"facebookId"]=facebookId;
        //user[@"userObject"]=user;
        
        // download user profile picture from facebook
        NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square",facebookId]];
        NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL];
        [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self showErrorAndLogout];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _profilePictureData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.profilePictureData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (self.profilePictureData.length == 0 || !self.profilePictureData) {
        [self showErrorAndLogout];
    }
    else {
        PFFile *profilePictureFile = [PFFile fileWithData:self.profilePictureData];
        [profilePictureFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (!succeeded) {
                [self showErrorAndLogout];
            }
            else {
                PFUser *user = [PFUser currentUser];
                user[@"profilePicture"] = profilePictureFile;
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!succeeded) {
                        [self showErrorAndLogout];
                    }
                    else {
                        [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
                        
                        
                    }
                }];
            }
        }];
    }
}





























@end
