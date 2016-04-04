//
//  DBManager.m
//  BikeTrax
//
//  Created by blair on 4/3/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import "DBManager.h"
#define kDBPath @"BikeTrax.rdb"
@interface DBManager ()

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, assign) int currentRun;

-(BOOL) initDB;

@end


@implementation DBManager


//Need a way to only init once.

-(BOOL) initDB;
{
    [self copyDatabaseIfNeeded];
    return YES;
   }

- (void) copyDatabaseIfNeeded {
    
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
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
    return [documentsDir stringByAppendingPathComponent:kDBPath];
}

-(BOOL) openDB
{
  
    
    [self initDB];
    
    _db = [FMDatabase databaseWithPath:[self getDBPath]];
    
    return [_db open];
}

-(BOOL) closeDB
{
    return [_db close];
}

-(BOOL)  insertTagData:(SensorTagData *)tagData
{
    return NO;
}

-(NSString *)  startRun:(NSString *)runName
{
    return nil;
}

-(NSArray *) getRunData:(NSString *)runName
{
    return nil;
}


@end
