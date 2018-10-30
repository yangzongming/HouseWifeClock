//
//  ClockObject.h
//  HouseWifeClock
//
//  Created by Yang leo on 12-11-24.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ClockObjectDelegate <NSObject>

-(void)clockObjectSubSecond:(NSIndexPath *)indexpath;

@end


@interface ClockObject : NSObject{
    NSString *clockid;
    NSString *clockName;
    NSInteger second;
    NSInteger defaultSecond;
    NSString *createDate;
    
    UILabel *timeLabel;
    
    NSIndexPath *indexPath;
    id<ClockObjectDelegate> delegate;
    
    BOOL isOn;
    BOOL isPause;
}

@property (nonatomic,retain)NSString *clockid;
@property (nonatomic,retain)NSString *clockName;
@property (nonatomic,retain)NSString *createDate;
@property (nonatomic,assign) NSInteger second;
@property (nonatomic,assign)NSInteger defaultSecond;
@property (nonatomic,retain)UILabel *timeLabel;
@property (nonatomic,retain)NSIndexPath *indexPath;
@property (nonatomic,assign)id<ClockObjectDelegate> delegate;
@property (nonatomic,assign)BOOL isOn;
@property (nonatomic,assign)BOOL isPause;

-(void)subSecond;

@end
