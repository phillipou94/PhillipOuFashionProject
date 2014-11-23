//
//  ViewStoryViewController.m
//  Storyboard
//
//  Created by Phillip Ou on 8/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "ViewStoryViewController.h"
#import "FullStoryViewController.h"
#import "Parse/Parse.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewStoryViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *smallerImageView;

@property (strong, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *smallerLabel;
@property (nonatomic, strong) NSMutableArray *likedPhoto;
@property (nonatomic, strong) NSMutableArray *likedStory;
@property float likes;
@property (nonatomic, strong) PFObject *currentUser;
@property int initialLengthOfLikes;

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSString *isVideo;


@end

@implementation ViewStoryViewController

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
    
    [self.view setUserInteractionEnabled:YES];
    
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fullStoryButton:)];
       
    
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    // [self.imageView addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeUp];
        
        UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fullPictureButton:)];
        [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
        // [self.imageView addGestureRecognizer:swipeLeft];
        [self.view addGestureRecognizer:swipeDown];
    
    
    self.currentUser = [PFUser currentUser];

    [super viewDidLoad];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM d yyyy" options:0 locale:nil];
    
    [formatter setDateFormat:dateFormat];
    
    self.dateLabel.text= [formatter stringFromDate:self.selectedMessage.createdAt];
   
    
    self.videoFilePath=self.selectedMessage[@"videoFilePath"];
    
    

   

    
    //NSLog(@"view did load:%@",self.selectedMessage.objectId);
    // Do any additional setup after loading the view.
    
    if([self.selectedMessage[@"likedPhoto"] count]==0){
        self.likedPhoto =[[NSMutableArray alloc] init];
       
        
    }
    else{
        self.likedPhoto = [NSMutableArray arrayWithArray:self.selectedMessage[@"likedPhoto"] ];
      
    }
    self.likes = [self.selectedMessage[@"numberOfLikes"] floatValue];
    self.initialLengthOfLikes = [self.selectedMessage[@"likedPhoto"] count];
}

#define kOFFSET_FOR_KEYBOARD 80.0
-(void)setViewMovedUp:(BOOL)movedUp
{
    
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        
        CGRect rect = self.view.frame;
    CGRect storyRect = self.storyView.frame;
    //NSLog(@"%f",storyRect.origin.y);
   
            //NSLog(@"this is being showed");
    
            // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
            // 2. increase the size of the view so that the area behind the keyboard is covered up.
            rect.origin.y -= kOFFSET_FOR_KEYBOARD+150;
            rect.size.height += kOFFSET_FOR_KEYBOARD+150;
            
            storyRect.origin.y-= kOFFSET_FOR_KEYBOARD+150;
            storyRect.size.height += kOFFSET_FOR_KEYBOARD+150;
            self.smallerImageView.hidden=NO;
            self.fullStoryButton.hidden=YES;
            self.fullStoryIcon.hidden=YES;
            self.fullPicture.hidden=NO;
            self.storyView.hidden=NO;
    self.smallerLabel.hidden=NO;
     self.imageView.hidden=YES;
    self.likeButton2.hidden=NO;
    self.heart.hidden=YES;
    self.dateLabel.hidden=YES;
    self.view.frame = rect;
    
    
        [UIView commitAnimations];
    
           
    
            //self.chosenImageView.hidden=YES;
           // self.smallerImageView.hidden=NO;
}
//after swipe down
-(void)setViewMovedDown:(BOOL)movedDown
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    CGRect storyRect = self.storyView.frame;
    
    //NSLog(@"this is being showed");
    
    self.imageView.hidden=NO;
    self.smallerLabel.hidden=YES;
    self.dateLabel.hidden=NO;
    // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
    // 2. increase the size of the view so that the area behind the keyboard is covered up.
    rect.origin.y += kOFFSET_FOR_KEYBOARD+150;
    rect.size.height -= kOFFSET_FOR_KEYBOARD+150;
    
    storyRect.origin.y+= kOFFSET_FOR_KEYBOARD+150;
    storyRect.size.height -= kOFFSET_FOR_KEYBOARD+150;
    self.smallerImageView.hidden=YES;
    self.fullStoryButton.hidden=NO;
    self.fullStoryIcon.hidden=NO;
    self.fullPicture.hidden=YES;
    self.storyView.hidden=YES;
    
    self.likeButton2.hidden=YES;
    if(self.likeButton2.selected==YES){
        self.heart.hidden=NO;
    }
    
    self.view.frame = rect;
    
        [UIView commitAnimations];
    
}

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



