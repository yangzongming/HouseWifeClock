//
//  AppDelegate.m
//  HouseWifeClock
//
//  Created by leo on 12-11-23.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate
@synthesize httpUtil;
@synthesize player;


- (void)dealloc
{
    [player release];
    [httpUtil closeDB];
    [httpUtil release];
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self initData];
    
    [self loadNavigationBar];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    [nav.navigationBar setBarStyle:UIBarStyleBlack];
    self.window.rootViewController = nav;
    [nav release];
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)initData{
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"fitst"] == -2){
        //非第一次进入程序
    }else{
        //第一次进入程序
    }
    
    NSArray *array = [UIFont familyNames];
    for(int i=0;i<[array count];++i){
        NSLog(@"%@",[array objectAtIndex:i]);
    }
    
    if(httpUtil == nil){
        HttpUtil *http = [[HttpUtil alloc] init];
        self.httpUtil = http;
        [http release];
    }
    [httpUtil openDB];
}

#pragma mark --- 加载Navigationbar状态
-(void)loadNavigationBar{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"title_main.png"] forBarMetrics:UIBarMetricsDefault];
    }
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClockAppDidEnterBackground" object:nil];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClockAppWillEnterForeground" object:nil];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark- 增加本地通知

-(void)addLoocalNotification{
    
    //一天　３天　５天　１０天　１５天　３０天　３５天　４５天　６０天
    NSArray *days = [NSArray arrayWithObjects:@"1",@"3",@"5",@"10",@"15",@"30",@"35",@"45",@"60",nil];
    
    for(int i=0;i<[days count];++i){
        UILocalNotification *newNotification = [[UILocalNotification alloc] init];
        if (newNotification) {
            int randomHouts = 0;
            newNotification.fireDate = [NSDate dateWithTimeInterval:randomHouts+60*60*24*[[days objectAtIndex:i] intValue] sinceDate:[NSDate date]];
            newNotification.soundName = @"e3.wav";
            newNotification.alertBody = @"好久没来谈古筝了，快来弹奏一曲吧";
            [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
        }
        NSLog(@"Post new localNotification:%@", [newNotification fireDate]);
        [newNotification release];
    }
}


#pragma mark- 增加一个闹钟

-(void)addNewLocalClockNotificationWithClockObject:(ClockObject *)clockObj{
    
    [self cancelLocalClockNotifationWithClockObject:clockObj];
    
    UILocalNotification *newNotification = [[UILocalNotification alloc] init];
    if (newNotification) {
        newNotification.fireDate = [NSDate dateWithTimeInterval:clockObj.second-1 sinceDate:[NSDate date]];
        newNotification.hasAction = NO;
        //newNotification.repeatInterval = kCFCalendarUnitMinute;
        newNotification.alertBody = clockObj.clockName;
        newNotification.alertAction = @"取消";
        newNotification.soundName = @"welcom.mp3";
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:clockObj.clockid,@"clockid",clockObj.clockName,@"clockname",nil];
        [newNotification setUserInfo:dic];
        [[UIApplication sharedApplication] scheduleLocalNotification:newNotification];
    }
    NSLog(@"Post new localNotification:%@", [newNotification fireDate]);
    NSLog(@"Now : %@",[NSDate date]);
    [newNotification release];
}

-(void)cancelLocalClockNotifationWithClockObject:(ClockObject *)clockObj{
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for(UILocalNotification *notification in localNotifications)
    {
        //[[UIApplication sharedApplication] cancelLocalNotification:notification];
        NSDictionary *dic = [notification userInfo];
        if([[dic objectForKey:@"clockid"] isEqualToString:clockObj.clockid]){
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    UIApplicationState state = application.applicationState;
    if (state == UIApplicationStateActive) {
        NSDictionary *dic = [notification userInfo];
        
        NSURL *u2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"welcom" ofType:@"mp3"]];
        AVAudioPlayer *p2 = [[AVAudioPlayer alloc] initWithContentsOfURL:u2 error:nil];
        [p2 setDelegate:self];
        [p2 setNumberOfLoops:0];
        [p2 setVolume:1];
        self.player = p2;
        [p2 release];
        [player prepareToPlay];
        [player play];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertBody
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"关闭"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [player stop];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClockAppWillEnterForeground" object:nil];
}


@end

@implementation UIPickerView (KeyboardDismiss)
- (void)drawRect:(CGRect)rect {
	
	//4-选择区域的背景颜色； 0-大背景的颜色； 1-选择框左边的颜色; 2-? ;3-?; 5-滚动区域的颜色 回覆盖数据
	//6-选择框的背景颜色 7-选择框左边的颜色 8-整个View的颜色 会覆盖所有的图片
    
//	UIView *v0 = [[self subviews] objectAtIndex:6];
//	[v0 setBackgroundColor:[UIColor clearColor]];
    UIView *v = [[self subviews] objectAtIndex:9];
	[v setBackgroundColor:[UIColor clearColor]];
    UILabel *houtlabel = [[UILabel alloc] initWithFrame:CGRectMake(50, -2, 100, 50)];
    [houtlabel setText:@"分钟"];
    [houtlabel setFont:[UIFont boldSystemFontOfSize:20]];
    [houtlabel setBackgroundColor:[UIColor clearColor]];
    [v addSubview:houtlabel];
    [houtlabel release];
	
    UILabel *minituelabel = [[UILabel alloc] initWithFrame:CGRectMake(-50, -2, 100, 50)];
    [minituelabel setText:@"小时"];
    [minituelabel setFont:[UIFont boldSystemFontOfSize:20]];
    [minituelabel setBackgroundColor:[UIColor clearColor]];
    [v addSubview:minituelabel];
    [minituelabel release];
    
    
	[self setNeedsDisplay];
	
}
@end


#pragma ----
@implementation UINavigationBar (CustomImage2)
- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed: @"title_main.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end

