//
//  RunInfo.m
//  BikeTrax
//
//  Created by blair on 4/6/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import "RunInfo.h"

@implementation RunInfo


-(NSString *)getDateString
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterMediumStyle];
    return [df stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:_timeStamp]];
}

@end
