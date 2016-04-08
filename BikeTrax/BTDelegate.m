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
#import "RunInfo.h"
#import "DBManager.h"

#define START_STRING @"{\n \"d\":{\n"
#define VARIABLE_STRING(a,b) [NSString stringWithFormat:@"\"%@\":\"%@\"",a,b]
#define STOP_STRING @"\n}\n}"

@interface BTDelegate()

@property (nonatomic, strong) SensorTagData *tempData;
@property (nonatomic, strong) DBManager *dbm;
@property (nonatomic, assign) BOOL record;
@end

@implementation BTDelegate

+(BTDelegate *) sharedInstance
{
    static BTDelegate *sharedBTDelegate = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedBTDelegate = [self new];
    });
    return sharedBTDelegate;
}

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
        _dbm = [DBManager getSharedInstance];
        _record = NO;
        NSLog(@"OPEN DB:");
    }
    
    return self;
}

-(SensorTagData *)getCurrentData
{
    return _currentData;
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
                if(_buttonDelegate != nil)
                {
                    [serv setButtonDelegate: _buttonDelegate];
                }
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
    _tempData.runID = [_currentRun intValue];
    for (int ii = 0; ii < self.services.count; ii++) {
        bleGenericService *s = [self.services objectAtIndex:ii];
        [s dataUpdate:characteristic withTagData:_tempData];
       
        /** For Cloud sending
        NSArray *arr = [s getCloudData];
        if (arr != nil) {
            for (NSDictionary *dict in arr) {
                
                NSString *name = [dict objectForKey:@"name"];
                NSString *value = [dict objectForKey:@"value"];
                
                self.MQTTStringLive = [self.MQTTStringLive stringByAppendingString:[NSString stringWithFormat:@"%@,\n",[BTDelegate encodeJSONString:name value:value]]];
            }
        }
         **/
    }
   //double diff =  _tempData.timestamp - _currentData.timestamp;
    _currentData = _tempData;
    if(_record)
    {
        [_dbm insertTagData:_currentData];
    }
  //  NSLog(@"Got Notification:*** \n %f %f \n", diff, _currentData.light);
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

-(NSArray *) getRunData:(NSString *)runID;
{
    NSArray *rval = nil;
    rval = [_dbm getRunData:[runID intValue]];
    return rval;
}

-(NSString *) startRecordingWithRunName:(NSString * ) runName
{
    int runId = [_dbm startRun:runName];
    _record = YES;
    //Make the runID
    _currentRun = [NSString stringWithFormat:@"%d",runId];
    
    return _currentRun;
}
-(NSString *) stopRecording;
{
    _record = NO;
    NSString *runId = _currentRun;
  // NSArray *data =  [self getRunData:_currentRun];
    
    //Close the run
    
    _currentRun = nil;
    
    return runId;
}

-(NSArray<RunInfo *> *) getRuns
{
    return [_dbm getRuns];
}
@end
