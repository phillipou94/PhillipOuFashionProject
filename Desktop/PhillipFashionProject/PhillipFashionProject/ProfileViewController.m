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

@interface ProfileViewController ()
@property (nonatomic,strong) User *currentUser;
@property (nonatomic, strong) NSMutableArray *arrayOfItems;

@end


@implementation ProfileViewController
@synthesize header, collectionView;
- (void)loadView {
    
    [super loadView];
    
    CGRect bounds;
    bounds = [[self view] bounds];
    
    StretchyHeaderCollectionViewLayout *stretchyLayout;
    stretchyLayout = [[StretchyHeaderCollectionViewLayout alloc] init];
    [stretchyLayout setSectionInset:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
    [stretchyLayout setItemSize:CGSizeMake(300.0, 494.0)];
    [stretchyLayout setHeaderReferenceSize:CGSizeMake(320.0, 160.0)];
    
    collectionView = [[UICollectionView alloc] initWithFrame:bounds collectionViewLayout:stretchyLayout];
    [collectionView setBackgroundColor:[UIColor clearColor]];
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
        CGRect bounds;
        bounds = [header bounds];
        
        
        UIImageView *imageView;
        imageView = [[UIImageView alloc] initWithFrame:bounds];
        [imageView setImage:[UIImage imageNamed:@"header-background"]];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [imageView setClipsToBounds:YES];
        [header addSubview:imageView];
    }
    
    return header;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate=self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(showCamera)];
    [self.profileImageView addGestureRecognizer:tap];
    
    CoreDataSingleton *coreRequest = [CoreDataSingleton sharedManager];
    NSString *userID=[coreRequest getCurrentUserID];
    
    ServerRequest *serverRequest = [ServerRequest sharedManager];
    self.currentUser=[serverRequest getUserInfoFromServer:userID];
    self.arrayOfItems=[serverRequest getItemsFor:userID];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
 
    
    // Do any additional setup after loading the view.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.arrayOfItems count];
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
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

- (void)showCamera{
    NSLog(@"show camera");
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];

}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.profileImageView.isAnimating)
    {
        [self.profileImageView stopAnimating];
    }
    
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    //make sure it has camera
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;}
    else{ //but send them to photo library if they don't have a camera.
        
        imagePickerController.sourceType = sourceType;}
    
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
}

//once photo is finished being taken
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    
    UIImage *chosenImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    
    self.profileImageView.image = chosenImage;
    
    //handling landscape mode
    
    UIImageOrientation orientation = self.profileImageView.image.imageOrientation;
    if(orientation ==0 || orientation ==1){
        self.profileImageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:nil];
    self.tabBarController.hidesBottomBarWhenPushed=NO;
    
}

- (IBAction)logOut:(id)sender {
    if (FBSession.activeSession.isOpen)
    {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *loginNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"loginNav"];
    [self presentViewController:loginNavigationController animated:NO completion:nil];

}


@end
