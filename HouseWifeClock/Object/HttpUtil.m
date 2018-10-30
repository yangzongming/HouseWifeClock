//
//  HttpUtil.m
//  HouseWifeClock
//
//  Created by Yang leo on 12-12-3.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import "HttpUtil.h"

@implementation HttpUtil


#pragma mark 打开数据库
- (int) openDB {
	
	[self createDatabaseIfNeeded:KDBname];
	NSString *dbpath;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	dbpath = [documentsDirectory stringByAppendingPathComponent:KDBname];
	
	//dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AssistantMark.sqlite" ];
	
	if (sqlite3_open([dbpath UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
	else
	{
		//NSLog(@"Open Data Writabledatabase DB Successful");
	}
	return 1;
}

- (void) closeDB {
	sqlite3_close(database);
}
-(void) createDatabaseIfNeeded:(NSString *)filename{
	BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:filename];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success){
		return;
    }
	//NSLog([@"Copy File " stringByAppendingString:filename]);
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
		return;
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}




#pragma mark ******************************************
#pragma mark ******************************************
#pragma mark－－－－－ 闹钟相关数据库操作
#pragma mark ******************************************
#pragma mark ******************************************


#pragma mark 获取老数据库存稿信息
-(NSArray *)getClockListFromDataBase{
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
    NSString *sqlString=[NSString stringWithFormat:@"select * from clock order by createdate asc"];
    sqlite3_stmt *select_statement = nil;
    const char *sql_char=[sqlString UTF8String];
    int returnValue = sqlite3_prepare_v2(database, sql_char, -1, &select_statement, NULL);
    if(returnValue == SQLITE_OK){
        while(sqlite3_step(select_statement) == SQLITE_ROW)
        {
            ClockObject *clock = [[ClockObject alloc] init];
            NSString *clockid= [NSString stringWithUTF8String:(char *)sqlite3_column_text(select_statement, 0)];
            NSString *clockname= [NSString stringWithUTF8String:(char *)sqlite3_column_text(select_statement, 1)];
            NSString *second= [NSString stringWithUTF8String:(char *)sqlite3_column_text(select_statement, 2)];
            NSString *createdate= [NSString stringWithUTF8String:(char *)sqlite3_column_text(select_statement, 3)];
            
            [clock setClockid:clockid];
            [clock setClockName:clockname];
            [clock setSecond:[second integerValue]];
            [clock setDefaultSecond:[second integerValue]];
            [clock setCreateDate:createdate];
            
            [dataArray addObject:clock];
            [clock release];
        }
    }
    return dataArray;
}



-(NSString *)saveClockObjectToDatabase:(ClockObject *)object{
    
    if([self clockIsExistWithClockid:object.clockid]){
        [self updateClockObjectToDatabase:object];
        return object.clockid;
        //存在了 需要更新
    }
    sqlite3_stmt *insert_statement = nil;
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO clock (clockname,second,createdate) VALUES (?,?,?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
        }
    }
    sqlite3_bind_text(insert_statement, 1, [[object clockName] UTF8String], 256, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 2, [[NSString stringWithFormat:@"%d",[object defaultSecond]] UTF8String], -1, SQLITE_TRANSIENT);
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    [dateFormat setAMSymbol:@"AM"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    [dateFormat release];
    
    sqlite3_bind_text(insert_statement, 3, [dateString UTF8String], 256, SQLITE_TRANSIENT);
    
    int success = sqlite3_step(insert_statement);
    sqlite3_finalize(insert_statement);
    
    insert_statement=nil;
    if (success == SQLITE_ERROR) {
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
    }else{
        //NSLog(@"pass insert");
    }
    
    return [self getNewsInsertClockid];
}

-(void)updateClockObjectToDatabase:(ClockObject *)object{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    [dateFormat setAMSymbol:@"AM"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    [dateFormat release];
    
	NSString *update = [NSString stringWithFormat:@"update clock set clockname='%@',second='%@',createdate='%@' where clockid= %d ",
						object.clockName,
                        [NSString stringWithFormat:@"%d",object.defaultSecond],
                        dateString,
                        [object.clockid intValue]];
    if (sqlite3_exec(database, [update UTF8String], NULL, NULL, nil) == SQLITE_OK) {
    }
    else {
    }
}

-(NSString *)getNewsInsertClockid{
    NSString *_draftid = nil;
    NSString *sqlString=[NSString stringWithFormat:@"select * from clock order by createdate desc"];
    sqlite3_stmt *select_statement = nil;
    const char *sql_char=[sqlString UTF8String];
    int returnValue = sqlite3_prepare_v2(database, sql_char, -1, &select_statement, NULL);
    if(returnValue == SQLITE_OK){
        while(sqlite3_step(select_statement) == SQLITE_ROW)
        {
            int draftid = sqlite3_column_int(select_statement,0);
            _draftid = [NSString stringWithFormat:@"%d",draftid];
            break;
        }
    }
    return _draftid;
}

-(BOOL)clockIsExistWithClockid:(NSString *)clockid{
    if(clockid == nil)
        return NO;
    BOOL flag = NO;
    NSString *sqlString=[NSString stringWithFormat:@"select * from clock where clockid = %d",[clockid intValue]];
    sqlite3_stmt *select_statement = nil;
    const char *sql_char=[sqlString UTF8String];
    int returnValue = sqlite3_prepare_v2(database, sql_char, -1, &select_statement, NULL);
    if(returnValue == SQLITE_OK){
        while(sqlite3_step(select_statement) == SQLITE_ROW)
        {
            flag = YES;
        }
    }
    return flag;
}

-(void)deleteClockWithClockid:(NSString *)clockid{
    sqlite3_stmt *delete_statement = nil;
	if (delete_statement == nil) {
		NSString *SQL=[NSString stringWithFormat:@"delete from clock where clockid=%d",[clockid intValue]];
		const char *sql = [SQL UTF8String];
		if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
	}
	sqlite3_step(delete_statement);
	sqlite3_finalize(delete_statement);
}
//获取存稿箱数据
-(NSInteger)getClockListCount{
    NSInteger count = 0;
    NSString *sqlString=[NSString stringWithFormat:@"select clockid from clock"];
    sqlite3_stmt *select_statement = nil;
    const char *sql_char=[sqlString UTF8String];
    int returnValue = sqlite3_prepare_v2(database, sql_char, -1, &select_statement, NULL);
    if(returnValue == SQLITE_OK){
        while(sqlite3_step(select_statement) == SQLITE_ROW)
        {
            count++;
        }
    }
    return count;
}


@end
