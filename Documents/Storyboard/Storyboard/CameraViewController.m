//
//  CameraViewController.m
//  Storyboard
//
//  Created by Phillip Ou on 8/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <Parse/Parse.h>
#import "WritingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CameraViewController ()
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;




@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *chosenImageView;
@property (weak, nonatomic) UIImage *chosenImage;
/*@property (weak,nonatomic) IBOutlet UITextField *titleTextField;*/
@property (nonatomic,strong) PFGeoPoint *messageLocation;

@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) UIImage *videoThumbnail;
@property (nonatomic,strong) NSString *isVideo;
@property (nonatomic, strong) PFFile *videoFile;

@end

static int clickcount;
@implementation CameraViewController

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
    
    
    self.textView.delegate = self;
     self.titleTextField.delegate = self;
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyboard)];
    
    
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    // [self.imageView addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    // [self.imageView addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeDown];

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

#define kOFFSET_FOR_KEYBOARD 160.0

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
   
}

-(void)keyboardWillHide {
     if (self.view.frame.origin.y < 0)
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
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if(clickcount==0){
        textView.text = @"";}
    clickcount++;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.smallerImageView.hidden=YES;
    self.tabBarController.tabBar.hidden=YES;
    self.titleTextField.text = nil;
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.playButton.hidden=YES;
    if([self.isVideo isEqualToString:@"YES"]){
        self.playButton.hidden=NO;
    }
    
    //crop image into a square like instagram
    
    self.imagePicker.allowsEditing=YES;
    
    //video duration has to be under 10 seconds
    self.imagePicker.videoMaximumDuration=10;
    //if device has camera show camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
       
       
        
    }
    //if not show library of photos
    else{
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    //pictures only
   // self.imagePicker.mediaTypes = [NSArray arrayWithObjects: (NSString *) kUTTypeImage, nil];
    
    //allows video
   self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
    
    [self presentViewController:self.imagePicker animated:NO completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}



-(void) showError{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not post your photo, please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
//person finished taking picture
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // if photos was taken or selected!!
    if([mediaType isEqualToString: (NSString*)kUTTypeImage]){
        self.chosenImage = info[UIImagePickerControllerEditedImage];
    //NSLog(@"%@",self.chosenImage);
        self.chosenImageView.image = self.chosenImage;
        self.smallerImageView.image=self.chosenImage;
        [self dismissViewControllerAnimated:YES completion: nil];
    
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        //NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
        self.messageLocation = geoPoint;
            self.isVideo=@"NO";
    }];
    }
    //video was taken!!
   else{
       self.isVideo=@"YES";
        self.videoFilePath = (__bridge NSString *)([[info objectForKey:UIImagePickerControllerMediaURL] path]);
       [self dismissViewControllerAnimated:YES completion:nil];
       
       NSURL *videoURl = [NSURL fileURLWithPath:self.videoFilePath];
       NSLog(@"VideoURL: %@",videoURl);
       AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURl options:nil];
       AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
       generate.appliesPreferredTrackTransform = YES;
       NSError *err = NULL;
       CMTime time = CMTimeMake(1, 60);
       CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
       self.chosenImageView.image=nil;
       self.videoThumbnail = [[UIImage alloc] initWithCGImage:imgRef];
       [self.chosenImageView setImage:self.videoThumbnail];
       self.smallerImageView.image=self.videoThumbnail;
        [self dismissViewControllerAnimated:YES completion: nil];
       
       [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
           
           //NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
           self.messageLocation = geoPoint;
       }];
       
       
      /*  if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)){
            UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil);
        }*/
        
    }
}
///person decides to cancel picture
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //go back to home screen and clear camera of data
    [self.tabBarController setSelectedIndex:0];
    [self clear];
    
}
-(void) clear{
    self.chosenImageView.image=nil;
    self.smallerImageView.image=nil;
    self.titleTextField.text=nil;
    self.videoFilePath=nil;
    self.videoThumbnail=nil;
    self.playButton.hidden=YES;
}

