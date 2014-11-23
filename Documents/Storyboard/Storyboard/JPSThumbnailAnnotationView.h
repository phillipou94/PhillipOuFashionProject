//
//  JPSThumbnailAnnotationView.h
//  Storyview
//
//  Created by Phillip Ou on 8/11/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

@import MapKit;

@class JPSThumbnail;

extern NSString * const kJPSThumbnailAnnotationViewReuseID;

typedef NS_ENUM(NSInteger, JPSThumbnailAnnotationViewAnimationDirection) {
    JPSThumbnailAnnotationViewAnimationDirectionGrow,
    JPSThumbnailAnnotationViewAnimationDirectionShrink,
};

typedef NS_ENUM(NSInteger, JPSThumbnailAnnotationViewState) {
    JPSThumbnailAnnotationViewStateCollapsed,
    JPSThumbnailAnnotationViewStateExpanded,
    JPSThumbnailAnnotationViewStateAnimating,
};

@protocol JPSThumbnailAnnotationViewProtocol <NSObject>

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView;
- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView;

@end

@interface JPSThumbnailAnnotationView : MKAnnotationView <JPSThumbnailAnnotationViewProtocol>

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

- (void)updateWithThumbnail:(JPSThumbnail *)thumbnail;

@end
