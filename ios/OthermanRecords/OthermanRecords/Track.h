//
//  Track.h
//  OthermanRecords
//
//  Created by Ca5 on 13/02/05.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlData.h"

@class Track;

@protocol TrackDelegate
-(void) didFailWithError:(NSError *)error;
-(void) didFinishLoadingTrack:(Track *)data;
@end

@interface Track : XmlData <XmlDataDelegate>

+(Track *)getInstance:(id<TrackDelegate>) delegate;

@end
