//
//  GeoPointAnnotation.h
//  Storyview
//
//  Created by Phillip Ou on 8/11/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface GeoPointAnnotation : NSObject <MKAnnotation>

- (id)initWithObject:(PFObject *)aObject;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

@property (nonatomic, strong) PFObject *object;
@property (nonatomic, strong) PFObject *objectAcquired;
@property (nonatomic, strong) PFImageView *image;

@end

