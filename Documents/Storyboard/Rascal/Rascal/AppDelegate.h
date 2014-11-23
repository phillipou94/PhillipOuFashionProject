//
//  AppDelegate.h
//  Rascal
//
//  Created by Phillip Ou on 6/28/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ParseLoginViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, PFLogInViewControllerDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSMutableData *profilePictureData;

- (void)presentLoginControllerAnimated:(BOOL)animated;
@end