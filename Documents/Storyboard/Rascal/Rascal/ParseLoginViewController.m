//
//  ParseLoginViewController.m
//  Rascal
//
//  Created by Phillip Ou on 6/30/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "ParseLoginViewController.h"
#import "TutorialViewController.h"

@interface ParseLoginViewController ()

@end

@implementation ParseLoginViewController

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
    //self.logInView.backgroundColor = [UIColor blueColor];
    
     //[self setFields: PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsDismissButton];
    
    
    self.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.logInView.backgroundColor = [UIColor whiteColor];
    [self.logInView.facebookButton setTitle:@"Login" forState:UIControlStateNormal];
     [self.logInView.facebookButton addTarget:self action:@selector(tutorialButton:) forControlEvents:UIControlEventTouchDown];
}


-(IBAction)tutorialButton:(id)sender{
    //NSLog(@"CLICKED THISSS!!");
   
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.logInView.facebookButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    
    CGRect frame = self.logInView.logo.frame;
    frame.origin.y = 150;
    self.logInView.logo.frame = frame;
    frame = self.logInView.facebookButton.frame;
    frame.origin.y = 300;
    self.logInView.facebookButton.frame = frame;
}

@end