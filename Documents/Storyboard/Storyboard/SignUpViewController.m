//
//  SignUpViewController.m
//  Storyboard
//
//  Created by Phillip Ou on 8/3/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation SignUpViewController

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)dismissKeyboard {
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)signup:(id)sender {
    
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([username rangeOfString:@"@"].location!=NSNotFound){
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter a username, not an email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else{
    if(username.length !=0 && password.length !=0){
        UIAlertView *EULA = [[UIAlertView alloc] initWithTitle:@"By Using This App You Agree to:" message:@"1. Not posting nude partially nude, or sexually suggestive photos. \n 2. Be responsible for any activity that occurs under your screen name. \n 3. Not abuse harass, threaten, or intimidate other users. \n 4. Not use Storyview for any illegal or unauthorized purpose \n 5. Be responsible for any data, text, information, graphics, photos, profiles that you submit, post and display to users on Storyview. \n Photos that violate these terms will be banned from the app along with the users who post them."
                                                      delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil];
        [EULA show];
        PFUser *user = [PFUser user];
        user.username = username;
        user.password = password;
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error){
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error Signing Up" message:@"that username is taken, please try a new one" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
            }
        }];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"One of the fields is empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }

    }
    
    

}

@end
