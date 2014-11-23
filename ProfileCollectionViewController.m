//
//  ProfileCollectionViewController.m
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/29/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "ProfileCollectionViewController.h"
#import "CoreDataSingleton.h"
#import "User.h"
#import "ServerRequest.h"
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>


@interface ProfileCollectionViewController ()
@property (nonatomic,strong) User *currentUser;
@property (nonatomic, strong) NSMutableArray *arrayOfItems;
@property (nonatomic, readonly) UICollectionReusableView *header;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation ProfileCollectionViewController{
    UIImageView *blurredView;
    BOOL isEditting;
}
@synthesize  header;

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    isEditting=NO;
    CGRect bounds;
    bounds = [[self view] bounds];
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(editPressed:)];
    longPress.minimumPressDuration = 1.0; //seconds
    longPress.delegate = self;
    [self.collectionView addGestureRecognizer:longPress];
    
    
  
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    isEditting=NO;
    [self.collectionView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.collectionView.delegate=self;
    self.collectionView.dataSource=self;
    CoreDataSingleton *coreRequest = [CoreDataSingleton sharedManager];
    PFQuery *query = [PFQuery queryWithClassName:@"ProfilePictures"];
    [query whereKey:@"userID" containsString:self.currentUser.userID];
    [query addDescendingOrder:@"createdAt"];
    if([[query findObjects]count]!=0){
        PFObject *photoObject = [query findObjects][0];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.profileImageView.image = [[UIImage alloc] initWithData: [[photoObject objectForKey:@"file"] getData]];
        }];
    }
    NSString *userID=[coreRequest getCurrentUserID];
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        ServerRequest *serverRequest = [ServerRequest sharedManager];
        self.currentUser=[serverRequest getUserInfoFromServer:userID];
        self.arrayOfItems=[serverRequest getItemsFor:userID];
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectedItem = [self.arrayOfItems objectAtIndex:indexPath.row];
    ShowItemViewController *newViewController = [[ShowItemViewController alloc] initWithNibName:@"ShowItemViewController" bundle:nil];
    newViewController.item = selectedItem;
    newViewController.imageURL = [selectedItem[@"images"][3] objectForKey:@"url"];
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.collectionView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CIImage *imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat: 10] forKey: @"inputRadius"];
    CIImage *resultImage = [gaussianBlurFilter valueForKey: @"outputImage"];
    UIImage *endImage = [[UIImage alloc] initWithCIImage:resultImage];
    
    //Place the UIImage in a UIImageView
    blurredView = [[UIImageView alloc] initWithFrame:CGRectMake(newViewController.view.frame.origin.x-50,newViewController.view.frame.origin.y-50,500,800)];
    blurredView.image = endImage;
    newViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    newViewController.delegate=self;
    [self presentModalViewController:newViewController animated:YES];
    [self.view addSubview:blurredView];
    
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)cv viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (!header) {
        
        header = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
        
        header.backgroundColor=[UIColor blackColor];
        self.profileImageView = (UIImageView*)[header viewWithTag:-1];
        [header addSubview:self.profileImageView];

    }
    
    return header;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return [self.arrayOfItems count];
    
}
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    UIButton *deleteButton = (UIButton*)[cell viewWithTag:-10];
    [deleteButton addTarget:self action:@selector(deleteButtonClicked:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    deleteButton.hidden=YES;
    if(isEditting){
        deleteButton.hidden=NO;
        CGAffineTransform leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-0.7));
        CGAffineTransform rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(0.7));
        cell.transform = leftWobble;  // starting point
        [UIView beginAnimations:@"wobble" context:(__bridge void *)(cell)];
        [UIView setAnimationRepeatAutoreverses:YES];
        [UIView setAnimationRepeatCount:10000]; // adjustable
        [UIView setAnimationDuration:0.125];
        [UIView setAnimationDelegate:self];
        cell.transform = rightWobble; // end here & auto-reverse
        [UIView commitAnimations];
    }
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        NSMutableDictionary *item = self.arrayOfItems[indexPath.row];
        NSString *imageString=[item[@"images"][3] objectForKey:@"url"];
        NSURL *imageURL = [NSURL URLWithString:imageString];
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        UIImage *itemImage = [UIImage imageWithData: data];
        
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.backgroundColor=[UIColor whiteColor];
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:-1];
            imageView.image=itemImage;
            imageView.contentMode=UIViewContentModeScaleAspectFit;
        });
    });
    
 
    return cell;
}

- (NSIndexPath*)indexPathForEvent:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.collectionView];
    
    return [self.collectionView indexPathForItemAtPoint:currentTouchPosition];
    
}

-(IBAction)deleteButtonClicked:(id)sender withEvent:(UIEvent*)event {
    
    UIButton *button = (UIButton*)sender;
    button.selected=YES;
    NSIndexPath *buttonIndexPath = [self indexPathForEvent:event];
    NSDictionary *item= [self.arrayOfItems objectAtIndex:buttonIndexPath.row];
    ServerRequest *serverRequest = [ServerRequest sharedManager];
    [serverRequest deleteItem:item[@"_id"]];
    [self.collectionView performBatchUpdates:^{
        [self.arrayOfItems removeObjectAtIndex:buttonIndexPath.row];
        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:buttonIndexPath]];
        
    } completion:^(BOOL finished) {
        
    }];
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(self.view.bounds.size.width/2-15, collectionView.bounds.size.width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

-(void)removeBlur{
    [@[blurredView] makeObjectsPerformSelector: @selector(removeFromSuperview)];
}

- (IBAction)editPressed:(id)sender {
    if(!isEditting){
        isEditting=YES;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"Done" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor blackColor];
        button.tintColor = [UIColor whiteColor];
        button.frame = self.tabBarController.tabBar.frame;
        [self.view addSubview:button];
        self.tabBarController.tabBar.hidden=YES;
    }
    [self.collectionView reloadData];
}

-(IBAction)done:(id)sender{
    isEditting = NO;
    UIButton *button = (UIButton*)sender;
    button.hidden=YES;
    [self.collectionView reloadData];
    self.tabBarController.tabBar.hidden=NO;
    
    
}
- (IBAction)takePhoto:(id)sender {
    [self performSegueWithIdentifier:@"showPhoto" sender:self];
}

- (IBAction)logOut:(id)sender {
    
    [FBSession.activeSession closeAndClearTokenInformation];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *loginNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"loginNav"];
    [self presentViewController:loginNavigationController animated:NO completion:nil];
    
}
@end
