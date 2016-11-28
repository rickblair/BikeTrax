//
//  DBManager.m
//  BikeTrax
//
//  Created by blair on 4/3/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import "DBManager.h"
#import "RunInfo.h"
#import <sqlite3.h>
#define kDBPath @"BikeTrax.rdb"


static sqlite3 *database = nil;
static DBManager *sharedInstance = nil;
static sqlite3_stmt *statement = nil;

@interface DBManager ()

//@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, assign) int currentRun;
@property (nonatomic, strong) NSString *dbPath;

-(BOOL) initDB;

@end


@implementation DBManager

//Make this a true singleton
+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance initDB];
    }
    return sharedInstance;
}


//Need a way to only init once.

-(BOOL) initDB;
{
    [self copyDatabaseIfNeeded:NO];
    _dbPath = [self getDBPath];
    _currentRun = -1;
    return YES;
}

-(BOOL)  clearDB
{
    [self copyDatabaseIfNeeded:YES];
    _dbPath = [self getDBPath];
    _currentRun = -1;
    return YES;
}

- (void) copyDatabaseIfNeeded:(BOOL)force {
    
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *dbPath = [self getDBPath];
    if(force)
    {
        [fileManager removeItemAtPath:dbPath error:&error];
    }
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success || force) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDBPath];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

- (NSString *) getDBPath
{
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    //NSLog(@"dbpath : %@",documentsDir);
    NSString *rval = [documentsDir stringByAppendingPathComponent:kDBPath];
    NSLog(@"DBPath = ** %@ **", rval);
    return rval;
}


-(BOOL)  insertTagData:(SensorTagData *)tagData
{
    
    BOOL rval = NO;
    NSString * sql = [NSString stringWithFormat:@"INSERT into runData (runID, timeStamp, ambientTemp, objectTemp,\
                      humidity, pressure, accelX, accelY, accelZ, magX, magY, magZ, gyroX, gyroY, gyroZ, light,\
                      key1, key2, reedRelay, locX, locY, locZ, speed, altitude) VALUES (%d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f,\
                      %f, %f, %f, %f, %f, %d, %d, %d, %f, %f, %f, %f, %f)",_currentRun, tagData.timestamp, tagData.ambientTemp,\
                      tagData.objectTemp, tagData.humidity, tagData.pressure, tagData.accelX, tagData.accelY,\
                      tagData.accelZ, tagData.magX, tagData.magY, tagData.magZ, tagData.gyroX,tagData.gyroY,\
                      tagData.gyroZ, tagData.light, tagData.key1, tagData.key2, tagData.reedRelay, tagData.locX, tagData.locY,\
                      tagData.locZ,tagData.speed,tagData.altitude];
                      
                      
                      
                      
                      
    if (sqlite3_open([_dbPath UTF8String], &database) == SQLITE_OK)
    {
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
           // NSLog(@"Insert Done: %@",sql);
        }
        else{
            NSLog(@"SQL Error in insert: %@",sql);
        }
        sqlite3_finalize(statement);
        
       
        sqlite3_close(database);
        rval = YES;
    }
   // NSLog(@"Insert Returning %d",rval);
    
    return rval;
}

-(int)  startRun:(NSString *)runName
{
    double tnow = [NSDate timeIntervalSinceReferenceDate];
    int rval = -1;
    NSString * sql = [NSString stringWithFormat:@"INSERT into RUN (time, name, description) VALUES(%f,\"%@\",\"NULL\")",tnow,runName];
    if (sqlite3_open([_dbPath UTF8String], &database) == SQLITE_OK)
    {
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
          //  NSLog(@"Insert Done: %@",sql);
        }
        else{
            NSLog(@"SQL Error in insert: %@",sql);
        }
        sqlite3_finalize(statement);
        rval = (int)sqlite3_last_insert_rowid(database);
        _currentRun = rval;
        sqlite3_close(database);
    }
  //  NSLog(@"Insert Returning %d",rval);
        return rval;
}

-(int)  startRecording:(NSString *)runName
{
    return [self startRun:runName];
}

