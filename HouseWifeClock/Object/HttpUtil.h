//
//  HttpUtil.h
//  HouseWifeClock
//
//  Created by Yang leo on 12-12-3.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ClockObject.h"

#define KDBname @"clock.db"



@interface HttpUtil : NSObject{
    sqlite3 *database;
}

- (void) closeDB;
- (int) openDB;
-(void) createDatabaseIfNeeded:(NSString *)filename;


-(NSArray *)getClockListFromDataBase;
-(NSString *)saveClockObjectToDatabase:(ClockObject *)object;
-(void)updateClockObjectToDatabase:(ClockObject *)object;
-(NSString *)getNewsInsertClockid;
-(BOOL)clockIsExistWithClockid:(NSString *)clockid;
-(void)deleteClockWithClockid:(NSString *)clockid;
-(NSInteger)getClockListCount;

@end
