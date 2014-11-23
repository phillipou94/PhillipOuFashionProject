//
//  ProfileViewController.h
//  Rascal
//
//  Created by Phillip Ou on 7/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "HomeViewController.h"

@interface ProfileViewController : PFQueryTableViewController
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) PFUser *currentUser;


@property (strong, nonatomic) IBOutlet UILabel *titleLabel;




@end
