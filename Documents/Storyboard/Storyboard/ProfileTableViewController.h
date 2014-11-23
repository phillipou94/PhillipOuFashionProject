//
//  ProfileTableViewController.h
//  Storyview
//
//  Created by Phillip Ou on 8/10/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ProfileTableViewController : PFQueryTableViewController
@property (nonatomic, strong) PFUser *currentUser;

@property (nonatomic, strong) PFObject *selectedMessage;
@property int loadCount;
@property (strong, nonatomic) IBOutlet UIButton *showStoryButton;
@property (strong, nonatomic) IBOutlet UIButton *showStoryIcon;


@end
