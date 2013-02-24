//
//  AppDelegate.h
//  OthermanRecords
//
//  Created by Ca5 on 13/02/04.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "Track.h"
#import "StreamingPlayer.h"
#import "LocalData.h"




@interface AppDelegate : UIResponder <UIApplicationDelegate,AlbumDelegate,TrackDelegate>

@property (strong, nonatomic) UIWindow *window;



@end
