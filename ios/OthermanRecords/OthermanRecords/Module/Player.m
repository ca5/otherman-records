//
//  Player.m
//  OthermanRecords
//
//  Created by ca54makske on 13/02/25.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "Player.h"
#import "PlayList.h"

@implementation Player
{
    NSString *_new_cutnum;
    NSString *_new_tracknum;
    AudioStreamer *_streamer;
    NSTimer *progressUpdateTimer;
    id<PlayerDelegate> _delegate;
}

@synthesize cutnum = _cutnum;
@synthesize tracknum = _tracknum;


+(Player *)instanceWithDelegate:(id<PlayerDelegate>)delegate
{
    static dispatch_once_t pred;
    static Player *shared = nil;

    
    dispatch_once(&pred, ^{
        shared = [[[self class] alloc] init];
    });
    return [shared setDelegate:delegate];
}

-(id)init
{
    return [super init];
}

-(id)setDelegate:(id<PlayerDelegate>)delegate
{
    _delegate = delegate;
    return self;
}




-(void)startWithCutnum:(NSString *)cutnum tracknum:(NSString *)tracknum;
{
    [[PlayList instance] setCurrentIndexWithCutnum:cutnum tracknum:tracknum];
    //if([cutnum isEqualToString:_cutnum] && [tracknum isEqualToString:_tracknum]){
        //[[StreamingPlayer getInstance] start];
    ///    [self createStreamerWithCutnum:cutnum tracknum:tracknum];
    //} else {
        if([[TrackList instanceWithDelegate:self] count] == 0){
            _new_cutnum = cutnum;
            _new_tracknum = tracknum;
            [[TrackList instanceWithDelegate:self] load];
        }else{
            [self destroyStreamer];

            [self createStreamerWithCutnum:cutnum tracknum:tracknum];
            [_streamer start];
        }
    //}
    _cutnum = cutnum;
    _tracknum = tracknum;
}

-(BOOL)next
{
    PlayList* playlist = [PlayList instance];
    if([playlist next]){
        if([_streamer isPlaying]){
            NSLog(@"play next track cutnum:%@ tracknum:%@", playlist.currentCutnum, playlist.currentTracknum);
            [self startWithCutnum:playlist.currentCutnum tracknum:playlist.currentTracknum];
        }else{
            //if use extra action
        }
        [_delegate playerDidChangeCurrentCutnum:playlist.currentCutnum tracknum:playlist.currentTracknum];
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)prev
{
    PlayList* playlist = [PlayList instance];
    if([playlist prev]){
        if([_streamer isPlaying]){
            [self startWithCutnum:playlist.currentCutnum tracknum:playlist.currentTracknum];
        }else{
            //TODO: change Player title etc...
        }
        [_delegate playerDidChangeCurrentCutnum:playlist.currentCutnum tracknum:playlist.currentTracknum];
        return YES;
    }else{
        return NO;
    }
}

-(void)stop
{
    [self destroyStreamer];
}


-(BOOL)isPlaying
{
    return [_streamer isPlaying];
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
        [_delegate playerDidChangeProgress:_streamer.progress duration:_streamer.duration];
		//double progress = _streamer.progress;
		//double duration = _streamer.duration;
		
        /*
		if (duration > 0)
		{
			[positionLabel setText:
             [NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
              progress,
              duration]];
			[progressSlider setEnabled:YES];
			[progressSlider setValue:100 * progress / duration];
		}
		else
		{
			[progressSlider setEnabled:NO];
		}
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
	if ([_streamer isWaiting])
	{
        [_delegate playerDidChangeStatusToWaiting];
	}
	else if ([_streamer isPlaying])
	{
        [_delegate playerDidChangeStatusToPlaying];
	}
	else if ([_streamer isIdle])
	{
        [_delegate playerDidChangeStatusToIdle];
	}
}

-(void)trackDidFinishLoading
{
    [self startWithCutnum:_new_cutnum tracknum:_new_tracknum];
}

-(void)trackDidFailWithError:(NSError *)error
{
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]Player cannot get TrackData:%@", error_str);
}


@end
