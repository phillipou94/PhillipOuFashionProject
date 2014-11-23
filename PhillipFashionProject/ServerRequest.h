//
//  ServerRequest.h
//  Project Fashion
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import <UIKit/UIKit.h>

@interface ServerRequest : NSObject<NSURLSessionDelegate>

+ (id)sharedManager;
-(void) saveNewUser:(User*) currentUser;
-(User*) getUserInfoFromServer:(NSString*)userID;
-(void)saveLikedItem:(NSDictionary *)item forUser:(NSString*)userID;
-(NSMutableArray*)getItemsFor:(NSString*)userID;
-(void)setProfilePicture:(UIImage*)image ForServerID:(NSString*)serverID andUserID:(NSString*)userID;
-(NSArray*) getAllUsers;
-(void)deleteItem:(NSString*)itemServerID;
-(void)updateProfilePictureInfoForUser:(NSString*)serverID withPicture: (NSString*)pictureID;
@end
