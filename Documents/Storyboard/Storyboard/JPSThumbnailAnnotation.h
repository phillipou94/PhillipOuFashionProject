//
//  JPSThumbnailAnnotation.h
//  Storyview
//
//  Created by Phillip Ou on 8/11/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

@import Foundation;
@import MapKit;
#import "JPSThumbnail.h"


@protocol JPSThumbnailAnnotationProtocol <NSObject>

- (MKAnnotationView *)annotationViewInMap:(MKMapView *)mapView;

@end

@interface JPSThumbnailAnnotation : NSObject <MKAnnotation, JPSThumbnailAnnotationProtocol>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

+ (instancetype)annotationWithThumbnail:(JPSThumbnail *)thumbnail;
- (id)initWithThumbnail:(JPSThumbnail *)thumbnail;
- (void)updateThumbnail:(JPSThumbnail *)thumbnail animated:(BOOL)animated;

@end
