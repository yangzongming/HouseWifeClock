//
//  ClockDetailViewController.h
//  HouseWifeClock
//
//  Created by leo on 12-11-23.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockObject.h"
#import "const.h"

@protocol ClockDetailViewControllerDelegate <NSObject>

@optional
-(void)saveClockToDatabaseSuccssful:(ClockObject *)obj;
-(void)justSaveClockToDataBase:(ClockObject *)obj;
-(void)modifyDraftFinishedWithObject:(ClockObject *)obj;
-(void)startClockWithObj:(ClockObject *)obj;
-(void)cancelClockWithObj:(ClockObject *)obj;
-(void)continueClockWithObj:(ClockObject *)obj;
-(void)stopClockWithObj:(ClockObject *)obj;
@end

@interface ClockDetailViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate,ClockObjectDelegate,UITextFieldDelegate>{
    IBOutlet UIPickerView *_pickView;
    
    IBOutlet UILabel *timeLabel;
    IBOutlet UIView *timeLabelView;
    IBOutlet UITextField *clockNameTextFiled;
    
    ClockObject *clockObj;
    
    NSInteger pushType;
    
    NSMutableArray *hourArray;
    NSMutableArray *minitueArray;
    
    int selectHourIndex;
    int selectMinitueIndex;
    
    id<ClockDetailViewControllerDelegate> delegate;
    
    IBOutlet UIButton *startButton;
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *stop_continue_Button;
    
}
@property (nonatomic,retain)IBOutlet UIPickerView *_pickView;
@property (nonatomic,retain)ClockObject *clockObj;
@property (nonatomic,assign)NSInteger pushType;
@property (nonatomic,retain)IBOutlet UILabel *timeLabel;
@property (nonatomic,retain)IBOutlet UITextField *clockNameTextFiled;

@property (nonatomic,retain)NSMutableArray *hourArray;
@property (nonatomic,retain)NSMutableArray *minitueArray;

@property (nonatomic,assign)int selectHourIndex;
@property (nonatomic,assign)int selectMinitueIndex;

@property (nonatomic,assign)id<ClockDetailViewControllerDelegate> delegate;

@property (nonatomic,retain)IBOutlet UIButton *startButton;
@property (nonatomic,retain)IBOutlet UIButton *cancelButton;
@property (nonatomic,retain)IBOutlet UIButton *stop_continue_Button;

-(IBAction)startClockButtonClick:(id)sender;
-(IBAction)cancelButtonClick:(id)sender;
-(IBAction)stop_continueButtonClick:(id)sender;
@end
