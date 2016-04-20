//
//  RunInfo.m
//  BikeTrax
//
//  Created by blair on 4/6/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import "RunInfo.h"
#import "DBManager.h"

@implementation RunInfo


-(NSString *)getDateString
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterMediumStyle];
    return [df stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_timeStamp]];
}

-(NSDictionary*)toDictionary
{
    NSArray *sensorData = [[DBManager getSharedInstance] getRunData:(int)_runID];
    NSMutableArray *runData = [NSMutableArray new];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    for (SensorTagData *data in sensorData)
    {
        [runData addObject:[data toDictionary]];
    }
    
    dict[@"name"] = _name;
    dict[@"timeStamp"] = @(_timeStamp);
    dict[@"desc"] = _desc!= nil?_desc:@"";
    dict[@"runID"] = @(_runID);
    dict[@"sensorData"] = runData;
    dict[@"transfered"] = @(_transfered);
    return [NSDictionary dictionaryWithDictionary:dict];
}


-(NSString *)toJSONString
{
    NSError *error;
    NSDictionary *dict  = [self toDictionary];
    NSData* json = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    // If no errors, let's view the JSON
    if (json != nil && error == nil)
    {
        return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    else
    {
        NSLog (@"error in creating JSON: %@", error);
    }
    
    return nil;
    
}

@end