-(void) viewWillAppear:(BOOL)animated{
    //NSLog(@"view will appear");
    self.isVideo = self.selectedMessage[@"isVideo"];
    if(![self.isVideo isEqualToString:@"YES"]){
        self.playButton.hidden=YES;
    }
    else{
        self.playButton.hidden=NO;
    }
    self.tabBarController.tabBar.hidden=NO;
    
  
    
    self.titleLabel.text = [self.selectedMessage objectForKey:@"title"];
    self.titleLabel.adjustsFontSizeToFitWidth=YES;
    self.smallerLabel.text = self.titleLabel.text;
    self.smallerLabel.adjustsFontSizeToFitWidth=YES;
    self.smallerLabel.hidden=YES;
    self.storyView.text = [self.selectedMessage objectForKey:@"story"];
    self.dateLabel.hidden=NO;
    self.likeButton2.hidden=YES;
    
    self.heart.hidden=YES;
    if(self.likeButton2.selected==YES){
        self.heart.hidden=NO;
        
    }
    
    if([self.likedPhoto containsObject:self.currentUser.objectId]){
        self.likeButton2.selected=YES;
        self.heart.hidden=NO;
    }
    
    PFFile *imageFile = [self.selectedMessage objectForKey: @"file"];
    
    
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageFile.url]];
    
    
    //self.imageView.image =
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.clipsToBounds = YES;
    self.image =[UIImage imageWithData:imageData];
    [self.imageView setImage:self.image];
    self.imageView.hidden=NO;
    
    self.smallerImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.smallerImageView.clipsToBounds = YES;
     [self.smallerImageView setImage:self.image];
    self.smallerImageView.hidden=YES;
    
    self.fullStoryButton.hidden=NO;
    self.fullStoryIcon.hidden=NO;
    self.fullPicture.hidden=YES;
    self.storyView.hidden=YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (IBAction)fullPictureButton:(id)sender {
    //NSLog(@"touched");
   
    
        [self setViewMovedDown:YES];
    
    
}

- (IBAction)fullStoryButton:(id)sender {
   
    if  (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    
    //remove moviePlayer when keyboard shows up
    [self.moviePlayer.view setFrame:CGRectMake(0,0,0,0)];
    NSLog(@"called???");

}
/*
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"fullStory"]){
        FullStoryViewController *viewController = [segue destinationViewController];
        //WritingViewController *viewController = [[WritingViewController alloc]init];
        
        viewController.selectedMessage = self.selectedMessage;
    }
}
*/



- (IBAction)likeButton2:(id)sender {
    //NSLog(@"liked");
    if(self.likeButton2.selected==YES){
        if([self.likedPhoto containsObject:self.currentUser.objectId])
            self.likeButton2.selected=NO;
            [self.likedPhoto removeObject:self.currentUser.objectId];
            self.likes-=1;
    }
    else{
        if(![self.likedPhoto containsObject:self.currentUser.objectId]){
            [self.likedPhoto addObject:self.currentUser.objectId];
            self.likeButton2.selected=YES;
            self.likes +=1;}
        }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    if(self.initialLengthOfLikes!=[self.likedPhoto count]){
        [self.selectedMessage setObject: [NSNumber numberWithFloat:self.likes]forKey:@"numberOfLikes"];
        [self.selectedMessage setObject:[NSArray arrayWithArray:self.likedPhoto]forKey:@"likedPhoto"];
        [self.selectedMessage saveInBackground];
        NSLog(@"count different");}
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
    
    self.moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    [self.moviePlayer.view setFrame:CGRectMake(10, 105, 298, 298)];
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
- (IBAction)like:(id)sender {
    PFUser *currentUser= [PFUser currentUser];
    if([[self.selectedMessage objectForKey:@"listOfLikers"] count]!=0){
            NSArray *array = [self.selectedMessage objectForKey:@"listOfLikers"];
        NSMutableArray *arrayUpdate = [NSMutableArray arrayWithArray:array];
        [arrayUpdate addObject:currentUser.objectId];
        [self.selectedMessage setObject:arrayUpdate forKey:@"listOfLikers"];}
    else{
        NSMutableArray *arrayUpdate = [[NSMutableArray alloc]init];
        [arrayUpdate addObject:currentUser.objectId];
        NSArray *array = [NSArray arrayWithArray: arrayUpdate];
        [self.selectedMessage setObject:array forKey:@"listOfLikers"];
    }
    [self.selectedMessage saveInBackground];
    
    
}*/

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
