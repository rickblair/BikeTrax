//
//  SensorTagData.m
//  BikeTrax
//
//  Created by blair on 4/1/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import "SensorTagData.h"

@implementation SensorTagData

-(NSString *)getOutputString
{
    return [NSString stringWithFormat:@"accel X: %4f accel Y: %4f accel Z: %4f",_accelX,_accelY,_accelZ];
}

@end
