//
//  ViewController.m
//  HouseWifeClock
//
//  Created by leo on 12-11-23.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import "ViewController.h"
#import "ClockDetailViewController.h"
#import "ClockObject.h"
#import "const.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize _tableView;
@synthesize dataArray;
@synthesize onClockArray;
@synthesize listBg;


- (void)viewDidLoad
{
    self.title = @"煮妇闹钟";
    [self updateUI];
    //声明右侧增加按钮
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    [add setFrame:CGRectMake(0, 0, 44, 44)];
    [add setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    [add addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:add];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    self.dataArray = [NSMutableArray arrayWithCapacity:0];
    self.onClockArray = [NSMutableArray arrayWithCapacity:0];
    [self initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ClockAppWillEnterForeground)
                                                 name:@"ClockAppWillEnterForeground"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ClockAppDidEnterBackground)
                                                 name:@"ClockAppDidEnterBackground"
                                               object:nil];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


-(void)updateUI{
    
    if(KScreenHeight == 480 || KScreenHeight == 960){
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        [bgImageView setImage:[UIImage imageNamed:@"background.png"]];
        [self.view addSubview:bgImageView];
        [bgImageView release];
        
        listBg = [[UIImageView alloc] initWithFrame:CGRectMake(10, (480-44-397)/2-5, 300, 397)];
        [listBg setImage:[UIImage imageNamed:@"list_bg.png"]];
        [listBg setFrame:CGRectMake(10, (480-44-397)/2-5, 300, 397)];
        [self.view addSubview:listBg];
        
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 10-5, 300, 353-48)];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setBackgroundView:nil];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setFrame:CGRectMake(10, (480-44-397)/2+24-5, 300, 397-48)];
        [self.view addSubview:_tableView];
    }else if(KScreenHeight == 568){
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 569)];
        [bgImageView setImage:[UIImage imageNamed:@"background.png"]];
        [self.view addSubview:bgImageView];
        [bgImageView release];
        
        
        listBg = [[UIImageView alloc] initWithFrame:CGRectMake(10, (480-44-397)/2-5, 300, 397)];
        [listBg setImage:[UIImage imageNamed:@"list_bg_1136.png"]];
        [listBg setFrame:CGRectMake(10, (568-44-485)/2-5, 300, 485)];
        [self.view addSubview:listBg];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 10-5, 300, 353-48)];
        [_tableView setDelegate:self];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView setDataSource:self];
        [_tableView setBackgroundView:nil];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setFrame:CGRectMake(10, 24+(568-44-485)/2-5, 300, 485-48)];
        [self.view addSubview:_tableView];
    }
}




-(void)initData{
    
    //获取所有闹钟
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.dataArray addObjectsFromArray:[[appDelegate httpUtil] getClockListFromDataBase]];
    //获取正在运行中的闹钟
    [self getAllOnClock];
    
    NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
    NSTimer *myTimer = [NSTimer timerWithTimeInterval:1.0
                                               target:self
                                             selector:@selector(loop)
                                             userInfo:nil
                                              repeats:YES];
    [myRunLoop addTimer:myTimer forMode:NSRunLoopCommonModes];
}

