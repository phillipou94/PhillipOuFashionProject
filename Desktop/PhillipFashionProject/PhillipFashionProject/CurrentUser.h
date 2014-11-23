//
//  CurrentUser.h
//  Project Fashion
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "User.h"

@interface CurrentUser : User
+ (id)sharedManager;
@end
