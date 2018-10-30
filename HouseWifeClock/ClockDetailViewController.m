//
//  ClockDetailViewController.m
//  HouseWifeClock
//
//  Created by leo on 12-11-23.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import "ClockDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

@interface ClockDetailViewController ()

@end

@implementation ClockDetailViewController
@synthesize _pickView;
@synthesize clockObj;
@synthesize pushType;
@synthesize hourArray;
@synthesize minitueArray;
@synthesize selectHourIndex;
@synthesize selectMinitueIndex;
@synthesize delegate;
@synthesize timeLabel;
@synthesize clockNameTextFiled;
@synthesize startButton;
@synthesize cancelButton;
@synthesize stop_continue_Button;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"新闹钟";
        
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setFrame:CGRectMake(0, 0, 68, 30)];
        [back setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
        self.navigationItem.leftBarButtonItem = backButton;
        [backButton release];
        
        
        
        UIButton *save = [UIButton buttonWithType:UIButtonTypeCustom];
        [save setFrame:CGRectMake(0, 0, 50, 30)];
        [save setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
        [save addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithCustomView:save];
        self.navigationItem.rightBarButtonItem = saveButton;
        [saveButton release];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ClockAppWillEnterForeground)
                                                     name:@"ClockAppWillEnterForeground"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ClockAppDidEnterBackground)
                                                     name:@"ClockAppDidEnterBackground"
                                                   object:nil];
        
    }
    return self;
}

