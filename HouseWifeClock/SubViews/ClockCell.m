//
//  ClockCell.m
//  HouseWifeClock
//
//  Created by Yang leo on 12-11-24.
//  Copyright (c) 2012年 leo. All rights reserved.
//

#import "ClockCell.h"

@implementation ClockCell
@synthesize clockNameLable;
@synthesize timeLabel;
@synthesize startButton;
@synthesize cancelButton;
@synthesize stop_continueButton;

@synthesize indexpath;
@synthesize delegate;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
//        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 1)];
//        [line setImage:[UIImage imageNamed:@"line.png"]];
//        [[self contentView] addSubview:line];
//        [line release];
//        
        UIImageView *line2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 49, 300, 1)];
        [line2 setImage:[UIImage imageNamed:@"line.png"]];
        [[self contentView] addSubview:line2];
        [line2 release];
        
        clockNameLable = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 180, 25)];
        [clockNameLable setFont:[UIFont boldSystemFontOfSize:18]];
        [clockNameLable setMinimumFontSize:13];
        [clockNameLable setBackgroundColor:[UIColor clearColor]];
        [clockNameLable setAdjustsFontSizeToFitWidth:YES];
        [clockNameLable setTextColor:[UIColor colorWithRed:151.0/255 green:151.0/255 blue:151.0/255 alpha:1]];
        [clockNameLable setText:@"新闹钟"];
        [[self contentView] addSubview:clockNameLable];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, 110, 30)];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setMinimumFontSize:12];
        [timeLabel setTextColor:[UIColor colorWithRed:231.0/255 green:143.0/255 blue:133.0/255 alpha:1]];
        [timeLabel setAdjustsFontSizeToFitWidth:YES];
        [timeLabel setFont:[UIFont systemFontOfSize:18]];
        [[self contentView] addSubview:timeLabel];
        
        self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [startButton setImage:[UIImage imageNamed:@"start.png"] forState:UIControlStateNormal];
        [startButton setFrame:CGRectMake(320-100, 10, 56, 28)];
        [startButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [[self contentView] addSubview:startButton];
        
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:[UIImage imageNamed:@"cancle.png"] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(320-100, 10, 56, 28)];
        [cancelButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [[self contentView] addSubview:cancelButton];
        
//        self.stop_continueButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        [stop_continueButton setFrame:CGRectMake(320-80, 60, 60, 40)];
//        [stop_continueButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [[self contentView] addSubview:stop_continueButton];
    }
    return self;
}

-(void)buttonClick:(id)sender{
    UIButton *button = (UIButton *)sender;
    if(button == startButton){
        [delegate clockCellStartButtonClick:indexpath];
    }else if(button == cancelButton){
        [delegate clockCellcancelButtonClick:indexpath];
    }else if(button == stop_continueButton){
        [delegate clockCellStopContinueButtonClick:indexpath];
    }
}

-(void)updateClockButtonWithClock:(ClockObject *)obj{
    if(obj.isOn == YES){
        [startButton setAlpha:0];
        [cancelButton setAlpha:1];
        [stop_continueButton setAlpha:1];
    }else{
        [startButton setAlpha:1];
        [cancelButton setAlpha:0];
        [stop_continueButton setAlpha:0];
    }
    
    if(obj.isPause){
        [stop_continueButton setTitle:@"继续" forState:UIControlStateNormal];
    }else{
        [stop_continueButton setTitle:@"暂停" forState:UIControlStateNormal];
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc{
    [indexpath release];
    [startButton release];
    [cancelButton release];
    [stop_continueButton release];
    [clockNameLable release];
    [timeLabel release];
    [super dealloc];
}

@end
