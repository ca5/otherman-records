//
//  PlayerViewController.h
//  OthermanRecords
//
//  Created by ca54makske on 13/02/24.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"


@interface PlayerViewController : UIViewController<PlayerDelegate>
@property NSString *cutnum;
@property NSString *tracknum;


@end
