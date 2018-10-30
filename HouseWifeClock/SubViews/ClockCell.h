//
//  ClockCell.h
//  HouseWifeClock
//
//  Created by Yang leo on 12-11-24.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockObject.h"

@protocol ClockCellDelegate <NSObject>

@optional
-(void)clockCellStartButtonClick:(NSIndexPath *)indexPath;
-(void)clockCellcancelButtonClick:(NSIndexPath *)indexPath;
-(void)clockCellStopContinueButtonClick:(NSIndexPath *)indexPath;

@end


@interface ClockCell : UITableViewCell{
    
    UILabel *clockNameLable;
    UILabel *timeLabel;
    
    UIButton *startButton;
    UIButton *cancelButton;
    UIButton *stop_continueButton;
    
    NSIndexPath *indexpath;
    
    id<ClockCellDelegate> delegate;
}
@property (nonatomic,retain)UILabel *clockNameLable;
@property (nonatomic,retain)UILabel *timeLabel;

@property (nonatomic,retain)UIButton *startButton;
@property (nonatomic,retain)UIButton *cancelButton;
@property (nonatomic,retain)UIButton *stop_continueButton;

@property (nonatomic,retain)NSIndexPath *indexpath;

@property (nonatomic,assign)id<ClockCellDelegate> delegate;

-(void)updateClockButtonWithClock:(ClockObject *)obj;

@end
