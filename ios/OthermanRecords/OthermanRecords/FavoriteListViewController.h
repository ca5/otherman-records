//
//  FavoriteListViewController.h
//  OthermanRecords
//
//  Created by ca54makske on 13/04/13.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumList.h"
#import "MultiRequestOperation.h"
#import "Jacket.h"

@interface FavoriteListViewController : UITableViewController <AlbumDelegate, JacketDelegate>

@end
