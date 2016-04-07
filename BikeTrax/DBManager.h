//
//  DBManager.h
//  BikeTrax
//
//  Created by blair on 4/3/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "FMDB/FMDB.h"
//#import <sqlite3.h>

#import "SensorTagData.h"



@interface DBManager : NSObject
@property (nonatomic, assign) BOOL dbOpen;


-(BOOL)  insertTagData:(SensorTagData *)tagData;
-(int)  startRun:(NSString *)runName;
-(NSArray *) getRunData:(int)runID;
-(int)  startRecording:(NSString *)runName;
-(NSArray *) getRuns;
+(DBManager*)getSharedInstance;

@end
