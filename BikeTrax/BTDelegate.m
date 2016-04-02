//
//  BTDelegate.m
//  BikeTrax
//
//  Created by blair on 4/1/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import "BTDelegate.h"
#import "sensorTagAmbientTemperatureService.h"
#import "sensorTagAirPressureService.h"
#import "sensorTagHumidityService.h"
#import "sensorTagMovementService.h"
#import "sensorTagLightService.h"
#import "sensorTagKeyService.h"
#import "deviceInformationService.h"

#define START_STRING @"{\n \"d\":{\n"
#define VARIABLE_STRING(a,b) [NSString stringWithFormat:@"\"%@\":\"%@\"",a,b]
#define STOP_STRING @"\n}\n}"

@interface BTDelegate()

@property (nonatomic, strong) SensorTagData *tempData;

@end

@implementation BTDelegate

-(instancetype) init
{
    self = [super init];
    if(self)
    {
        _handler = [bluetoothHandler sharedInstance];
        _handler.delegate = self;
        _services = [NSMutableArray new];
        _deviceSelect = [DeviceSelectTableViewController new];
        _deviceSelect.devSelectDelegate = self;
        _tempData = [SensorTagData new];
    }
    
    return self;
}

+(NSString *) encodeJSONString:(NSString *)name value:(NSString *)value {
    return VARIABLE_STRING(name, value);
}

//Delegate Methods

