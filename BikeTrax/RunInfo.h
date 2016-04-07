//
//  RunInfo.h
//  BikeTrax
//
//  Created by blair on 4/6/16.
//  Copyright © 2016 Blair, Rick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunInfo : NSObject

@property(nonatomic,strong)NSString * name;
@property(nonatomic, assign) double timeStamp;
@property (nonatomic, strong) NSString *desc;

-(NSString *)getDateString;

@end
