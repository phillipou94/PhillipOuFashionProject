//
//  SaveWritingViewController.m
//  Storyboard
//
//  Created by Phillip Ou on 8/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "SaveWritingViewController.h"
#import <Parse/Parse.h>
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SaveWritingViewController ()

@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSString *isVideo;
@end

@implementation SaveWritingViewController

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
    //NSLog(@"%@",self.selectedMessage.objectId);
    self.currentUser = [PFUser currentUser];
    self.textView.delegate = self;
    self.titleTextField.text = self.selectedMessage[@"title"];
    self.textView.text = self.selectedMessage[@"story"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    self.initialTextLength = [self.selectedMessage[@"story"] length];
    
    [self.view addGestureRecognizer:tap];
    
    self.textView.delegate = self;
    
    PFFile *imageFile = [self.selectedMessage objectForKey: @"file"];
    
    
   // NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageFile.url]];
    
    self.videoFilePath=[self.selectedMessage objectForKey:@"videoFilePath"];
    self.isVideo=[self.selectedMessage objectForKey:@"isVideo"];
    
    if(![self.isVideo isEqualToString:@"YES"]){
        self.playButton.hidden=YES;
    }
    else{
        self.playButton.hidden=NO;
    }
    
    self.chosenImageView.file = imageFile;
    [self.chosenImageView loadInBackground];
    //self.chosenImageView.image = [UIImage imageWithData:imageData];
    self.smallerImageView.file = imageFile;
    [self.smallerImageView loadInBackground];
    self.smallerImageView.hidden=YES;
    
   /*
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveDraft:)];
    doubleTap.cancelsTouchesInView = YES;
    doubleTap.numberOfTouchesRequired=2;
    doubleTap.numberOfTapsRequired = 1;
    doubleTap.delegate = self;
    
    [self.view addGestureRecognizer:doubleTap];*/
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyboard)];
    
    
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    // [self.imageView addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    // [self.imageView addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeDown];

    


    self.tabBarController.tabBar.hidden = NO;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)textViewDidChange:(UITextView *)textView {
    
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}

#define kOFFSET_FOR_KEYBOARD 140.0

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    
    
    if ([sender isEqual:self.textView])
    {
        
        
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
   
   
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    if(self.titleTextField.isEditing){
        //don't scroll up if we're doing editting the titleTextField anything if we're
    }
    else{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    CGRect textViewRect = self.textView.frame;
       
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD+155;
        rect.size.height += kOFFSET_FOR_KEYBOARD+155;
        textViewRect.origin.y -=kOFFSET_FOR_KEYBOARD+155;
        textViewRect.size.height += kOFFSET_FOR_KEYBOARD+155;
        
        self.smallerImageView.hidden=NO;
       
    }
        
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD+155;
        rect.size.height -= kOFFSET_FOR_KEYBOARD+155;
        textViewRect.origin.y +=kOFFSET_FOR_KEYBOARD+155;
        textViewRect.size.height -= kOFFSET_FOR_KEYBOARD+155;
        textViewRect.origin.x -= 51;
        self.smallerImageView.hidden=YES;
    }
    
    self.view.frame = rect;
    
    [UIView commitAnimations];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden=YES;
    
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    if([self.currentUser[@"Anonymous"] isEqualToString:@"Yes"]){
        self.anonymousLabel.hidden=NO;
    }
    else{
        self.anonymousLabel.hidden=YES;
    }
    if (![self connected]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"There is no network connection" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        // connected, do some internet stuff
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
 
    if([self.textView.text length] != self.initialTextLength){
        [self.selectedMessage setObject:[self.textView text] forKey:@"story"];
        [self.selectedMessage setObject:self.titleTextField.text forKey:@"title"];
        [self.selectedMessage saveInBackground];
        //NSLog(@"saved!");
    }
   
        
    
    
   
}

-(void)dismissKeyboard {
    [self.textView resignFirstResponder];
    [self.titleTextField resignFirstResponder];
}
-(void)showKeyboard{
    //if statement needed to avoid bug when user swipes up while still editting title
    if(self.titleTextField.isEditing){
        [self.titleTextField resignFirstResponder];
            
        }
    [self.textView becomeFirstResponder];
    
    //[self.titleTextField becomeFirstResponder];
    
}
/*
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.text = @"";
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)shareButton:(id)sender {
    PFObject *message = [PFObject objectWithClassName:@"Messages"];
    PFUser *currentUser = [PFUser currentUser];
     PFFile *imageFile = [self.selectedMessage objectForKey: @"file"];
    message[@"file"] = imageFile;
    message[@"whoTook"]= [PFUser currentUser];
    message[@"whoTookId"]= [[PFUser currentUser]objectId];
    message[@"location"] = [self.selectedMessage objectForKey:@"location"];
    if(self.titleTextField.text.length ==0){
        self.titleTextField.text = @"Untitled";
    }
    if(self.titleLabel.text.length==0){
        self.titleLabel.text=@"Untitled";
    }
    [message setObject: self.titleTextField.text forKey:@"title"];
    [message setObject: [self.textView text] forKey:@"story"];
    
    [message setObject:[[PFUser currentUser] username] forKey:@"whoTookName"];
    if([currentUser[@"Anonymous"] isEqualToString:@"Yes"]){
        [message setObject:@"Anonymous" forKey:@"whoTookName"];
    }
    if([self.isVideo isEqualToString:@"YES"]){
        message[@"videoFilePath"]=self.videoFilePath;
        message[@"isVideo"]=@"YES";
        message[@"videofile"]=self.selectedMessage[@"videofile"];
        
    }


    
    [message saveInBackground];
    
   /* [self.selectedMessage setObject: @"sent" forKey:@"sent"];
    [self.selectedMessage saveInBackground];*/
    //[self.tabBarController setSelectedIndex:0];
    [self.selectedMessage deleteInBackground];
    [self reset];
    
}


-(void) reset{
    self.selectedMessage = nil;
    //[self.tabBarController setSelectedIndex:0];
     [self performSegueWithIdentifier:@"backToTab" sender:self];
}

- (IBAction)saveDraft:(id)sender {
    //NSLog(@"save clicked");
    [self.selectedMessage setObject:self.titleTextField.text forKey:@"title"];
    [self.selectedMessage setObject:[self.textView text] forKey:@"story"];
    [self.selectedMessage saveInBackground];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Draft Saved"
                                                        message:@"Come back and edit it anytime"
                                                       delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
    [alertView show];
    
    
}
- (BOOL)connected{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (IBAction)playButton:(id)sender {
    NSLog(@"Play");
	//NSString *moviePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"fire.mov"];
    [self playMovieAtURL:self.videoFilePath];
}

-(void) playMovieAtURL: (NSString*) videoPath {
    
    
    PFFile *videoFile = self.selectedMessage[@"videofile"];
    //NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSURL *videoURL =  [NSURL URLWithString: videoFile.url];
    NSLog(@"Converted: %@",videoURL);
    
    self.moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    [self.moviePlayer.view setFrame:CGRectMake(43, 119, 235, 235)];
    [self.moviePlayer prepareToPlay];
    [self.moviePlayer setShouldAutoplay:NO]; // And other options you can look through the documentation.
    [self.view addSubview:self.moviePlayer.view];
    
    
    [self.moviePlayer play];
}

// When the movie is done, release the controller.
-(void) myMovieFinishedCallback: (NSNotification*) aNotification
{
    MPMoviePlayerController* theMovie = [aNotification object];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: MPMoviePlayerPlaybackDidFinishNotification
     object: theMovie];
    
    
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

@end