-(void)loop{
    for(int i=0;i<[onClockArray count];++i){
        ClockObject *clock = [onClockArray objectAtIndex:i];
        if(clock.second > 0){
            //[clock setSecond:clock.second-1];
            [clock subSecond];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    
}


//后台中止后 重新启动 获取生存的闹钟

-(void)getAllOnClock{
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for(int i=0;i<[dataArray count];++i){
        
        ClockObject *clock = [dataArray objectAtIndex:i];
        [clock setDelegate:self];
        for(UILocalNotification *notification in localNotifications){
            NSDictionary *dic = [notification userInfo];
            NSString *clockid = [dic objectForKey:@"clockid"];
            int second = [[notification fireDate] timeIntervalSinceDate:[NSDate date]];
            
            if([clockid isEqualToString:clock.clockid]){
                [clock setSecond:second];
                [clock setIsOn:YES];
                [onClockArray addObject:clock];
                break;
            }
        }
    }
}


-(void)ClockAppWillEnterForeground{
    //先获取所有闹钟数据
    //再获取正在运行中的数据，并设置为YES
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    int flag = 1;
    for(int i=0;i<[onClockArray count];++i){
        ClockObject *clock = [onClockArray objectAtIndex:i];
        
        for(int j=0;j<[localNotifications count];++j){
            UILocalNotification *notification = [localNotifications objectAtIndex:j];
            NSDictionary *dic = [notification userInfo];
            NSString *clockid = [dic objectForKey:@"clockid"];
            int second = [[notification fireDate] timeIntervalSinceDate:[NSDate date]];
            
            if([clock.clockid isEqualToString:clockid] && second > 0){
                [clock setSecond:second];
                flag = 0;
                break;
            }
        }
        
        if(flag != 0){
            NSLog(@"cao");
            [clock setIsOn:NO];
            [clock setSecond:clock.defaultSecond];
            [onClockArray removeObject:clock];
        }
        
        flag = 1;
    }
    [_tableView reloadData];
    [_tableView setAlpha:1];
}

-(void)ClockAppDidEnterBackground{
    [_tableView setAlpha:0];
}



-(void)addButtonClick:(id)sender{
    ClockDetailViewController *detail = [[ClockDetailViewController alloc] initWithNibName:@"ClockDetailViewController" bundle:nil];
    [detail setDelegate:self];
    
    [detail setPushType:Clock_PushType_NewClock];
    [self.navigationController pushViewController:detail animated:YES];
    [detail release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ClockAppDidEnterBackground" object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ClockAppWillEnterForeground" object:self];
    [listBg release];
    [dataArray release];
    [_tableView release];
    [super dealloc];
}

#pragma mark- ClockObjectDelegate

-(void)clockObjectSubSecond:(NSIndexPath *)indexpath{
    
    ClockCell *cell = (ClockCell *)[_tableView cellForRowAtIndexPath:indexpath];
    
    ClockObject *obj = [dataArray objectAtIndex:indexpath.row];
    
    [[cell timeLabel] setText:[self getTimeWithSecond:obj.second]];
    
}

#pragma mark- ClockCellDelegate
//开始
-(void)clockCellStartButtonClick:(NSIndexPath *)indexPath{
    //开始 暂停 按钮点击了
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ClockObject *clockObj = [dataArray objectAtIndex:indexPath.row];
    
    
    [clockObj setIsOn:YES];
    [clockObj setIsPause:NO];
    
    [clockObj setDelegate:self];
    
    [onClockArray addObject:[dataArray objectAtIndex:indexPath.row]];
    [appDelegate addNewLocalClockNotificationWithClockObject:clockObj];
    
    ClockCell *cell = (ClockCell *)[_tableView cellForRowAtIndexPath:indexPath];
    [cell updateClockButtonWithClock:clockObj];
}
-(void)clockCellcancelButtonClick:(NSIndexPath *)indexPath{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ClockObject *clockObj = [dataArray objectAtIndex:indexPath.row];
    
    [clockObj setIsOn:NO];
    [clockObj setIsPause:NO];
    
    [clockObj setSecond:clockObj.defaultSecond];
    [onClockArray removeObject:clockObj];
    [appDelegate cancelLocalClockNotifationWithClockObject:clockObj];
    
    ClockCell *cell = (ClockCell *)[_tableView cellForRowAtIndexPath:indexPath];
    [cell updateClockButtonWithClock:clockObj];
    [[cell timeLabel] setText:[self getTimeWithSecond:clockObj.second]];
}
-(void)clockCellStopContinueButtonClick:(NSIndexPath *)indexPath{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ClockObject *clockObj = [dataArray objectAtIndex:indexPath.row];
    //先取消
    if(clockObj.isPause == YES){
        [clockObj setIsPause:NO];
        [appDelegate addNewLocalClockNotificationWithClockObject:clockObj];
    }else{
        [clockObj setIsPause:YES];
        [appDelegate cancelLocalClockNotifationWithClockObject:clockObj];
    }
    
    
    ClockCell *cell = (ClockCell *)[_tableView cellForRowAtIndexPath:indexPath];
    [cell updateClockButtonWithClock:clockObj];
}


#pragma mark- UITableViewDatasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[[ClockCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:identifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 20, 20)];
        [imageV setImage:[UIImage imageNamed:@"alarm.png"]];
        [[cell contentView] addSubview:imageV];
        [imageV release];
        
        [(ClockCell *)cell setDelegate:self];
    }
    
    ClockObject *obj = [dataArray objectAtIndex:indexPath.row];
    [obj setIndexPath:indexPath];
    
    [[(ClockCell *)cell timeLabel] setText:[self getTimeWithSecond:obj.second]];
    [[(ClockCell *)cell clockNameLable] setText:obj.clockName];
    [(ClockCell *)cell setIndexpath:indexPath];
    
    [(ClockCell *)cell updateClockButtonWithClock:obj];
    
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [dataArray count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row != [dataArray count])
    {
        ClockCell *cell = (ClockCell *)[_tableView cellForRowAtIndexPath:indexPath];
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.15];
        
        [[cell startButton] setAlpha:0];
        [[cell cancelButton] setAlpha:0];
        [[cell stop_continueButton] setAlpha:0];
        
        [UIView commitAnimations];
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row != [dataArray count]){
        ClockObject *obj = [dataArray objectAtIndex:indexPath.row];
        ClockCell *cell = (ClockCell *)[_tableView cellForRowAtIndexPath:indexPath];
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.15];
        
        [(ClockCell *)cell updateClockButtonWithClock:obj];
        
        [UIView commitAnimations];
    }
}

