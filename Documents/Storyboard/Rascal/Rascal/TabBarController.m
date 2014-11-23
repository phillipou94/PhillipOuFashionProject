//
//  TabBarController.m
//  Rascal
//
//  Created by Phillip Ou on 7/15/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "TabBarController.h"
#import "InboxViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
   
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([PFUser currentUser]){
       // NSLog(@"Segueing");
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        //InboxViewController *inboxViewController = (ImageViewController *)segue.destinationViewController;
       
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
