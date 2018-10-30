//
//  ViewController.h
//  HouseWifeClock
//
//  Created by leo on 12-11-23.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockCell.h"
#import "ClockObject.h"
#import "AppDelegate.h"
#import "ClockDetailViewController.h"

@interface ViewController : UIViewController<ClockObjectDelegate,ClockCellDelegate,ClockDetailViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITableView *_tableView;
    NSMutableArray *dataArray;
    NSMutableArray *onClockArray;
    
    IBOutlet UIImageView *listBg;
}
@property (nonatomic,retain)IBOutlet UITableView *_tableView;
@property (nonatomic,retain)NSMutableArray *dataArray;
@property (nonatomic,retain)NSMutableArray *onClockArray;
@property (nonatomic,retain)IBOutlet UIImageView *listBg;

@end
