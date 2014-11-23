//
//  MapViewController.h
//  Storyview
//
//  Created by Phillip Ou on 8/11/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@protocol MyOtherDelegate

-(void)receiveDataFromMap: (float)searchRadius;

@end
@interface MapViewController : UIViewController<MKAnnotation>
@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (strong,nonatomic) NSArray *objects;
@property (strong, nonatomic) PFGeoPoint *userLocation;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (strong, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic) id<MyOtherDelegate> delegate;

@property double searchRadius;


@property (strong, nonatomic) IBOutlet UILabel *searchRadiusLabel;
@end
