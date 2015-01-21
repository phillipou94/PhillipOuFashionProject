//
//  ShowItemViewController.h
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol removeBlurDelegate
-(void) removeBlur;
@end

@protocol ShowItemViewControllerLikeDelegate
-(void)removeItemFromMainviewAtIndex:(NSInteger)index;
@end

@protocol ShowItemViewAnimationDelegate
-(void)showConfirmationAnimation;
@end

@interface ShowItemViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSDictionary *item;
@property NSInteger index;
@property (strong, nonatomic) NSString *fromViewController;
@property (nonatomic, assign) id<removeBlurDelegate> delegate;
@property (nonatomic, assign) id<ShowItemViewControllerLikeDelegate>likeDelegate;
@property (nonatomic, assign) id<ShowItemViewAnimationDelegate>animationDelegate;
@property (nonatomic, assign) User *fromUser;
@property (nonatomic, assign) User *toUser;
@property (nonatomic, assign) UIImage *toUserImage;

@end
