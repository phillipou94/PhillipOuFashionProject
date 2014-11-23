//
//  SavedTableViewController.h
//  Storyboard
//
//  Created by Phillip Ou on 8/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SavedTableViewController : PFQueryTableViewController
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) PFObject *selectedMessage;
@property int loadCount;
@property (strong, nonatomic) IBOutlet UIButton *showDraftsButton;
@property (strong, nonatomic) IBOutlet UIButton *showDraftsIcon;

@end
