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
    return [NSString stringWithFormat:@"accel X: %4f accel Y: %4f accel Z: %4f mag X: %4f mag Y: %4f mag Z: %4f Direction: %2f",
            _accelX,_accelY,_accelZ,_magX,_magY,_magZ, [self getMagAngle]];
}

-(id) copyWithZone: (NSZone *) zone
{
    SensorTagData *newData = [SensorTagData new];
    
    newData.runID = _runID;
    newData.ambientTemp = _ambientTemp;
    newData.objectTemp = _objectTemp;
    newData.humidity = _humidity;
    newData.pressure = _pressure;
    newData.accelX = _accelX;
    newData.accelY = _accelY;
    newData.accelZ = _accelZ;
    newData.magX= _magX;
    newData.magY = _magY;
    newData.magZ = _magZ;
    newData.gyroX = _gyroX;
    newData.gyroY = _gyroY;
    newData.gyroZ = _gyroZ;
    newData.light = _light;
    newData.key1 = _key1;
    newData.key2 = _key2;
    newData.reedRelay = _reedRelay;
    newData.timestamp = _timestamp;
    newData.locX = _locX;
    newData.locY = _locY;
    newData.locZ = _locZ;
    return newData;
}

-(float)getMagAngle
{
    double xovery = _magX/_magY;
    
    if(_magY >0)
    {
        return 90 - atan(xovery) * 180/M_PI;
    }
    
    if(_magY < 0)
    {
        return 270 - atan(xovery) * 180/M_PI;
    }
    
    if(_magY==0 && _magX < 0)
    {
        return 180.0;
    }
    
    return 0;
}

-(NSString *)getDateString
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy/MM/dd hh:mm:ss.SSSS"];
    return [df stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_timestamp]];
}

@end
