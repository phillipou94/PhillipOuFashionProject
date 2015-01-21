//
//  ServerRequest.m
//  Project Fashion
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "ServerRequest.h"
#import <Parse/Parse.h>
#import "CoreDataSingleton.h"
#import "CoreDataUser.h"

@implementation ServerRequest
+ (id)sharedManager {
    static ServerRequest *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

#pragma mark -saving new user
-(void) saveNewUser:(User*) currentUser{
    NSLog(@"saving new: %@",currentUser.username);
    NSMutableDictionary *user = [NSMutableDictionary new];
    [user setObject:currentUser.userID forKey:@"userID"];
    [user setObject:currentUser.username forKey:@"username"];
    [user setObject:@{} forKey:@"followersDictionary"]; //{ID: username}
    [user setObject:@{} forKey:@"followingDictionary"];
    [user setObject:@"0" forKey:@"points"]; //can only post strings to JSON
    [user setObject:@[] forKey:@"recommendedList"];
    [user setObject:@[] forKey:@"favoriteClothing"];
    [user setObject:@[] forKey:@"shoppingCart"];
    [user setObject:@[] forKey:@"profilePictures"];
    [user setObject:@[] forKey:@"profilePictureID"];
    [user setObject:[NSString stringWithFormat:@"%@",[NSDate date] ] forKey:@"dateCreated"];
    NSURL *url = [NSURL URLWithString: @"http://fashapp.herokuapp.com/users"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:user options:kNilOptions error:&error];
    if(!error){
        NSURLSessionUploadTask *uploadTask = [urlSession uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSLog(@"save successful");
            
            
        }];
        [uploadTask resume];
        
    }
    
}


-(User*) getUserInfoFromServer:(NSString*)userID{
    __block User *user = [[User alloc]init];
    
    //create semaphore that fetches user information from server and then returns user object
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://fashapp.herokuapp.com/users/%@",userID]];
    NSLog(@"searching for:%@",userID);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        if(responseStatusCode==200 &&data){
            NSArray *downloadedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //list of dictionaries
           
            for(NSDictionary *dic in downloadedJSON){
                
                user.followerDictionary = [dic objectForKey:@"followersDictionary"];
                user.followingDictionary = [dic objectForKey:@"followingDictionary"];
                user.shoppingCart = [dic objectForKey:@"shoppingCart"];
                user.favoriteClothing = [dic objectForKey:@"favoriteClothing"];
                user.recommendedList = [dic objectForKey:@"recommendedList"];
                user.points = [[dic objectForKey:@"points"]intValue];
                user.serverID = [dic objectForKey:@"_id"];
                user.userID = userID;
                user.username = [dic objectForKey:@"username"];
                user.profilePictures = [dic objectForKey:@"profilePictures"];
                user.profilePictureID = [dic objectForKey:@"profilePictureID"][0];
                
            }
        }
        //signal you're done with fetching user information
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    //wait for signal that completion block retrieving user info is finished before continuing
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return user;

}

-(NSArray*) getAllUsers{
    //__block User *user = [[User alloc]init];
    
    //create semaphore that fetches user information from server and then returns user object
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://fashapp.herokuapp.com/users"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
     __block NSMutableArray *array = [[NSMutableArray alloc]init];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        if(responseStatusCode==200 &&data){
            NSArray *downloadedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //list of dictionaries
           
           
            for(NSDictionary *dic in downloadedJSON){
                [array addObject:dic];
               
            }
        }
        //signal you're done with fetching user information
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    //wait for signal that completion block retrieving user info is finished before continuing
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return [NSArray arrayWithArray:array];
    
}


-(void)saveLikedItem:(NSDictionary *)item forUser:(NSString*)userID{
   
    NSMutableDictionary *mutableItem = [item mutableCopy];
    [mutableItem setObject:userID forKey:@"likedBy"];
    item = [NSDictionary dictionaryWithDictionary:mutableItem];
    NSURL *url = [NSURL URLWithString: @"http://fashapp.herokuapp.com/items"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject: item options:kNilOptions error:&error];
    if(!error){
        NSURLSessionUploadTask *uploadTask = [urlSession uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSLog(@"save successful");
            
            
        }];
        [uploadTask resume];
        
    }

    
}

