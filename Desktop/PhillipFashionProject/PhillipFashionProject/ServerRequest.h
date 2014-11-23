//
//  ServerRequest.h
//  Project Fashion
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface ServerRequest : NSObject<NSURLSessionDelegate>

+ (id)sharedManager;
-(void) saveNewUser:(User*) currentUser;
-(User*) getUserInfoFromServer:(NSString*)userID;
-(void)saveLikedItem:(NSDictionary *)item forUser:(User*)userID;
-(NSMutableArray*)getItemsFor:(NSString*)userID;

@end
