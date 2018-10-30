//
//  AppDelegate.h
//  HouseWifeClock
//
//  Created by leo on 12-11-23.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpUtil.h"
#import "ClockObject.h"
#import <AVFoundation/AVFoundation.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,AVAudioPlayerDelegate,UIAlertViewDelegate>{
    HttpUtil *httpUtil;
    AVAudioPlayer *player;
}

@property (nonatomic,retain) HttpUtil *httpUtil;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (nonatomic,retain)AVAudioPlayer *player;

-(void)addNewLocalClockNotificationWithClockObject:(ClockObject *)clockObj;
-(void)cancelLocalClockNotifationWithClockObject:(ClockObject *)clockObj;
@end
