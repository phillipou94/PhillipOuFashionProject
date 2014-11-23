//
//  SaveButton.h
//  Rascal
//
//  Created by Phillip Ou on 7/7/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SaveButton;
@protocol SaveButtonDelegate
-(void) saveButton: (SaveButton*) button didTapWithSectionIndex: (NSInteger) index;

@end


@interface SaveButton : UIButton
@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, weak) id <SaveButtonDelegate> delegate;
@end
