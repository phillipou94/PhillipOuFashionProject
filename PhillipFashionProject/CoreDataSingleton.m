//
//  CoreDataSingleton.m
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//
#import "AppDelegate.h"
#import "CoreDataSingleton.h"


@implementation CoreDataSingleton

+ (id)sharedManager {
    static CoreDataSingleton *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}
-(NSString*) getCurrentUserID{
    
    NSManagedObjectContext *context = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CoreDataUser" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error=nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"fetchedL%@",fetchedObjects);
    if([fetchedObjects count]>0){
        CoreDataUser *coreUser = [fetchedObjects objectAtIndex:0];
        return coreUser.userID;
    }
    else{
        return nil;
    }
    
}

-(CoreDataUser*) getCurrentUser
{
    NSManagedObjectContext *context = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CoreDataUser" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error=nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"fetchedL%@",fetchedObjects);
    if([fetchedObjects count]>0){
        CoreDataUser *coreUser = [fetchedObjects objectAtIndex:0];
        return coreUser;
    }

    return nil;
    
}

-(void)savePictureID:(NSString*) picID
{
    NSManagedObjectContext *context = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"CoreDataUser" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error=nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"fetchedL%@",fetchedObjects);
    if([fetchedObjects count]>0){
        CoreDataUser *coreUser = [fetchedObjects objectAtIndex:0];
        coreUser.profilePictureID=picID;
        [context save:nil];
        NSLog(@"saved:%@",coreUser.profilePictureID);
        
    }
    
}
@end
