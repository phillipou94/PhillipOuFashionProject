//
//  ProfileViewController.m
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "ProfileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <FacebookSDK/FacebookSDK.h>
#import "CurrentUser.h"
#import "ServerRequest.h"
#import "CoreDataSingleton.h"
#import "StretchyHeaderCollectionViewLayout.h"
#import "ShowItemViewController.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()
@property (nonatomic,strong) User *currentUser;
@property (nonatomic, strong) NSMutableArray *arrayOfItems;

@end


@implementation ProfileViewController{
    UIImageView *blurredView;
}
@synthesize header, collectionView;

-(void)viewDidLoad{
    
    [super viewDidLoad];
    CGRect bounds;
    bounds = [[self view] bounds];
    
    PFQuery *query = [PFQuery queryWithClassName:@"ProfilePictures"];
    [query whereKey:@"userID" containsString:self.currentUser.userID];
    PFObject *photoObject = [query findObjects][0];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        self.profileImageView.image = [[UIImage alloc] initWithData: [[photoObject objectForKey:@"file"] getData]];
        
        
    }];
    
    StretchyHeaderCollectionViewLayout *stretchyLayout;
    stretchyLayout = [[StretchyHeaderCollectionViewLayout alloc] init];
    [stretchyLayout setSectionInset:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
    [stretchyLayout setItemSize:CGSizeMake(190, 360.0)];
    [stretchyLayout setHeaderReferenceSize:CGSizeMake(190.0, 360.0)];
    
    
    collectionView = [[UICollectionView alloc] initWithFrame:bounds collectionViewLayout:stretchyLayout];
    [collectionView setBackgroundColor:[UIColor colorWithRed:218.0/255 green:218.0/255 blue:218.0/255 alpha:1]];
    [collectionView setAlwaysBounceVertical:YES];
    [collectionView setShowsVerticalScrollIndicator:NO];
    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [[self view] addSubview:self.collectionView];
    [collectionView registerClass:[UICollectionViewCell class]
       forCellWithReuseIdentifier:@"Cell"];
    [collectionView registerClass:[UICollectionReusableView class]
       forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
              withReuseIdentifier:@"Header"];
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)cv viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (!header) {
        
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                    withReuseIdentifier:@"Header"
                                                           forIndexPath:indexPath];
        header.backgroundColor=[UIColor blackColor];
        CGRect bounds;
        bounds = [header bounds];
        
        //UIButton *cameraButton = [[UIButton alloc]initWithFrame:header.frame];
        UIButton *cameraButton = [[UIButton alloc]initWithFrame:CGRectMake(header.frame.size.width-40,0,35,35)];
        [cameraButton addTarget:self action:@selector(showCamera) forControlEvents:UIControlEventTouchUpInside];
        //cameraButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"camera-grey"]];
        [cameraButton setBackgroundImage:[UIImage imageNamed:@"camera-grey"] forState:UIControlStateNormal];
        cameraButton.imageView.contentMode=UIViewContentModeScaleAspectFill;
        //cameraButton.imageView.image = [UIImage imageNamed:@"camera-grey"];
        
        self.profileImageView = [[UIImageView alloc] initWithFrame:bounds];
        [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.profileImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        self.profileImageView.frame = header.frame;
        //self.profileImageView.contentMode =UIViewContentModeScaleAspectFit;
        [self.profileImageView setClipsToBounds:YES];
        
        [header addSubview:self.profileImageView];
        [self.profileImageView addSubview:cameraButton];
        [header addSubview:cameraButton];
    }
    
    return header;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.collectionView.delegate=self;
    CoreDataSingleton *coreRequest = [CoreDataSingleton sharedManager];
    NSString *userID=[coreRequest getCurrentUserID];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(concurrentQueue, ^{
        ServerRequest *serverRequest = [ServerRequest sharedManager];
        self.currentUser=[serverRequest getUserInfoFromServer:userID];
        self.arrayOfItems=[serverRequest getItemsFor:userID];
        
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
             [collectionView reloadData];
            
        });
    });

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.arrayOfItems count];
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *selectedItem = [self.arrayOfItems objectAtIndex:indexPath.row];
    
    ShowItemViewController *newViewController = [[ShowItemViewController alloc] initWithNibName:@"ShowItemViewController" bundle:nil];
    newViewController.item = selectedItem;
    newViewController.imageURL = [selectedItem[@"images"][3] objectForKey:@"url"];
    newViewController.index=indexPath.row;
    
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
    
    [self presentViewController:newViewController animated:YES completion:nil];
    [self.view addSubview:blurredView];

}
-(void)removeBlur{
    
    [@[blurredView] makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //this will start the image loading in background
    dispatch_async(concurrentQueue, ^{
        
        NSMutableDictionary *item = self.arrayOfItems[indexPath.row];
        NSString *imageString=[item[@"images"][3] objectForKey:@"url"];
        NSURL *imageURL = [NSURL URLWithString:imageString];
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        UIImage *itemImage = [UIImage imageWithData: data];
        //this will set the image when loading is finished
        dispatch_async(dispatch_get_main_queue(), ^{
            
            cell.backgroundView = [[UIImageView alloc] initWithImage:itemImage];
            cell.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
            cell.backgroundColor = [UIColor whiteColor];
           
           
        });
    });
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(138, 310);
}



- (void)showCamera {
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];

}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.profileImageView.isAnimating) {
        
        [self.profileImageView stopAnimating];
        
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    //make sure it has camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else{ //but send them to photo library if they don't have a camera.
        
        imagePickerController.sourceType = sourceType;
    }
    
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;}
        
        else{
            imagePickerController.showsCameraControls =YES;}
        
    }
    
    self.imagePicker = imagePickerController;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    self.tabBarController.tabBar.hidden=YES;
   
}

//once photo is finished being taken
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.profileImageView.image = chosenImage;
    
    ServerRequest *request = [ServerRequest sharedManager];
    [request setProfilePicture:chosenImage ForServerID:self.currentUser.serverID andUserID:self.currentUser.userID];
    
    UIImageOrientation orientation = self.profileImageView.image.imageOrientation;
    if(orientation ==0 || orientation ==1) {
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.tabBarController.tabBar.hidden=NO;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.tabBarController.hidesBottomBarWhenPushed=NO;
    self.tabBarController.tabBar.hidden=NO;
}



- (IBAction)logOut:(id)sender {
    
    [FBSession.activeSession closeAndClearTokenInformation];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *loginNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"loginNav"];
    [self presentViewController:loginNavigationController animated:NO completion:nil];

}


@end
