//
//  PostCameraViewController.h
//  Rascal
//
//  Created by Phillip Ou on 7/10/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "CameraViewController.h"
@interface PostCameraViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSMutableArray *recipients;
@property (nonatomic, strong) PFObject *mostRecentPost;
@property(nonatomic, strong ) NSData *imageData;
@property (nonatomic, strong) NSMutableArray *allFriends;


@property (nonatomic, strong) PFUser *whoTook;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong )UIImageView *chosenImageView;
@property (nonatomic, strong) PFObject *selectedMessage;




@property (nonatomic, copy) CameraViewController *photoJustPosted;
@property (nonatomic, strong) NSString *photoObjectId;

@property (nonatomic, strong) PFObject *message;

@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, strong) NSString *senderId;



- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;

- (void)uploadMessage;


@end

