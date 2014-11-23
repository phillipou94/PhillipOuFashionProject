//
//  CoreDataSingleton.h
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataUser.h"

@interface CoreDataSingleton : NSObject
+ (id)sharedManager;
-(NSString*) getCurrentUserID;
-(CoreDataUser*) getCurrentUser;
-(void)savePictureID:(NSString*) picID;

@end
