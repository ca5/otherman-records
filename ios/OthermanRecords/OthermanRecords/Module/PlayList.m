//
//  Playlist.m
//  OthermanRecords
//
//  Created by ca54makske on 13/03/04.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "PlayList.h"

@implementation PlayList
{
    NSUInteger _cindex;
}
@synthesize currentCutnum = _ccutnum;
@synthesize currentTracknum = _ctracknum;
@synthesize repeat = _repeat;

-(NSArray *)listWithCutnum:(NSString *)cutnum
{
    NSMutableArray *result = [NSMutableArray array];
    for(int i = 0; i < [self count]; i ++){
        if([cutnum isEqualToString:[[self objectAtIndex:i] objectForKey:@"cutnum"]]){
            [result addObject:[self objectAtIndex:i]];
        }
    }
    return result;
}

+(PlayList *)instance
{
    static dispatch_once_t pred;
    static PlayList *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

-(id)init
{
    return [super init];
}

-(BOOL)setCurrentIndexWithCutnum:(NSString *)cutnum tracknum:(NSString *)tracknum
{
    int i = 0;
    for(i = 0; i < [self count]; i++){
        if([[[self objectAtIndex:i] objectForKey:@"cutnum"] isEqualToString:cutnum]
           && [[[self objectAtIndex:i] objectForKey:@"num"] isEqualToString:tracknum]){
            break;
        }
    }
    
    //2nd check
    if([[self objectAtIndex:i] objectForKey:@"cutnum"] == cutnum
       && [[self objectAtIndex:i] objectForKey:@"num"] == tracknum){
        return NO;
    }
    _cindex = i;
    NSLog(@"[DEBUG]current index:%d",_cindex);
    _ccutnum = cutnum;
    _ctracknum = tracknum;
    return YES;
}

-(BOOL)next
{
    if([self objectAtIndex:_cindex + 1]){
        _cindex ++;
        _ccutnum = [[self objectAtIndex:_cindex] objectForKey:@"cutnum"];
        _ctracknum = [[self objectAtIndex:_cindex] objectForKey:@"num"];
        return YES;
    }else{
        if(_repeat){
            _cindex = 0;
            _ccutnum = [[self objectAtIndex:_cindex] objectForKey:@"cutnum"];
            _ctracknum = [[self objectAtIndex:_cindex] objectForKey:@"num"];
            return YES;
        }else{
            return NO;
        }
    }
}

-(BOOL)prev
{
    if([self objectAtIndex:_cindex - 1]){
        _cindex --;
        _ccutnum = [[self objectAtIndex:_cindex] objectForKey:@"cutnum"];
        _ctracknum = [[self objectAtIndex:_cindex] objectForKey:@"num"];
        return YES;
    }else{
        if(_repeat){
            _cindex = [self count] - 1;
            _ccutnum = [[self objectAtIndex:_cindex] objectForKey:@"cutnum"];
            _ctracknum = [[self objectAtIndex:_cindex] objectForKey:@"num"];
            return YES;
        }else{
            return NO;
        }
    }
}

-(void)setFromTrackList
{
    TrackList *tracklist = [TrackList instanceWithDelegate:self];
    if([tracklist count]){
        [self setList:tracklist];
    }else{
        [tracklist load];
    }
}

-(void)trackDidFinishLoading
{
    [self setFromTrackList];
}

-(void)didFailWithError:(NSError *)error
{
    NSString *error_str = [error localizedDescription];
    NSLog(@"[ERR]Playlist cannot get TrackData:%@", error_str);
}

@end