-(void) transferRun:(RunInfo *) runInfo
{
    NSString *sql = [NSString stringWithFormat:@"UPDATE RUN set transfered = 1 where serial = %ld",runInfo.runID];
    if (sqlite3_open([_dbPath UTF8String], &database) == SQLITE_OK)
    {
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
          //  NSLog(@"Insert Done: %@",sql);
        }
        else{
            NSLog(@"SQL Error in insert: %@",sql);
        }
        sqlite3_finalize(statement);
        
        sqlite3_close(database);
    }
}
-(NSArray * ) getRuns
{
    NSString *sql = @"Select * from RUN";
    sqlite3_stmt    *statement = NULL;
   
    NSMutableArray *vals = [NSMutableArray new];
    if (sqlite3_open([_dbPath UTF8String], &database) == SQLITE_OK)
    {
        const char *query = [sql UTF8String];
        sqlite3_prepare_v2(database, query,
                           -1, &statement, NULL);
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            RunInfo *info = [RunInfo new];
            info.runID = sqlite3_column_int64(statement, 0);
            info.timeStamp = sqlite3_column_double(statement, 1);
            info.name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
            info.desc = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
            info.transfered = sqlite3_column_int(statement, 4 );
            [vals addObject:info];
         //   NSLog(@"Got Value: %D:%@ for time %@", info.runID, info.name, [info getDateString]);
            
        }
        sqlite3_finalize(statement);

        sqlite3_close(database);
    }
        return [NSArray arrayWithArray:vals];
}

-(RunInfo *) getRunByID:(NSString *) runID
{
    NSString *sql = [NSString stringWithFormat:@"Select * from RUN where serial = %@", runID];
    sqlite3_stmt    *statement = NULL;
    RunInfo * info = nil;
    NSMutableArray *vals = [NSMutableArray new];
    if (sqlite3_open([_dbPath UTF8String], &database) == SQLITE_OK)
    {
        const char *query = [sql UTF8String];
        sqlite3_prepare_v2(database, query,
                           -1, &statement, NULL);
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            info = [RunInfo new];
            info.runID = sqlite3_column_int64(statement, 0);
            info.timeStamp = sqlite3_column_double(statement, 1);
            info.name = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
            info.desc = [NSString stringWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
            info.transfered = sqlite3_column_int(statement, 4 );
            [vals addObject:info];
            //   NSLog(@"Got Value: %D:%@ for time %@", info.runID, info.name, [info getDateString]);
            
        }
        sqlite3_finalize(statement);
        
        sqlite3_close(database);
    }
    return info;

}
-(NSArray *) getRunData:(int)runID
{
    NSString *sql = [NSString stringWithFormat:@"Select * from runData where runID = %d",runID];
    sqlite3_stmt    *statement;
    NSMutableArray *vals = [NSMutableArray new];
    if (sqlite3_open([_dbPath UTF8String], &database) == SQLITE_OK)
    {
        const char *insert_stmt = [sql UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,
                           -1, &statement, NULL);
       
        while (sqlite3_step(statement) == SQLITE_ROW) //get each row in loop
        {
            SensorTagData *data = [SensorTagData new];
            data.runID = sqlite3_column_int(statement, 1);
            data.timestamp = sqlite3_column_double(statement, 2);
            data.ambientTemp = sqlite3_column_double(statement, 3);
            data.objectTemp = sqlite3_column_double(statement, 4);
            data.humidity = sqlite3_column_double(statement, 5);
            data.pressure = sqlite3_column_double(statement, 6);
            data.accelX = sqlite3_column_double(statement, 7);
            data.accelY = sqlite3_column_double(statement, 8);
            data.accelZ = sqlite3_column_double(statement, 9);
            data.magX = sqlite3_column_double(statement, 10);
            data.magY = sqlite3_column_double(statement, 11);
            data.magZ = sqlite3_column_double(statement, 12);
            data.gyroX =sqlite3_column_double(statement, 13);
            data.gyroY = sqlite3_column_double(statement, 14);
            data.gyroZ = sqlite3_column_double(statement, 15);
            data.light = sqlite3_column_double(statement, 16);
            data.key1 = sqlite3_column_int(statement, 17);
            data.key2 = sqlite3_column_int(statement, 18);
            data.reedRelay = sqlite3_column_int(statement, 19);
            data.locX = sqlite3_column_double(statement, 20);
            data.locY = sqlite3_column_double(statement, 21);
            data.locZ = sqlite3_column_double(statement, 22);
            data.speed = sqlite3_column_double(statement, 23);
            data.altitude = sqlite3_column_double(statement, 24);
            [vals addObject:data];

        }
        sqlite3_finalize(statement);
    }
    
    sqlite3_close(database);
    
        return [NSArray arrayWithArray:vals];
}


@end
