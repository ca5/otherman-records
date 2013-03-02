//
//  AlbumListViewController.h
//  OthermanRecords
//
//  Created by ca54makske on 13/02/24.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackList.h"
#import "Jacket.h"

@interface AlbumListViewController : UITableViewController <TrackDelegate,JacketDelegate>
@property NSString *cutnum;


@end
