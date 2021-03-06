//
//  Track.h
//  OthermanRecords
//
//  Created by Ca5 on 13/02/05.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlData.h"

@class TrackList;


@protocol TrackDelegate
-(void) trackDidFailWithError:(NSError *)error;
-(void) trackDidFinishLoading;
@end


@interface TrackList : XmlData <XmlDataDelegate>

+(TrackList *)instanceWithDelegate:(id<TrackDelegate>) delegate;

- (NSArray *)listWithCutnum:(NSString *)cutnum;

- (NSDictionary *)trackWithCutnum:(NSString *)cutnum tracknum:(NSNumber *)tracknum;
- (NSURL *)trackURLWithCutnum:(NSString *)cutnum tracknum:(NSNumber *)tracknum;
//- (TrackList *)sortedList;
@end
