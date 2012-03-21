//
//  LocationController.h
//  iDrank
//
//  Created by Rob Balian on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationController : NSObject <CLLocationManagerDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
	CLLocationManager *locationManager;
    CLLocation *lastLocation;
    NSMutableData *nearbyLocationsData;
    NSString *placeName;
    id delegate;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) id delegate;

+(LocationController *)sharedInstance;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;
-(CLLocation *)getLastLocation;
-(NSArray *)getNearbyPlaces;
-(void)requestNearbyPlaces;
-(void)setPlaceName:(NSString *)name;
-(NSString *)getPlaceName;

@end