//
//  GeoPointAnnotation.m
//  Storyview
//
//  Created by Phillip Ou on 8/11/14.
//  Copyright (c) 2014 Philip Ou. All rights reserved.
//

#import "GeoPointAnnotation.h"

@interface GeoPointAnnotation()

@end

@implementation GeoPointAnnotation



#pragma mark - Initialization

- (id)initWithObject:(PFObject *)aObject {
    self = [super init];
    if (self) {
        _object = aObject;
        
        PFGeoPoint *geoPoint = self.object[@"location"];
        [self setGeoPoint:geoPoint];
    }
    return self;
}


#pragma mark - MKAnnotation

// Called when the annotation is dragged and dropped. We update the geoPoint with the new coordinates.
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
    [self setGeoPoint:geoPoint];
    [self.object setObject:geoPoint forKey:@"location"];
    [self.object saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Send a notification when this geopoint has been updated. MasterViewController will be listening for this notification, and will reload its data when this notification is received.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"geoPointAnnotiationUpdated" object:self.object];
        }
    }];
}


#pragma mark - ()

- (void)setGeoPoint:(PFGeoPoint *)geoPoint {
    _coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    
    static NSNumberFormatter *numberFormatter = nil;
    if (numberFormatter == nil) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.maximumFractionDigits = 3;
    }
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM/dd 'at' hh mm" options:0 locale:nil];
    
    [formatter setDateFormat:dateFormat];
   
    
    _subtitle = [formatter stringFromDate:self.object.createdAt];
    _title = self.object[@"title"];
    _objectAcquired = self.object;
    
    
    
}

@end