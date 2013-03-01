//
//  Favorite.h
//  OthermanRecords
//
//  Created by ca54makske on 13/02/24.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalData.h"

@interface Favorite : LocalData

- (id)init;
- (void)addFavoliteWithCutnum:(NSString *)cutnum tracknum:(NSNumber *)tracknum;
- (void)deleteFavoliteAtIndex:(NSUInteger) index;

@end
