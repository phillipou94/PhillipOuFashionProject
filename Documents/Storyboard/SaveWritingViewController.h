//
//  SaveWritingViewController.h
//  Storyboard
//
//  Created by Phillip Ou on 8/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SaveWritingViewController : UIViewController

@property (strong, nonatomic) IBOutlet PFImageView *chosenImageView;


@property (strong, nonatomic) UIImage *chosenImage;
@property (nonatomic,strong) PFGeoPoint *messageLocation;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) PFObject *selectedMessage;
@property (strong, nonatomic) IBOutlet PFImageView *smallerImageView;

@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property int initialTextLength;

@property (strong, nonatomic) IBOutlet UIButton *anonymousLabel;

@end
