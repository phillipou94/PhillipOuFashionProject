//
//  ViewStoryViewController.h
//  Storyboard
//
//  Created by Phillip Ou on 8/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ViewStoryViewController : UIViewController
@property (strong,nonatomic) PFObject *selectedMessage;
@property(strong,nonatomic) UIImage *image;


@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UITextView *storyView;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIButton *fullStoryButton;

@property (strong, nonatomic) IBOutlet UIButton *fullPicture;

@property (strong, nonatomic) IBOutlet UIButton *heart;

@property (strong, nonatomic) IBOutlet UIButton *fullStoryIcon;

@property (strong, nonatomic) IBOutlet UIButton *likeButton2;



@end
