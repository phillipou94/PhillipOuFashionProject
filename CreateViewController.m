//
//  CreateViewController.m
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/29/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "CreateViewController.h"
#import <Parse/Parse.h>
#import "CoreDataSingleton.h"
#import "ServerRequest.h"
#import "User.h"

@interface CreateViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) User *currentUser;

@end

@implementation CreateViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CoreDataSingleton *coreRequest = [CoreDataSingleton sharedManager];
    NSString *userID=[coreRequest getCurrentUserID];
    
    ServerRequest *serverRequest = [ServerRequest sharedManager];
    self.currentUser=[serverRequest getUserInfoFromServer:userID];


    
    
    // Do any additional setup after loading the view.
}

-(void)viewDidLoad{
    [super viewDidLoad];
    PFQuery *query = [PFQuery queryWithClassName:@"ProfilePictures"];
    [query whereKey:@"userID" containsString:self.currentUser.userID];
    [query addDescendingOrder:@"createdAt"];
    if([[query findObjects] count]>0) {
        PFObject *photoObject = [query findObjects][0];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"%@",photoObject);
            self.imageView.image = [[UIImage alloc] initWithData: [[photoObject objectForKey:@"file"] getData]];
        }];
    }

}


- (IBAction)takePhoto:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}
- (IBAction)choosePhoto:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
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
    // [self presentModalViewController:self.imagePicker animated:YES completion:nil];
}

//once photo is finished being taken
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    self.imageView.image = nil;
    UIImage *chosenImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = chosenImage;
    ServerRequest *request = [ServerRequest sharedManager];
    //[request setProfilePicture:chosenImage For:self.currentUser.userID];
    [request setProfilePicture:chosenImage ForServerID:self.currentUser.serverID andUserID:self.currentUser.userID];
    
    //handling landscape mode
    
    UIImageOrientation orientation = self.profileImageView.image.imageOrientation;
    if(orientation ==0 || orientation ==1){
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.tabBarController.tabBar.hidden=NO;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.tabBarController.hidesBottomBarWhenPushed=NO;
    self.tabBarController.tabBar.hidden=NO;
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
