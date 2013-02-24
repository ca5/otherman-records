//
//  Album.h
//  OthermanRecords
//
//  Created by Ca5 on 13/02/06.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlData.h"

@class Album;

@protocol AlbumDelegate
-(void) didFailWithError:(NSError *)error;
-(void) didFinishLoadingAlbum:(Album *)data;
@end

@interface Album : XmlData <XmlDataDelegate>

+(Album *)getInstance:(id<AlbumDelegate>) delegate;

@end


