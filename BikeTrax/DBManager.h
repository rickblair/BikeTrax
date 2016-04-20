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
#import "RunInfo.h"


@interface DBManager : NSObject
@property (nonatomic, assign) BOOL dbOpen;


-(BOOL)  clearDB;
-(BOOL)  insertTagData:(SensorTagData *)tagData;
-(int)  startRun:(NSString *)runName;
-(NSArray *) getRunData:(int)runID;
-(int)  startRecording:(NSString *)runName;
-(NSArray *) getRuns;
+(DBManager*)getSharedInstance;
-(void) transferRun:(RunInfo *) runInfo;
-(RunInfo *) getRunByID:(NSString *) runID;
@end