//every timescreen is touched in CameraViewController, this is activated

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.titleTextField resignFirstResponder]; //!!!resign first responder take away keyboard once photo chosen
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"transition"]){
    WritingViewController *viewController = [segue destinationViewController];
    //WritingViewController *viewController = [[WritingViewController alloc]init];
        //NSLog(@"%@",self.chosenImage);
    viewController.chosenImage=self.chosenImage;
    viewController.messageLocation = self.messageLocation;
    viewController.titleText= self.titleTextField.text;
        
    viewController.videoThumbnail= self.videoThumbnail;
    viewController.videoFilePath=self.videoFilePath;
    viewController.videoFile=self.videoFile;
    
        
        
  
        
    }
}
- (IBAction)backButton:(id)sender {
    [self clear];
    
    [self.tabBarController setSelectedIndex: 0];
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)post:(id)sender {
    PFObject *message = [PFObject objectWithClassName:@"Messages"];
    
  
    
    message[@"location"]=self.messageLocation;
    message[@"whoTook"]= [PFUser currentUser];
    message[@"whoTookName"]=[[PFUser currentUser]username];
    message[@"whoTookId"]= [[PFUser currentUser]objectId];
   
    if(self.videoFilePath != NULL){
        NSLog(@"There's a Video");
        self.videoFile = [PFFile fileWithName:@"video.mov" contentsAtPath:self.videoFilePath];
        message[@"videofile"] = self.videoFile;
        
        NSData *imageData = UIImageJPEGRepresentation(self.videoThumbnail, 0.7);
        message[@"file"] =[PFFile fileWithName:@"image.png" data:imageData];
        message[@"isVideo"]=@"YES";
        message[@"videoFilePath"]=self.videoFilePath;
    }
    else{
        NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, 0.7);
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        message[@"file"] = imageFile;
    }
    
    if(self.titleTextField.text.length ==0){
        self.titleTextField.text = @"Untitled";
    }
    message[@"title"] = self.titleTextField.text;
    [message setObject: [self.textView text] forKey:@"story"];
    if([self.currentUser[@"Anonymous"] isEqualToString:@"Yes"]){
        [message setObject:@"Anonymous" forKey:@"whoTookName"];
    }
    NSLog(@"Posting:%@",message);
    [message saveInBackground];
    
    
    
    //[self clear];
    [self.tabBarController setSelectedIndex: 0];
    
    
}
- (IBAction)saveButton:(id)sender {
    PFObject *message = [PFObject objectWithClassName:@"SavedMessages"];
    
   
    
    message[@"location"]=self.messageLocation;
    message[@"whoTook"]= [PFUser currentUser];
    message[@"whoTookId"]= [[PFUser currentUser]objectId];
    message[@"title"] = self.titleTextField.text;
    message[@"story"] = [self.textView text];
    if(self.videoFilePath != NULL){
        NSLog(@"There's a Video");
        self.videoFile = [PFFile fileWithName:@"video.mov" contentsAtPath:self.videoFilePath];
        message[@"videofile"] = self.videoFile;
        
        NSData *imageData = UIImageJPEGRepresentation(self.videoThumbnail, 0.7);
        message[@"file"] =[PFFile fileWithName:@"image.png" data:imageData];
        message[@"isVideo"]=@"YES";
        message[@"videoFilePath"]=self.videoFilePath;
    }
    else{
         NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, 0.7);
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        message[@"file"] = imageFile;
    }
    
    
    [message saveInBackground];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Draft Saved"
                                                        message:@"Come back and edit it anytime"
                                                       delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:nil];
    [alertView show];
    
    [self clear];
     [self.tabBarController setSelectedIndex: 0];
}


- (IBAction)playButton:(id)sender {
    NSLog(@"Play");
	//NSString *moviePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"fire.mov"];
    [self playMovieAtURL:self.videoFilePath];
}

-(void) playMovieAtURL: (NSString*) videoPath {
    
    
    
     NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    NSLog(@"Converted: %@",videoURL);
    
    self.moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    [self.moviePlayer.view setFrame:CGRectMake(25, 108, 270, 270)];
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


@end
