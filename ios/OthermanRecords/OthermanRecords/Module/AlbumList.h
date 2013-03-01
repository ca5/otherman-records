//
//  Album.h
//  OthermanRecords
//
//  Created by Ca5 on 13/02/06.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlData.h"

@class AlbumList;

@protocol AlbumDelegate
-(void) didFailWithError:(NSError *)error;
-(void) albumDidFinishLoading;
@end

@interface AlbumList : XmlData <XmlDataDelegate>

+(AlbumList *)instanceWithDelegate:(id<AlbumDelegate>) delegate;

- (NSDictionary *)albumWithCutnum:(NSString *)cutnum;
- (NSURL *)jacketURLWithCutnum:(NSString *)cutnum;
- (NSURL *)thumbnailURLWithCutnum:(NSString *)cutnum;
@end


