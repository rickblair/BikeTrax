//
//  LocationServices.h
//  BikeTrax
//
//  Created by blair on 4/22/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationServices : NSObject <CLLocationManagerDelegate>

@property (atomic, strong) CLLocation* currentLoc;

+(LocationServices *)sharedLocationServices;
-(void)startUpdatingLocation;
-(void)stopUpdatingLocation;

@end