-(void)ClockAppWillEnterForeground{
    
    int flag = 1;
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for(int j=0;j<[localNotifications count];++j){
        UILocalNotification *notification = [localNotifications objectAtIndex:j];
        NSDictionary *dic = [notification userInfo];
        NSString *clockid = [dic objectForKey:@"clockid"];
        int second = [[notification fireDate] timeIntervalSinceDate:[NSDate date]];
        
        if([clockObj.clockid isEqualToString:clockid] && second > 0){
            [clockObj setSecond:second];
            flag = 0;
            break;
        }
    }
    
    if(flag != 0){
        [clockObj setIsOn:NO];
        [clockObj setSecond:clockObj.defaultSecond];
    }
    
    flag = 1;
    [timeLabel setText:[self getTimeWithSecond:clockObj.second]];
    if(clockObj.isOn){
        [startButton setAlpha:0];
        [cancelButton setAlpha:1];
        
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        [startButton setAlpha:1];
        [cancelButton setAlpha:0];
        
        UIButton *save = [UIButton buttonWithType:UIButtonTypeCustom];
        [save setFrame:CGRectMake(0, 0, 50, 30)];
        [save setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
        [save addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithCustomView:save];
        self.navigationItem.rightBarButtonItem = saveButton;
        [saveButton release];
        
    }
    
    [timeLabel setAlpha:1];
}
-(void)ClockAppDidEnterBackground{
    [timeLabel setAlpha:0];
    [startButton setAlpha:0];
    [cancelButton setAlpha:0];
}

-(IBAction)backButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    
    [self createUI];
    [self initData];
    _pickView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [_pickView setDelegate:self];
    [_pickView setDataSource:self];
    [_pickView setBackgroundColor:[UIColor clearColor]];
    [_pickView setShowsSelectionIndicator:YES];
    [_pickView setFrame:CGRectMake(0, 0, 320, 216)];
    
    
    UITapGestureRecognizer *_gister = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewOnClick:)];
    [timeLabelView addGestureRecognizer:_gister];
    [_gister release];
    
    
    if(pushType == Clock_PushType_NewClock){
        [_pickView selectRow:1 inComponent:1 animated:NO];
        selectHourIndex = 0;
        selectMinitueIndex = 1;
        
        [timeLabel setText:@"01:00"];
        [startButton setAlpha:1];
        [cancelButton setAlpha:0];
        [stop_continue_Button setAlpha:0];
        
    }else{
        
        selectHourIndex = clockObj.second/3600;
        selectMinitueIndex = clockObj.second%3600 / 60;
        
        [timeLabel setText:[self getTimeWithSecond:clockObj.second]];
        [clockNameTextFiled setText:clockObj.clockName];
        
        if(clockObj.isOn){
            [startButton setAlpha:0];
            [cancelButton setAlpha:1];
            [stop_continue_Button setAlpha:1];
            [self.navigationItem setRightBarButtonItem:nil];
        }else{
            [startButton setAlpha:1];
            [cancelButton setAlpha:0];
            [stop_continue_Button setAlpha:0];
        }
        
        if(clockObj.isPause){
            [stop_continue_Button setTitle:@"继续" forState:UIControlStateNormal];
        }else{
            [stop_continue_Button setTitle:@"暂停" forState:UIControlStateNormal];
        }
        
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)createUI{
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [bg setImage:[UIImage imageNamed:@"background.png"]];
    [self.view addSubview:bg];
    
    
    UIImageView *timebg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [timebg setImage:[UIImage imageNamed:@"time.png"]];
    [self.view addSubview:timebg];
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:[UIColor colorWithRed:231.0/255 green:143.0/255 blue:133.0/255 alpha:1]];
    [timeLabel setTextAlignment:UITextAlignmentCenter];
    [timeLabel setFont:[UIFont fontWithName:@"LCDMono" size:56]];
    //[timeLabel setFont:[UIFont systemFontOfSize:56]];
    [timeLabel setAdjustsFontSizeToFitWidth:YES];
    [timeLabel setMinimumFontSize:15];
    [self.view addSubview:timeLabel];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 320, 480)];
    [button addTarget:self action:@selector(backhideButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    timeLabelView = [[UIView alloc] initWithFrame:CGRectZero];
    [timeLabelView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:timeLabelView];
    
    
    clockNameTextFiled = [[UITextField alloc] initWithFrame:CGRectZero];
    [clockNameTextFiled setBackgroundColor:[UIColor clearColor]];
    [clockNameTextFiled setPlaceholder:@"输入闹钟名称"];
    [clockNameTextFiled setDelegate:self];
    [clockNameTextFiled setTextColor:[UIColor grayColor]];
    [clockNameTextFiled setTextAlignment:UITextAlignmentCenter];
    [clockNameTextFiled setBorderStyle:UITextBorderStyleNone];
    [clockNameTextFiled setFont:[UIFont boldSystemFontOfSize:22]];
    [self.view addSubview:clockNameTextFiled];
    
    
    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(startClockButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [startButton setImage:[UIImage imageNamed:@"time_start.png"] forState:UIControlStateNormal];
    [self.view addSubview:startButton];
    
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"time_cancel.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    //[cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.view addSubview:cancelButton];
    
//    self.stop_continue_Button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [stop_continue_Button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//    [stop_continue_Button addTarget:self action:@selector(stop_continueButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [stop_continue_Button setTitle:@"暂停" forState:UIControlStateNormal];
//    [self.view addSubview:stop_continue_Button];
    
    
    if(KScreenHeight == 480 || KScreenHeight == 960){
        [bg setFrame:CGRectMake(0, 0, 320, 480)];
        [timebg setFrame:CGRectMake(49, 5, 221, 143)];
        [timeLabel setFrame:CGRectMake(320/2-90, 10, 180, 88)];
        [timeLabelView setFrame:CGRectMake(0, 10, 320, 88)];
        [clockNameTextFiled setFrame:CGRectMake(58, 115,204, 34)];
        
        [startButton setFrame:CGRectMake(87, 230, 145, 65)];
        [cancelButton setFrame:CGRectMake(87, 230, 145, 65)];
        //[stop_continue_Button setFrame:CGRectMake(193, 230, 93, 44)];
    }else{
        [bg setFrame:CGRectMake(0, 0, 320, 568)];
        [timebg setFrame:CGRectMake(49, 5, 221, 143)];
        [timeLabel setFrame:CGRectMake(320/2-90, 10, 180, 88)];
        [timeLabelView setFrame:CGRectMake(0, 10, 320, 88)];
        [clockNameTextFiled setFrame:CGRectMake(58, 115,204, 34)];
        
        [startButton setFrame:CGRectMake(87, 230, 145, 65)];
        [cancelButton setFrame:CGRectMake(87, 230, 145, 65)];
        //[stop_continue_Button setFrame:CGRectMake(193, 230, 93, 44)];
    }
    
    [timebg release];
    [bg release];
}

-(void)initData{
    switch (pushType) {
        case Clock_PushType_NewClock:{
            if(clockObj == nil){
                clockObj = [[ClockObject alloc] init];
                clockObj.second = 60;
                clockObj.defaultSecond = 60;
                [clockObj setDelegate:self];
                clockNameTextFiled.text = @"新闹钟";
            }
        }
            break;
            
        case Clock_PushType_OldClock:{
            if(clockObj == nil){
                clockObj = [[ClockObject alloc] init];
            }
            [clockObj setDelegate:self];
            self.title = clockObj.clockName;
            
            /*此处设置时间，开关，等等信息*/
        }
            break;
    }
    
    
    self.hourArray = [NSMutableArray arrayWithCapacity:0];
    self.minitueArray = [NSMutableArray arrayWithCapacity:0];
    
    for(int i=0;i<24;++i){
        [hourArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    for(int i=0;i<60;++i){
        [minitueArray addObject:[NSString stringWithFormat:@"%d",i]];
    }
}

-(void)backhideButtonClick{
    [clockNameTextFiled resignFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ClockAppDidEnterBackground" object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ClockAppWillEnterForeground" object:self];
    
    [delegate modifyDraftFinishedWithObject:clockObj];
    
    [startButton release];
    [cancelButton release];
    [stop_continue_Button release];
    [clockNameTextFiled release];
    [timeLabel release];
    [hourArray release];
    [minitueArray release];
    [clockObj release];
    [_pickView release];
    [super dealloc];
}


#pragma mark- ClockObjectDelegate
#pragma mark- ClockObjectDelegate

-(void)clockObjectSubSecond:(NSIndexPath *)indexpath{
    
    [timeLabel setText:[self getTimeWithSecond:clockObj.second]];
    
}


-(void)viewOnClick:(id)sender{
    
    if(clockObj.isOn == YES){
        return;
    }
    
    [clockNameTextFiled resignFirstResponder];
    selectHourIndex = clockObj.second/3600;
    selectMinitueIndex = clockObj.second%3600 / 60;
    [_pickView selectRow:selectHourIndex inComponent:0 animated:NO];
    [_pickView selectRow:selectMinitueIndex inComponent:1 animated:NO];
    
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"\n\n\n\\n\n\n\\n\n\n\n\n\n\n"
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                destructiveButtonTitle:@"确定"
                                                     otherButtonTitles:nil] autorelease];
    actionSheet.userInteractionEnabled = YES;
    [actionSheet addSubview:_pickView];
    [actionSheet showInView:self.view];
    //actionSheet.bounds = CGRectMake(0, 0, 320, 516);
}


#pragma mark- Actions
-(IBAction)startClockButtonClick:(id)sender{
    //先要判断 时间是否选择，闹钟名称是否填写
    
    if(clockNameTextFiled.text == nil || [[clockNameTextFiled.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"闹钟名称不能为空"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
        return;
    }
    
    clockObj.defaultSecond = [[hourArray objectAtIndex:selectHourIndex] intValue]*3600 + [[minitueArray objectAtIndex:selectMinitueIndex] intValue] * 60;
    clockObj.second = clockObj.defaultSecond;
    clockObj.clockName = clockNameTextFiled.text;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *clockid = [[appDelegate httpUtil] saveClockObjectToDatabase:self.clockObj];
    
    if(clockObj.clockid == nil){
        [clockObj setClockid:clockid];
    }else{
        
    }
    
    [clockObj setIsOn:YES];
    [clockObj setIsPause:NO];
    
    if(pushType == Clock_PushType_NewClock){
        [delegate justSaveClockToDataBase:clockObj];
    }
    
    [delegate startClockWithObj:clockObj];
    
    [startButton setAlpha:0];
    [self.navigationItem setRightBarButtonItem:nil];
    [cancelButton setAlpha:1];
    [stop_continue_Button setAlpha:1];
    
}
-(IBAction)cancelButtonClick:(id)sender{
    [clockObj setIsOn:NO];
    [clockObj setSecond:clockObj.defaultSecond];
    [timeLabel setText:[self getTimeWithSecond:clockObj.second]];
    [delegate cancelClockWithObj:clockObj];
    
    [startButton setAlpha:1];
    [cancelButton setAlpha:0];
    [stop_continue_Button setAlpha:0];
    
    
    UIButton *save = [UIButton buttonWithType:UIButtonTypeCustom];
    [save setFrame:CGRectMake(0, 0, 50, 30)];
    [save setImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    [save addTarget:self action:@selector(saveButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithCustomView:save];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
}
-(IBAction)stop_continueButtonClick:(id)sender{
    
    if(clockObj.isPause == YES){
        [stop_continue_Button setTitle:@"暂停" forState:UIControlStateNormal];
        [clockObj setIsPause:NO];
        [delegate continueClockWithObj:clockObj];
    }else{
        [stop_continue_Button setTitle:@"继续" forState:UIControlStateNormal];
        [clockObj setIsPause:YES];
        [delegate stopClockWithObj:clockObj];
    }
}


#pragma mark-UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        //确定
        
        [timeLabel setText:[self getTimeWithSecond:[[hourArray objectAtIndex:selectHourIndex] intValue]*3600 + [[minitueArray objectAtIndex:selectMinitueIndex] intValue] * 60]];
        
    }else{
        
    }
}



-(void)saveButtonClick{
    
    //先要判断 时间是否选择，闹钟名称是否填写
    if(clockNameTextFiled.text == nil || [[clockNameTextFiled.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"闹钟名称不能为空"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
        [alert show];
        [alert release];
        return;
    }
    
    clockObj.defaultSecond = [[hourArray objectAtIndex:selectHourIndex] intValue]*3600 + [[minitueArray objectAtIndex:selectMinitueIndex] intValue] * 60;
    clockObj.second = clockObj.defaultSecond;
    clockObj.clockName = clockNameTextFiled.text;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *clockid = [[appDelegate httpUtil] saveClockObjectToDatabase:self.clockObj];
    
    if(clockObj.clockid == nil){
        [clockObj setClockid:clockid];
        [delegate saveClockToDatabaseSuccssful:clockObj];
    }else{
        [delegate modifyDraftFinishedWithObject:clockObj];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark- Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(clockObj.isOn == YES){
        return NO;
    }
    return YES;
}


#pragma mark- 
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component == 0){
        return [hourArray count];
    }else if(component == 1){
        return [minitueArray count];
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return 100;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 45;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(component == 0){
        return [hourArray objectAtIndex:row];
    }else{
        return [minitueArray objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(component == 0){
        selectHourIndex = row;
    }else if(component == 1){
        if(row == 0 && selectHourIndex == 0){
            self.selectMinitueIndex = 1;
            [pickerView selectRow:1 inComponent:1 animated:YES];
            return;
        }else{
            
        }
        selectMinitueIndex = row;
    }
}




#pragma mark-

-(NSString *)getTimeWithSecond:(NSInteger)second{
    
    NSInteger hour = (second%(24*60*60))/(60*60);
    NSInteger minitue = ((second%(24*60*60))%(60*60))/60;
    NSInteger seconds = ((second%(24*60*60))%(60*60))%60;
    
    
    NSString *hourValye = @"";
    NSString *minitueValue = @"";
    NSString *secondValue = @"";
    
    if(minitue > 0 && second == 0){
        minitue--;
    }
    
    if(hour > 0 && minitue == 0){
        hour--;
    }
    
    if(seconds == 0){
        secondValue = [NSString stringWithFormat:@"0%d",0];
    }else if(seconds > 0 && seconds < 10){
        secondValue = [NSString stringWithFormat:@"0%d",seconds];
    }else{
        secondValue = [NSString stringWithFormat:@"%d",seconds];
    }
    
    
    if(minitue == 0){
        minitueValue = [NSString stringWithFormat:@"0%d",0];
    }else if(minitue > 0 && minitue < 10){
        minitueValue = [NSString stringWithFormat:@"0%d",minitue];
    }else{
        minitueValue = [NSString stringWithFormat:@"%d",minitue];
    }
    
    if(hour == 0){
        hourValye = [NSString stringWithFormat:@"0%d",0];
    }else if(hour > 0 && hour < 10){
        hourValye = [NSString stringWithFormat:@"0%d",hour];
    }else{
        hourValye = [NSString stringWithFormat:@"%d",hour];
    }
    
    if(hour == 0){
        return [NSString stringWithFormat:@"%@:%@",minitueValue,secondValue];
    }else{
        return [NSString stringWithFormat:@"%@:%@:%@",hourValye,minitueValue,secondValue];
    }
}


@end
