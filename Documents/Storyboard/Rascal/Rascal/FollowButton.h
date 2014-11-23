//
//  FollowButton.h
//  Rascal
//
//  Created by Phillip Ou on 7/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FollowButton;


@protocol FollowButtonDelegate
-(void) FollowButton: (FollowButton*) button didTapWithSectionIndex: (NSInteger) index;
@end

@interface FollowButton : UIButton
@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, assign) id <FollowButtonDelegate> delegate;

@end