-(NSMutableArray*)getItemsFor:(NSString*)userID{
    
    __block NSMutableArray *arrayOfItems= [[NSMutableArray alloc]init];
    
    //create semaphore that fetches user information from server and then returns user object
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://fashapp.herokuapp.com/items/%@",userID ]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        if(responseStatusCode==200 &&data){
            NSArray *downloadedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //list of dictionaries
            for(NSDictionary *dic in downloadedJSON){
                [arrayOfItems addObject:dic];
               
            }
        }
        //signal you're done with fetching item information
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    //wait for signal that completion block retrieving user info is finished before continuing
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return arrayOfItems;

}

//Parse :(
-(void)setProfilePicture:(UIImage*)image ForServerID:(NSString*)serverID andUserID:(NSString*)userID{
    
    CoreDataSingleton *request = [CoreDataSingleton sharedManager];
    CoreDataUser *currentUser = [request getCurrentUser];
    NSData *imageData = UIImageJPEGRepresentation(image,0.8);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    NSLog(@"server:%@",serverID);
    if (currentUser.profilePictureID)
    {
        PFObject *profilePicture = [PFObject objectWithoutDataWithClassName:@"ProfilePictures" objectId:currentUser.profilePictureID];
    
    // Set a new value on quantity
        [profilePicture setObject:imageFile forKey:@"file"];
        [profilePicture saveInBackground];
        //[self updateProfilePictureInfoForUser:serverID withPicture:currentUser.profilePictureID];

    } else
    {
        PFObject *userPhoto = [PFObject objectWithClassName:@"ProfilePictures"];
        [userPhoto setObject:imageFile forKey:@"file"];
        [userPhoto setObject:userID forKey:@"userID"];
        [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded)
            {
                [request savePictureID:userPhoto.objectId];
                NSLog(@"new %@",userPhoto.objectId);
                [self updateProfilePictureInfoForUser:serverID withPicture:userPhoto.objectId];
                
            }
        }];
        
        
    }
    

}

-(void)updateProfilePictureInfoForUser:(NSString*)serverID withPicture: (NSString*)pictureID
{
    NSString *fixedUrl = [NSString stringWithFormat:@"http://fashapp.herokuapp.com/users/%@/profilePicture", serverID];
    NSLog(@"here:%@",pictureID);
    NSLog(@"there:%@",serverID);
    NSURL *url = [NSURL URLWithString:fixedUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"PUT"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSData *userData = [NSJSONSerialization dataWithJSONObject:@[pictureID] options:kNilOptions error:nil];
    
    NSURLSessionUploadTask *uploadTask = [urlSession uploadTaskWithRequest:request fromData:userData completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error)
        {
             NSLog(@"completed");
        }
       
    }];
    [uploadTask resume];

    
}

-(void)deleteItem:(NSString*)itemServerID{
    
    NSString *urlString = [NSString stringWithFormat:@"http://fashapp.herokuapp.com/items/%@",itemServerID];
    NSURL *url = [NSURL URLWithString: urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"DELETE"];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        if(responseStatusCode == 200){
            NSLog(@"Delete successful");
        }
        else{
            NSLog(@"Did not delete with status: %i", (int)responseStatusCode);
        }
        
    }];
    
    [dataTask resume];

    
}

-(void)sendReferal:(NSDictionary*)item fromUser:(User*)fromUser toUser:(User*)toUser
{
    NSMutableDictionary *object = [[NSMutableDictionary alloc]init];
    object[@"fromUser"]=@{fromUser.userID:fromUser.username};
    object[@"toUserID"]=toUser.userID;
    object[@"toUsername"]=toUser.username;
    object[@"accepted"]=@"NO";
    object[@"product"]=item;
    NSURL *url = [NSURL URLWithString: @"http://fashapp.herokuapp.com/referals"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
    if(!error){
        NSURLSessionUploadTask *uploadTask = [urlSession uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSLog(@"save successful");
            
            
        }];
        [uploadTask resume];
    
    }
}

-(NSArray*)getRecommendationsforUserID:(NSString*) userID {
    __block NSMutableArray *arrayOfItems= [[NSMutableArray alloc]init];
    
    //create semaphore that fetches user information from server and then returns user object
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://fashapp.herokuapp.com/referals/%@",userID ]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        if(responseStatusCode==200 &&data){
            NSArray *downloadedJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]; //list of dictionaries
            for(NSDictionary *dic in downloadedJSON){
                [arrayOfItems addObject:dic];
                
            }
        }
        //signal you're done with fetching item information
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    //wait for signal that completion block retrieving user info is finished before continuing
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return arrayOfItems;
}




@end