#pragma mark -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ClockDetailViewController *detail = [[ClockDetailViewController alloc] initWithNibName:@"ClockDetailViewController" bundle:nil];
    [detail setDelegate:self];
    
    [detail setPushType:Clock_PushType_OldClock];
    [detail setClockObj:[dataArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detail animated:YES];
    [detail release];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        
        ClockObject *clockObj = [dataArray objectAtIndex:indexPath.row];
        [[appDelegate httpUtil] deleteClockWithClockid:[clockObj clockid]];
        
        [appDelegate cancelLocalClockNotifationWithClockObject:clockObj];
        [dataArray removeObject:clockObj];
        [onClockArray removeObject:clockObj];
        
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
        NSArray *cells = [_tableView visibleCells];
        for(int i=0;i<[cells count];++i){
            ClockCell *cell = [cells objectAtIndex:i];
            if([_tableView indexPathForCell:cell].row < [dataArray count]){
                
                ClockObject *obj = [dataArray objectAtIndex:[_tableView indexPathForCell:cell].row];
                [cell setIndexpath:[_tableView indexPathForCell:cell]];
                [UIView beginAnimations:@"" context:nil];
                [UIView setAnimationCurve:UIViewAnimationCurveLinear];
                [UIView setAnimationDuration:0.15];
                
                [cell updateClockButtonWithClock:obj];
                [UIView commitAnimations];
            }
        }
        
    }
}

#pragma mark- ClockDetailViewControllerDelegate <NSObject>

-(void)saveClockToDatabaseSuccssful:(ClockObject *)obj{
    [obj setDelegate:self];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [dataArray addObject:obj];
    if(obj.isOn){
        [onClockArray addObject:obj];
        [appDelegate addNewLocalClockNotificationWithClockObject:obj];
    }
    [_tableView reloadData];
}

-(void)justSaveClockToDataBase:(ClockObject *)obj{
    [dataArray addObject:obj];
}

-(void)modifyDraftFinishedWithObject:(ClockObject *)obj{
    [obj setDelegate:self];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(obj.isOn == YES){
        int flag = -1;
        for(int i=0;i<[onClockArray count];++i){
            ClockObject *o = [onClockArray objectAtIndex:i];
            if([o.clockid isEqualToString:obj.clockid]){
                flag = 0;
            }
        }
        if(flag == -1){
            [onClockArray addObject:obj];
            [appDelegate addNewLocalClockNotificationWithClockObject:obj];
        }
    }
    
    [_tableView reloadData];
}

-(void)startClockWithObj:(ClockObject *)obj{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(obj.isOn){
        int flag = -1;
        for(int i=0;i<[onClockArray count];++i){
            ClockObject *o = [onClockArray objectAtIndex:i];
            if([o.clockid isEqualToString:obj.clockid]){
                flag = 0;
            }
        }
        if(flag == -1){
            [onClockArray addObject:obj];
            [appDelegate addNewLocalClockNotificationWithClockObject:obj];
        }
    }
}
-(void)cancelClockWithObj:(ClockObject *)obj{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [obj setIsOn:NO];
    [onClockArray removeObject:obj];
    [appDelegate cancelLocalClockNotifationWithClockObject:obj];
    
    [_tableView reloadData];
}
-(void)continueClockWithObj:(ClockObject *)obj{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate addNewLocalClockNotificationWithClockObject:obj];
    [_tableView reloadData];
}
-(void)stopClockWithObj:(ClockObject *)obj{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate cancelLocalClockNotifationWithClockObject:obj];
    [_tableView reloadData];
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
