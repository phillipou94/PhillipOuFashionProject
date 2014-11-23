//
//  CreateViewController.h
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/29/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@end
