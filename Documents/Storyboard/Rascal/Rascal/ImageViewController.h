//
//  ImageViewController.h
//  Rascal
//
//  Created by Phillip Ou on 7/9/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface ImageViewController : UIViewController
@property (nonatomic, strong) PFObject *message;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property(nonatomic, strong) NSMutableArray *listOfLikers;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *numberOfLikesLabel;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolBarLabel;

- (IBAction)Like:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *likeButton;




@end
