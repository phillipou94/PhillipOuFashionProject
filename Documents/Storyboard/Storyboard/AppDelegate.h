//
//  AppDelegate.h
//  Storyboard
//
//  Created by Phillip Ou on 8/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PFLogInViewControllerDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
