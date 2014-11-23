//
//  User.h
//  Project Fashion
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *userID;
@property (nonatomic,copy) NSString *serverID;
@property (nonatomic,strong) NSMutableDictionary *followingDictionary;
@property (nonatomic,strong) NSMutableDictionary *followerDictionary;
@property (nonatomic,strong) NSMutableArray *recommendedList;
@property (nonatomic,strong) NSMutableArray *favoriteClothing;
@property (nonatomic,strong) NSMutableArray *shoppingCart;
@property (nonatomic,strong) NSArray *profilePictures;
@property int points;
@end
