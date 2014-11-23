//
//  JPSThumbnail.h
//  Storyview
//
//  Created by Phillip Ou on 8/11/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

typedef void (^ActionBlock)();

@interface JPSThumbnail : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) ActionBlock disclosureBlock;

@end
