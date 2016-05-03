//
//  SensorTagData.h
//  BikeTrax
//
//  Created by blair on 4/1/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SensorTagData : NSObject <NSCopying>
//TagData
@property (nonatomic, assign) int runID;
@property (nonatomic, assign) float ambientTemp;
@property (nonatomic, assign) float objectTemp;
@property (nonatomic, assign) float humidity;
@property (nonatomic, assign) float pressure;
@property (nonatomic, assign) float accelX;
@property (nonatomic, assign) float accelY;
@property (nonatomic, assign) float accelZ;
@property (nonatomic, assign) float magX;
@property (nonatomic, assign) float magY;
@property (nonatomic, assign) float magZ;
@property (nonatomic, assign) float gyroX;
@property (nonatomic, assign) float gyroY;
@property (nonatomic, assign) float gyroZ;
@property (nonatomic, assign) float light;
@property (nonatomic, assign) int key1;
@property (nonatomic, assign) int key2;
@property (nonatomic, assign) int reedRelay;
//In Seconds
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) float locX;
@property (nonatomic, assign) float locY;
@property (nonatomic, assign) float locZ;
@property (nonatomic, assign) float speed;
@property (nonatomic, assign) float altitude;


-(NSString *)getOutputString;
-(id) copyWithZone: (NSZone *) zone;
-(NSString *)getDateString;
-(float)getMagAngle;
-(NSDictionary *)toDictionary;
@end
