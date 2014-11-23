//
//  FollowButton.m
//  Rascal
//
//  Created by Phillip Ou on 7/2/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "FollowButton.h"

@implementation FollowButton

//use initWithCoder instead of initWithFrame because it is initialized with storyboard
-(id) initWithCoder:(NSCoder *)aDecoder{
    if (self == [super initWithCoder:aDecoder]){
        [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
//called every time button is pressed
-(void) buttonPressed{
    [self.delegate FollowButton:self didTapWithSectionIndex:self.sectionIndex];//self.sectionIndex initiated at .h file (starts at 0)
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
