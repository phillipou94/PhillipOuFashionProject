//
//  FullStoryViewController.m
//  Storyboard
//
//  Created by Phillip Ou on 8/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "FullStoryViewController.h"
#import "ViewStoryViewController.h"
#import "Reachability.h"

@interface FullStoryViewController ()
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation FullStoryViewController

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
    //self.navigationItem.
    
    [self.view setUserInteractionEnabled:YES];
    
    
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backButton:)];
        
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        // [self.imageView addGestureRecognizer:swipeLeft];
        [self.view addGestureRecognizer:swipeRight];
    //NSLog(@"here!: %@",self.selectedMessage);
    self.titleLabel.text = [self.selectedMessage objectForKey:@"title"];
    self.titleLabel.adjustsFontSizeToFitWidth=YES;
    self.textField.text = [self.selectedMessage objectForKey:@"story"];
    
    PFFile *imageFile = [self.selectedMessage objectForKey: @"file"];
    
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageFile.url]];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM d yyyy" options:0 locale:nil];
    
    [formatter setDateFormat:dateFormat];
    
    self.dateLabel.text= [formatter stringFromDate:self.selectedMessage.createdAt];
    //self.imageView.image =
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.clipsToBounds = YES;
    [self.imageView setImage:[UIImage imageWithData:imageData]];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButton:(id)sender {
    //[self prepareForSegue:@"backToTab" sender:self];
    [self performSegueWithIdentifier:@"back" sender:self];
    
    
}



-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    FullStoryViewController *viewController = [segue destinationViewController];
    //WritingViewController *viewController = [[WritingViewController alloc]init];
    
    viewController.selectedMessage = self.selectedMessage;
   


}
-(void)viewWillAppear:(BOOL)animated{
    if (![self connected]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"There is no network connection" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        // connected, do some internet stuff
    }
    
    [super viewWillAppear:animated];
}
- (BOOL)connected{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}


@end
