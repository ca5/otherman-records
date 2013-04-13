//
//  PlayerViewController.m
//  OthermanRecords
//
//  Created by ca54makske on 13/02/24.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "PlayerViewController.h"
#import "TrackList.h"
#import "Jacket.h"


@implementation PlayerViewController
@synthesize cutnum = _cutnum;
@synthesize tracknum = _tracknum;

- (void)updateViews
{
    NSDictionary *track = [[TrackList instanceWithDelegate:nil] trackWithCutnum:_cutnum tracknum:_tracknum];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 480, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 3;
    label.font = [UIFont boldSystemFontOfSize: 9.0f];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%@\n%@\n%@",[track objectForKey:@"creator"], [track objectForKey:@"title"], [track objectForKey:@"album"]];
    
    NSLog(@"[DEBUG]updateViews %@\n%@\n%@\n", [track objectForKey:@"creator"], [track objectForKey:@"title"], [track objectForKey:@"album"]);
    
    self.navigationItem.titleView = label;
    
    
    UIImageView *jacket = (UIImageView *)[self.view viewWithTag:4];
    jacket.image = [[Jacket instanceWithDelegate:nil] imageWithCutnum:_cutnum];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog (@"cutnum:%@ tracknum:%@", _cutnum, _tracknum);
    [self updateViews];
    [[Player instanceWithDelegate:self] startWithCutnum:_cutnum tracknum:_tracknum];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    NSLog (@"Player View unloaded\n");

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}



-(IBAction)startStop:(id)sender
{
    Player *player = [Player instanceWithDelegate:self];
    if([player isPlaying]){
        NSLog(@"[DEBUG]isPlaying -stopPlayer");
        [player stop];
    }else{
        NSLog(@"[DEBUG]isNotPlaying -startPlayer");

        [player startWithCutnum:_cutnum tracknum:_tracknum];
    }
}

-(IBAction)next:(id)sender
{
    [[Player instanceWithDelegate:self] next];
}

-(IBAction)prev:(id)sender
{
    [[Player instanceWithDelegate:self] prev];
}

-(NSString *) timeString:(double)time {
    int sec = (int)time % 60;
    NSString *secStr;
    if(sec < 10){
        secStr = [NSString stringWithFormat:@"0%d",sec];
    }else{
        secStr = [NSString stringWithFormat:@"%d",sec];
    }
    return [NSString stringWithFormat:@"%d:%@",(int)(time / 60), secStr];
    
}

-(void)playerDidChangeCurrentCutnum:(NSString *)cutnum tracknum:(NSString *)tracknum
{
    NSLog(@"track changed: %@ %@", cutnum, tracknum);
    _cutnum = cutnum;
    _tracknum = tracknum;
    [self updateViews];
}

-(void) playerDidChangeProgress:(double)progress duration:(double)duration;
{
    UISlider *progressBar = (UISlider *)[self.view viewWithTag:1];
    UILabel *current = (UILabel *)[self.view viewWithTag:2];
    UILabel *remain = (UILabel *)[self.view viewWithTag:3];
    
    [progressBar setValue:progress / duration];
    current.text = [self timeString:progress];
    remain.text = [NSString stringWithFormat:@"%@",[self timeString:duration - progress]];
}

-(void) playerDidChangeStatusToWaiting
{
    
}
    
-(void) playerDidChangeStatusToPlaying
{
    
}

-(void) playerDidChangeStatusToIdle
{
    
}

@end
