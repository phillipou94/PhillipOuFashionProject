//
//  LoginViewController.m
//  Project Fashion
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import "ServerRequest.h"
#import "CurrentUser.h"
#import "AppDelegate.h"
#import "CoreDataUser.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FBLoginView *loginView = [[FBLoginView alloc] init];
    loginView.center = self.view.center;
    loginView.delegate = self;
    loginView.readPermissions = @[@"public_profile", @"user_friends", @"email"];
    [self.view addSubview:loginView];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    
    //instantiate Highlight Objects
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
        if (error) {
            // Handle error
        }
        
        else {
            ServerRequest *serverRequest = [ServerRequest sharedManager];
            User *currentUser = [serverRequest getUserInfoFromServer:[FBuser objectID]];
            if(currentUser.userID.length <1){
                NSLog(@"new user");
                currentUser.username = [FBuser name];
                currentUser.userID = [FBuser objectID];
                currentUser.followerDictionary = [@{} mutableCopy];
                currentUser.followingDictionary = [@{} mutableCopy];
                currentUser.shoppingCart = [@[] mutableCopy];
                currentUser.favoriteClothing = [@[] mutableCopy];
                currentUser.recommendedList = [@[] mutableCopy];
                currentUser.points = 0;
                [serverRequest saveNewUser:currentUser];
                CurrentUser *singleton = [CurrentUser sharedManager];
                singleton.username = [FBuser name];
                singleton.userID = [FBuser objectID];
                singleton.followerDictionary = [@{} mutableCopy];
                singleton.followingDictionary = [@{} mutableCopy];
                singleton.shoppingCart = [@[] mutableCopy];
                singleton.favoriteClothing = [@[] mutableCopy];
                singleton.recommendedList = [@[] mutableCopy];
                singleton.points = 0;
                
            }
            else{
                NSLog(@"returning user");
                currentUser.username = [FBuser name];
                currentUser.userID = [FBuser objectID];
                CurrentUser *singleton = [CurrentUser sharedManager];
                singleton.followerDictionary=currentUser.followerDictionary;
                singleton.followingDictionary=currentUser.followingDictionary;
                singleton.shoppingCart=currentUser.shoppingCart;
                singleton.favoriteClothing=currentUser.favoriteClothing;
                singleton.recommendedList=currentUser.recommendedList;
                singleton.points=currentUser.points;
                NSLog(@"got:%@",singleton.recommendedList);

            }
            
            [self saveToCoreData:currentUser];
        }
        
        
    }];
    
}

-(void)saveToCoreData:(User*) currentUser{
    NSLog(@"called?");
    NSManagedObjectContext *context = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    CoreDataUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"CoreDataUser" inManagedObjectContext:context];
    user.username = currentUser.username;
    user.userID=currentUser.userID;
    /*user.followingDictionary=[NSDictionary dictionaryWithDictionary: currentUser.followingDictionary];
   user.followerDictionary=[NSDictionary dictionaryWithDictionary:currentUser.followerDictionary];
    //user.serverID=currentUser.serverID;
    user.profilePictures = currentUser.profilePictures;
    user.recommendedList = currentUser.recommendedList;
    user.shoppingCart=currentUser.shoppingCart;
    user.favoriteClothing=currentUser.favoriteClothing;
    NSLog(@"saving to core data:%@",user.userID);
    user.points=currentUser.points;*/
    
    NSError *error = nil;
    [context save:&error];
    NSLog(@"saved:%@",user.followerDictionary);
    if(error){
        NSLog(@"unable to save");
    }
    
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}






/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
