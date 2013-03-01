//
//  Data.m
//  OthermanRecords
//
//  Created by Ca5 on 13/02/04.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "Data.h"

@implementation Data
{
    NSMutableArray *list;
}

- (id)init
{
    list = [NSMutableArray array];
    return self;
}

- (BOOL)load
{
    return [self loadWithCache:YES];
}

- (BOOL)loadWithCache:(BOOL)cache
{
    //should be overridden
    return YES;
}

- (BOOL)clear
{
    list = [NSMutableArray array];
    return YES;
}

/**************** Override from Mutable Array	****************/
- (void)addObject:(id)anObject
{
    [list addObject:anObject];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [list insertObject:anObject atIndex:index];
}

- (void)removeLastObject
{
    [list removeLastObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [list removeObjectAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [list replaceObjectAtIndex:index withObject:anObject];
}

/**************** Override from Immutable Array	****************/

- (NSUInteger)count
{
    return [list count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [list objectAtIndex:index];
}



@end

