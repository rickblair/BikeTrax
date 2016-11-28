//
//  LocationServices.m
//  BikeTrax
//
//  Created by blair on 4/22/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import "LocationServices.h"

@interface LocationServices ()

@property (nonatomic, strong) CLLocationManager* myLocManager;
@end

@implementation LocationServices



static LocationServices *sharedService = nil;
static dispatch_once_t onceToken;

+(LocationServices *)sharedLocationServices
{
    dispatch_once(&onceToken, ^{
        sharedService= [self new];
        
    });
    return sharedService;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        _currentLoc = nil;
    }
    return self;
}

-(void)startUpdatingLocation
{
    if(_myLocManager == nil)
    {
        _myLocManager = [CLLocationManager new];
        _myLocManager.delegate = self;
        _myLocManager.desiredAccuracy = kCLLocationAccuracyBest;
        _myLocManager.distanceFilter = kCLDistanceFilterNone;
        [_myLocManager requestAlwaysAuthorization];
    }
   
    [_myLocManager startUpdatingLocation];
    
}
-(void)stopUpdatingLocation
{
    [_myLocManager stopUpdatingLocation];
    _currentLoc = nil;
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
   
    NSLog(@"Error: %@",error.description);
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"Got %lu locations",(unsigned long)locations.count);
    _currentLoc = locations[locations.count -1];
}


@end
