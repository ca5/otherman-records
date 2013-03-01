//
//  Player.m
//  OthermanRecords
//
//  Created by ca54makske on 13/02/25.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "Player.h"
#import "TrackList.h"

@implementation Player
{
    NSString *_new_cutnum;
    NSString *_new_tracknum;
    AudioStreamer *_streamer;
    NSTimer *progressUpdateTimer;
}

@synthesize cutnum = _cutnum;
@synthesize tracknum = _tracknum;


+(Player *)instance
{
    static dispatch_once_t pred;
    static Player *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

-(id)init
{
    return [super init];
}

-(void)startWithCutnum:(NSString *)cutnum tracknum:(NSString *)tracknum;
{

    
    if([cutnum isEqualToString:_cutnum] && [tracknum isEqualToString:_tracknum]){
        [[StreamingPlayer getInstance] start];
    } else {
        if([[TrackList instanceWithDelegate:self] count] == 0){
            _new_cutnum = cutnum;
            _new_tracknum = tracknum;
            [[TrackList instanceWithDelegate:self] load];
        }else{
            /* StreamingPlayer
            NSString *filename = [[[Track instanceWithDelegate:self] trackWithCutnum:cutnum tracknum:tracknum] objectForKey:@"filename"];
            [[StreamingPlayer getInstance] startWithURL:[NSString stringWithFormat:@"http://archive.org/download/%@/%@", cutnum, filename]];
             */
            NSLog(@"before destroy Streamer");
            [self destroyStreamer];
            NSLog(@"before create Streamer");

            [self createStreamerWithCutnum:cutnum tracknum:tracknum];
            [_streamer start];
        }
    }
    _cutnum = cutnum;
    _tracknum = tracknum;
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (_streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:_streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[_streamer stop];
		_streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamerWithCutnum:(NSString *)cutnum tracknum:(NSString *)tracknum
{
	if (_streamer)
	{
		return;
	}
    
	[self destroyStreamer];
    //NSString *filename = [[[TrackList instanceWithDelegate:self] trackWithCutnum:cutnum tracknum:tracknum] objectForKey:@"filename"];
    NSURL *url = [[TrackList instanceWithDelegate:self] trackURLWithCutnum:cutnum tracknum:tracknum];

	_streamer = [[AudioStreamer alloc] initWithURL:url];

	progressUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:_streamer];
}

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (_streamer.bitRate != 0.0)
	{
		double progress = _streamer.progress;
		double duration = _streamer.duration;
		
		if (duration > 0)
		{
            /*
			[positionLabel setText:
             [NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
              progress,
              duration]];
			[progressSlider setEnabled:YES];
			[progressSlider setValue:100 * progress / duration];
             */
		}
		else
		{
            /*
			[progressSlider setEnabled:NO];
             */
		}
	}
	else
	{
        /*
		positionLabel.text = @"Time Played:";
         */
	}
}
//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
    /*
	if ([streamer isWaiting])
	{
		[self setButtonImageNamed:@"loadingbutton.png"];
	}
	else if ([streamer isPlaying])
	{
		[self setButtonImageNamed:@"stopbutton.png"];
	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		[self setButtonImageNamed:@"playbutton.png"];
	}
     */
}

-(void)trackDidFinishLoading
{
    [self startWithCutnum:_new_cutnum tracknum:_new_tracknum];
}

-(void)didFailWithError:(NSError *)error
{
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]Player cannot get TrackData:%@", error_str);
}


@end
