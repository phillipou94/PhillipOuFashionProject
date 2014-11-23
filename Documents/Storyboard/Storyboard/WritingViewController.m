//
//  WritingViewController.m
//  Storyboard
//
//  Created by Phillip Ou on 8/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "WritingViewController.h"
#import "CameraViewController.h"
#import <Parse/Parse.h>
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface WritingViewController ()




@end
static int clickcount;
@implementation WritingViewController

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
    clickcount=0;
    self.currentUser = [PFUser currentUser];
    self.titleTextField.text= self.titleText;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    
    self.textView.delegate = self;
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyboard)];
    
    
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    // [self.imageView addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    // [self.imageView addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeDown];
    
    //NSLog(@"%@",self.messageLocation);
   
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
        //don't scroll up if we're doing editting the titleTextField 
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
        textViewRect.origin.y -=kOFFSET_FOR_KEYBOARD+1;
        textViewRect.size.height += kOFFSET_FOR_KEYBOARD+150;
        
      
        //self.chosenImageView.hidden=YES;
        self.smallerImageView.hidden=NO;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD+155;
        rect.size.height -= kOFFSET_FOR_KEYBOARD+155;
        textViewRect.origin.y +=kOFFSET_FOR_KEYBOARD+155;
        textViewRect.size.height -= kOFFSET_FOR_KEYBOARD+155;
        //self.chosenImageView.hidden=NO;
        self.smallerImageView.hidden=YES;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}
}

- (void)viewWillAppear:(BOOL)animated
{
    
    self.chosenImageView.image = self.chosenImage;
    self.smallerImageView.image = self.chosenImage;
    self.smallerImageView.hidden=YES;
   
    if([self.currentUser[@"Anonymous"] isEqualToString:@"Yes"]){
        self.anonymousLabel.hidden=NO;
    }
    else{
        self.anonymousLabel.hidden=YES;
    }
    
    [super viewWillAppear:animated];
   
    // ensures that after we take a photo it will go back to original viewcontroller to take pictures
    if(self.chosenImage==nil){
        //NSLog(@"going back!");
        [self.navigationController popViewControllerAnimated:YES];
    }
    
     // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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
}/*
-(void) viewWillAppear:(BOOL)animated{
     //[self.chosenImageView setImage: self.chosenImage];
    
    
}*/

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
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(clickcount==0){
        textView.text = @"";}
    clickcount++;
}
- (IBAction)shareButton:(id)sender {
    self.selectedMessage = [PFObject objectWithClassName:@"Messages"];
    
    NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, 0.7);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    self.selectedMessage[@"file"] = imageFile;
    self.selectedMessage[@"location"]=self.messageLocation;
    self.selectedMessage[@"whoTook"]= [PFUser currentUser];
    self.selectedMessage[@"whoTookId"]= [[PFUser currentUser]objectId];
    self.selectedMessage[@"whoTookName"] =self.currentUser.username;
    if(self.titleTextField.text.length ==0){
        self.titleTextField.text = @"Untitled";
    }
    [self.selectedMessage setObject: self.titleTextField.text forKey:@"title"];
    
    [self.selectedMessage setObject: [self.textView text] forKey:@"story"];
    //for anonymous users
    if([self.currentUser[@"Anonymous"] isEqualToString:@"Yes"]){
        [self.selectedMessage setObject:@"Anonymous" forKey:@"whoTookName"];
    }
    
    [self.selectedMessage saveInBackground];
    
    [self reset];
    [self.tabBarController setSelectedIndex:0];
    
}
-(void) reset{
    self.selectedMessage = nil;
    self.chosenImage = nil;
    self.titleText=nil;
    self.titleTextField=nil;
    //[self.tabBarController setSelectedIndex:0];
    
}
- (IBAction)saveButton:(id)sender {
    
    self.selectedMessage = [PFObject objectWithClassName:@"SavedMessages"];
    
    NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, 0.7);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    self.selectedMessage[@"file"] = imageFile;
    self.selectedMessage[@"location"]=self.messageLocation;
    self.selectedMessage[@"whoTook"]= [PFUser currentUser];
    self.selectedMessage[@"whoTookId"]= [[PFUser currentUser]objectId];
    if(self.titleTextField.text.length ==0){
        self.titleTextField.text = @"Untitled";
    }
    [self.selectedMessage setObject: self.titleTextField.text forKey:@"title"];
    self.selectedMessage[@"story"] = [self.textView text];
    
    [self.selectedMessage saveInBackground];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Draft Saved"
                                                        message:@"Come back and edit it anytime"
                                                       delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
    [alertView show];
    [self reset];
    
    [self.tabBarController setSelectedIndex: 0];
}


@end
