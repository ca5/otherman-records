//
//  Playlist.h
//  OthermanRecords
//
//  Created by ca54makske on 13/03/04.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "Data.h"
#import "TrackList.h"



@interface PlayList : Data <TrackDelegate>
@property (readonly) NSString *currentCutnum;
@property (readonly) NSNumber *currentTracknum;
@property BOOL repeat;


+(PlayList *)instance;
-(BOOL)setCurrentIndexWithCutnum:(NSString *)cutnum tracknum:(NSNumber *)tracknum;
-(BOOL)next;
-(BOOL)prev;
-(void)setFromTrackList;


@end
