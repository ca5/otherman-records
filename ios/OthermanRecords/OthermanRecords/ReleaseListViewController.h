//
//  ReleaseListViewController.h
//  OthermanRecords
//
//  Created by ca54makske on 13/02/25.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlbumList.h"
#import "MultiRequestOperation.h"
#import "Jacket.h"


@interface ReleaseListViewController : UITableViewController <AlbumDelegate, JacketDelegate>

@end
