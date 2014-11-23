//
//  UsersCollectionViewController.h
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/26/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UsersCollectionViewController : UICollectionViewController
@property (nonatomic, strong) User *selectedUser;

@end
