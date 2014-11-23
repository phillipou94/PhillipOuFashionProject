//
//  CoreDataUser.h
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataUser : NSManagedObject
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString* userID;
@property (nonatomic, retain) NSString *serverID;
@property (nonatomic, retain) NSString *profilePictureID;
@property (nonatomic, retain) NSDictionary *followingDictionary;
@property (nonatomic, retain) NSDictionary *followerDictionary;
@property (nonatomic, retain) NSArray *profilePictures;
@property (nonatomic, retain) NSArray *recommendedList;
@property (nonatomic, retain) NSArray *shoppingCart;
@property (nonatomic, retain) NSArray *favoriteClothing;
@property (nonatomic) NSInteger *points;

@end
