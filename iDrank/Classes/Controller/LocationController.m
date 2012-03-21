//
//  LocationController.m
//  iDrank
//
//  Created by Rob Balian on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationController.h"
#import "JSON.h"
#import "iDrankAppDelegate.h"

@implementation LocationController

@synthesize locationManager, delegate;

static LocationController *LCInstance;


+ (LocationController *)getInstance {
    if (LCInstance == nil) {
        LCInstance = [[LocationController alloc] init];
    }
    return LCInstance;
}

+(LocationController *)sharedInstance {
    
	static LocationController *_sharedInstance;
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
        });
    }
    return _sharedInstance;
}

- (id) init {
    self = [super init];
    if (self != nil) {
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        self.locationManager.delegate = self; // send loc updates to myself
        lastLocation = nil;//[[CLLocation alloc] initWithLatitude:0.0 longitude:0.0];
    }
    return self;
}

-(CLLocation *)getLastLocation {
    return lastLocation;
}

-(NSArray *)getNearbyPlaces {
    
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dict = [[parser objectWithString:[[NSString alloc] initWithData:nearbyLocationsData encoding:NSASCIIStringEncoding] ] retain];
    if ([((NSNumber *)[[dict objectForKey:@"meta"] objectForKey:@"code"]) intValue] == 200) {
        return [[dict objectForKey:@"response"]objectForKey:@"venues"];
    }
    
    
    
    //[self requestNearbyPlaces];
    NSLog(@"Foursquare response error!");
    //NSLog(@"%@", [dict objectForKey:@"response"]);
    return [[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[[[NSString alloc] initWithString:@"Unknown"] retain] forKey:@"name"]] retain];
}

-(void)requestNearbyPlaces {
    NSString *urlStr = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&oauth_token=THDFFMXFX1BXN2NZ41VJHPR43KCBGPQ30PFJKFA55LT3N51E&v=20120320", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:req delegate:self startImmediately:YES];
    
    if (conn) {
        nearbyLocationsData = [[NSMutableData alloc] init];
    }
}

-(void)setPlaceName:(NSString *)name {
    placeName = name;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"locationChanged" object:self];
}

-(NSString *)getPlaceName {
    if (placeName == NULL) return @"Unknown";
    return placeName;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [nearbyLocationsData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"CLLocationController: nearby locations loaded!");
    //NSLog(@"Autosetting place to : %@", [[[self getNearbyPlaces] objectAtIndex:0] objectForKey:@"name"]);
    [self setPlaceName:[[[self getNearbyPlaces] objectAtIndex:0] objectForKey:@"name"] ];
    
    //NSLog(@"%@", [[NSString alloc] initWithData:nearbyLocationsData encoding:NSASCIIStringEncoding]);
    //[(iDrankAppDelegate *)delegate nearbyPlacesUpdated];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"CLLocationController: conneciton error!");
    NSLog(@"%@", [error userInfo]);
}

- (void)locationManager:(CLLocationManager *)manager
didUpdateToLocation:(CLLocation *)newLocation
fromLocation:(CLLocation *)oldLocation
{
   // NSLog(@"Location: %@", [newLocation description]);
    if (newLocation.horizontalAccuracy < 100.0) {
        if (lastLocation == nil) {
            lastLocation = [newLocation copy];
            [self requestNearbyPlaces];
        }
        [locationManager stopUpdatingLocation];
        lastLocation = [newLocation copy];    
    }
    //if (lastLocation.horizontalAccuracy < 100
}

- (void)locationManager:(CLLocationManager *)manager
didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
}

- (void)dealloc {
    [self.locationManager release];
    [super dealloc];
}

@end