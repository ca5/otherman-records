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


@interface Player : NSObject<TrackDelegate>
@property (readonly)NSString *cutnum;
@property (readonly)NSString *tracknum;

+(Player *)instance;
-(void)startWithCutnum:(NSString *)cutnum tracknum:(NSString *)tracknum;

@end
