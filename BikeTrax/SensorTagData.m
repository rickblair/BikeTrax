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
    return [NSString stringWithFormat:@"accel X: %4f accel Y: %4f accel Z: %4f gyro X: %4f gyro Y: %4f gyro Z: %4f locX: %6f",
            _accelX,_accelY,_accelZ,_gyroX,_gyroY,_gyroZ, _locX];
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
    newData.speed = _speed;
    newData.altitude = _altitude;
    return newData;
}

-(NSDictionary *)toDictionary
{
    NSMutableDictionary * dict = [NSMutableDictionary new];
    dict[@"runID"] = @(_runID);
    dict[@"ambientTemp"] = @(_ambientTemp);
    dict[@"objectTemp"]= @(_objectTemp);
    dict[@"humidity"] = @(_humidity);
    dict[@"pressure"] = @(_pressure);
    dict[@"accelX"] = @(_accelX);
    dict[@"accelY"] = @(_accelY);
    dict[@"accelZ"] = @(_accelZ);
    dict[@"gyroX"] = @(_gyroX);
    dict[@"gyroY"] = @(_gyroY);
    dict[@"gyroZ"] = @(_gyroZ);
    dict[@"magX"] = @(_magX);
    dict[@"magY"] = @(_magY);
    dict[@"magZ"] = @(_magZ);
    dict[@"key1"] = @(_key1);
    dict[@"key2"] = @(_key2);
    dict[@"reedRelay"] = @(_reedRelay);
    dict[@"timestamp"] = @(_timestamp);
    dict[@"locX"] = @(_locX);
    dict[@"locY"] = @(_locY);
    dict[@"locZ"] = @(_locZ);
    dict[@"speed"] = @(_speed);
    dict[@"altitude"] = @(_altitude);
   
    return [NSDictionary dictionaryWithDictionary:dict];
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
