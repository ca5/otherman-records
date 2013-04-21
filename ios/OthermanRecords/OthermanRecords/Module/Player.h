//
//  Player.h
//  OthermanRecords
//
//  Created by ca54makske on 13/02/25.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamingPlayer.h"
#import "AudioStreamer.h"
#import "TrackList.h"

@protocol PlayerDelegate
-(void) playerDidChangeCurrentCutnum:(NSString *)cutnum tracknum:(NSNumber *)tracknum;
-(void) playerDidChangeProgress:(double)progress duration:(double)duration;
-(void) playerDidChangeStatusToWaiting;
-(void) playerDidChangeStatusToPlaying;
-(void) playerDidChangeStatusToIdle;


@end

@interface Player : NSObject<TrackDelegate>
@property (readonly)NSString *cutnum;
@property (readonly)NSNumber *tracknum;

+(Player *)instanceWithDelegate:(id<PlayerDelegate>)delegate;
-(void)startWithCutnum:(NSString *)cutnum tracknum:(NSNumber *)tracknum;
-(BOOL)next;
-(BOOL)prev;
-(void)stop;
-(BOOL)isPlaying;

@end
