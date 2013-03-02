//
//  AppDelegate.h
//  OthermanRecords
//
//  Created by Ca5 on 13/02/04.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumList.h"
#import "TrackList.h"
#import "StreamingPlayer.h"
#import "DBData.h"
#import "MultiRequestOperation.h"





@interface AppDelegate : UIResponder <UIApplicationDelegate,AlbumDelegate,TrackDelegate>

@property (strong, nonatomic) UIWindow *window;



@end
