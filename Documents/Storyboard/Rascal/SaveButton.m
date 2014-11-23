//
//  SaveButton.m
//  Rascal
//
//  Created by Phillip Ou on 7/8/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "SaveButton.h"

@implementation SaveButton

/*- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}*/

-(id)initWithCoder: (NSCoder *)aDecoder{
    if (self ==[super initWithCoder:aDecoder]){
        [self addTarget:self action:@selector(buttonPressed) forControlEvents: UIControlEventTouchUpInside];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void) buttonPressed{
    [self.delegate saveButton: self didTapWithSectionIndex:self.sectionIndex];
}



@end
