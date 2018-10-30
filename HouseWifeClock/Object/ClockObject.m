//
//  ClockObject.m
//  HouseWifeClock
//
//  Created by Yang leo on 12-11-24.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import "ClockObject.h"

@implementation ClockObject
@synthesize second;
@synthesize clockName;
@synthesize timeLabel;
@synthesize indexPath;
@synthesize delegate;
@synthesize clockid;
@synthesize createDate;
@synthesize isOn;
@synthesize defaultSecond;
@synthesize isPause;


-(id)init{
    self = [super init];
    if(self){
        clockName = @"";
    }
    return self;
}

-(void)subSecond{
    if(!isOn){
        return;
    }
    
    if(isPause){
        return;
    }
    
    if(second > 0){
        second--;
        [delegate clockObjectSubSecond:indexPath];
    }
}


-(void)dealloc{
    [createDate release];
    [clockid release];
    [indexPath release];
    [timeLabel release];
    [clockName release];
    [super dealloc];
}

@end
