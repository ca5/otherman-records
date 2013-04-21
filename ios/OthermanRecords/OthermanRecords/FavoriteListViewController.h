//
//  FavoriteListViewController.h
//  OthermanRecords
//
//  Created by ca54makske on 13/04/13.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiRequestOperation.h"
#import "Jacket.h"
#import "Favorite.h"
#import "AlbumList.h"
#import "TrackList.h"



@interface FavoriteListViewController : UITableViewController <JacketDelegate,TrackDelegate>

@end
