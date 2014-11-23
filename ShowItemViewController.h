//
//  ShowItemViewController.h
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/25/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol removeBlurDelegate
-(void) removeBlur;
@end


@interface ShowItemViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSDictionary *item;
@property (nonatomic, assign) id<removeBlurDelegate> delegate;

@end
