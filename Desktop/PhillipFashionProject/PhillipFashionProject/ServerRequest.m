//
//  ServerRequest.m
//  Project Fashion
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "ServerRequest.h"

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

#pragma mark -get user info
#pragma warning - need to fix search later
-(User*) getUserInfoFromServer:(NSString*)userID{
    __block User *user = [[User alloc]init];
    
    //create semaphore that fetches user information from server and then returns user object
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://fashapp.herokuapp.com/users"]];
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
            NSLog(@"downloaded:%@",downloadedJSON);
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

-(void)saveLikedItem:(NSDictionary *)item forUser:(User*)user{
    NSLog(@"saving :%@",item);
    NSMutableDictionary *mutableItem = [item mutableCopy];
    [mutableItem setObject:user.userID forKey:@"likedBy"];
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
    NSLog(@"got:%@",arrayOfItems);
    return arrayOfItems;

}


@end
