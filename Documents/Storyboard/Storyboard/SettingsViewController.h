//
//  SettingsViewController.h
//  Storyboard
//
//  Created by Phillip Ou on 8/6/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyDataDelegate

- (void)recieveData:(float)searchRadius;

@end
@protocol MyPreferenceDelegate
-(void) receivePreference: (int) indexNum;
@end
@interface SettingsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UILabel *radiusLabel;
@property (nonatomic) id<MyDataDelegate> delegate;
@property (nonatomic) id<MyPreferenceDelegate> preferenceDelegate;
@property float searchRadius;

@property (strong, nonatomic) IBOutlet UISwitch *anonSwitch;

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;

@property (strong, nonatomic) IBOutlet UIImageView *anonymousLabel;

@property (strong, nonatomic) IBOutlet UIButton *privacyPolicyButton;

@property (strong, nonatomic) IBOutlet UITextView *privacyPolicy;

@end
