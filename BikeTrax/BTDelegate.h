//
//  BTDelegate.h
//  BikeTrax
//
//  Created by blair on 4/1/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "blueToothHandler.h"
#import "DeviceSelectTableViewController.h"
#import "SensorTagData.h"
#import "RunInfo.h"

@interface BTDelegate : NSObject < bluetoothHandlerDelegate,deviceSelectTableViewControllerDelegate>



@property (nonatomic, strong) bluetoothHandler *handler;
@property (nonatomic, strong) NSMutableArray *services;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, strong) NSString *MQTTStringLive;
@property (nonatomic, strong) DeviceSelectTableViewController *deviceSelect;
@property (atomic, strong) SensorTagData *currentData;
@property (nonatomic, strong) NSString *currentRun;
@property (nonatomic, weak) id<ButtonProtocol>buttonDelegate;
//

+(NSString *) encodeJSONString:(NSString *)name value:(NSString *)value;

-(void) newDeviceWasSelected:(NSUUID *)identifier;
-(NSString *) startRecordingWithRunName:(NSString * ) runName;
-(NSString *) stopRecording;
-(NSArray *) getRunData:(NSString *) runID;
-(NSArray <RunInfo *> *) getRuns;
-(SensorTagData *)getCurrentData;
-(RunInfo *) getRunByID:(NSString *)runID;

+(BTDelegate *)sharedInstance;

-(BOOL) clearDB;

@end