///Device has become ready, or not ready (connected and scanned / disconnected)
-(void) deviceReady:(BOOL)ready peripheral:(CBPeripheral *)peripheral
{
    if (ready) {
        _connected = YES;
        
        for (CBService *s in peripheral.services) {
            
            if ([sensorTagAmbientTemperatureService isCorrectService:s]) {
                sensorTagAmbientTemperatureService *serv = [[sensorTagAmbientTemperatureService alloc] initWithService:s];
                [self.services addObject:serv];
                [serv configureService];
                            }
            if ([sensorTagAirPressureService isCorrectService:s]) {
                sensorTagAirPressureService *serv = [[sensorTagAirPressureService alloc] initWithService:s];
                [self.services addObject:serv];
                [serv configureService];
                
            }
            if ([sensorTagHumidityService isCorrectService:s]) {
                sensorTagHumidityService *serv = [[sensorTagHumidityService alloc] initWithService:s];
                [self.services addObject:serv];
                [serv configureService];
                
            }
            if ([sensorTagMovementService isCorrectService:s]) {
                sensorTagMovementService *serv = [[sensorTagMovementService alloc] initWithService:s];
                [self.services addObject:serv];
                [serv configureService];
                
            }
            if ([sensorTagLightService isCorrectService:s]) {
                sensorTagLightService *serv = [[sensorTagLightService alloc] initWithService:s];
                [self.services addObject:serv];
                [serv configureService];
                
            }
            if ([deviceInformationService isCorrectService:s]) {
                deviceInformationService *serv = [[deviceInformationService alloc] initWithService:s];
                [self.services addObject:serv];
                [serv configureService];
                           }
            if ([sensorTagKeyService isCorrectService:s]) {
                sensorTagKeyService *serv = [[sensorTagKeyService alloc] initWithService:s];
                [self.services addObject:serv];
                [serv configureService];
            }
        }
    }
    else {
        NSLog(@"Disconnected! ");
        _connected = NO;
    }

}
-(void) didReadCharacteristic:(CBCharacteristic *)characteristic {
    for (int ii = 0; ii < self.services.count; ii++) {
        bleGenericService *s = [self.services objectAtIndex:ii];
        [s dataUpdate:characteristic];
    }
}
-(void) didGetNotificaitonOnCharacteristic:(CBCharacteristic *)characteristic {
    self.MQTTStringLive = [[NSString alloc] init];
    _tempData = [SensorTagData new];
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    _tempData.timestamp = now;
    for (int ii = 0; ii < self.services.count; ii++) {
        bleGenericService *s = [self.services objectAtIndex:ii];
        [s dataUpdate:characteristic];
        NSArray *arr = [s getCloudData];
        if (arr != nil) {
            for (NSDictionary *dict in arr) {
                //Gotta be a different way
                NSString *name = [dict objectForKey:@"name"];
                NSString *value = [dict objectForKey:@"value"];
                if([@"ambientTemp" isEqualToString:name])
                    {
                        _tempData.ambientTemp = [value doubleValue];
                    }
                else
                    if([@"objectTemp" isEqualToString:name])
                    {
                        _tempData.objectTemp = [value doubleValue];
                    }
                else
                    if([@"numidity" isEqualToString:name])
                    {
                        _tempData.humidity = [value doubleValue];
                    }
                else
                    if([@"humidity" isEqualToString:name])
                    {
                        _tempData.humidity = [value doubleValue];
                    }
                    else
                        if([@"pressure" isEqualToString:name])
                        {
                            _tempData.pressure = [value doubleValue];
                        }
                        else
                            if([@"accelX" isEqualToString:name])
                            {
                                _tempData.accelX = [value doubleValue];
                            }
                            else
                                if([@"accelY" isEqualToString:name])
                                {
                                    _tempData.accelY = [value doubleValue];
                                }
                                else
                                    if([@"accelZ" isEqualToString:name])
                                    {
                                        _tempData.accelZ = [value doubleValue];
                                    }
                                    else
                                        if([@"magX" isEqualToString:name])
                                        {
                                            _tempData.magX = [value doubleValue];
                                        }
                                        else
                                            if([@"magY" isEqualToString:name])
                                            {
                                                _tempData.magY = [value doubleValue];
                                            }
                                            else
                                                if([@"magZ" isEqualToString:name])
                                                {
                                                    _tempData.magZ = [value doubleValue];
                                                }
                                                else
                                                    if([@"gyroX" isEqualToString:name])
                                                    {
                                                        _tempData.gyroX = [value doubleValue];
                                                    }
                                                    else
                                                        if([@"gyroY" isEqualToString:name])
                                                        {
                                                            _tempData.gyroY = [value doubleValue];
                                                        }
                                                        else
                                                            if([@"gyroZ" isEqualToString:name])
                                                            {
                                                                _tempData.gyroZ = [value doubleValue];
                                                            }
                                                            else
                                                                if([@"light" isEqualToString:name])
                                                                {
                                                                    _tempData.light = [value doubleValue];
                                                                }
                                                                else
                                                                    if([@"key_1" isEqualToString:name])
                                                                    {
                                                                        _tempData.key1 = [value doubleValue];
                                                                    }
                                                                    else
                                                                        if([@"key_2" isEqualToString:name])
                                                                        {
                                                                            _tempData.key2 = [value doubleValue];
                                                                        }
                                                                        else
                                                                            if([@"reed_relay" isEqualToString:name])
                                                                            {
                                                                                _tempData.reedRelay = [value doubleValue];
                                                                            }


                    
                    
                self.MQTTStringLive = [self.MQTTStringLive stringByAppendingString:[NSString stringWithFormat:@"%@,\n",[BTDelegate encodeJSONString:name value:value]]];
            }
        }
    }
   double diff =  _tempData.timestamp - _currentData.timestamp;
    _currentData = _tempData;
    NSLog(@"Got Notification:*** \n %f %f \n", diff, _currentData.light);
}
-(void) didWriteCharacteristic:(CBCharacteristic *)characteristic error:(NSError *) error {
    for (int ii = 0; ii < self.services.count; ii++) {
        bleGenericService *s = [self.services objectAtIndex:ii];
        [s wroteValue:characteristic error:error];
    }
}

-(void) newDeviceWasSelected:(NSUUID *)identifier {
    self.handler.connectToIdentifier = identifier;
    self.handler.shouldReconnect = YES;
    self.services = [[NSMutableArray alloc] init];
    [ self.deviceSelect.tableView removeFromSuperview];
   
}



@end
