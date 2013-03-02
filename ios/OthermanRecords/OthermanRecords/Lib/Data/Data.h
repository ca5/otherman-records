//
//  Data.h
//  OthermanRecords
//
//  Created by Ca5 on 13/02/04.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Data : NSMutableArray
- (id) init;
- (BOOL)load;
- (BOOL)loadWithCache:(BOOL)force;
- (BOOL)clear;
- (BOOL)setList:(NSMutableArray *)list;


@end
