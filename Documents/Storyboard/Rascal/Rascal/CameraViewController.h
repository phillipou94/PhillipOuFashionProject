//
//  CameraViewController.h
//  Rascal
//
//  Created by Phillip Ou on 6/30/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import <UIKit/UIKit.h>


@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>



@property (retain,nonatomic) NSString *objectIdString;
@property (nonatomic,strong) PFObject *message;
@property (nonatomic, strong) PFObject *mostRecentObject;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, strong) NSString *senderId;

@property (strong, nonatomic) IBOutlet UILabel *prompt;

@end

