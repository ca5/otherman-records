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
    NSMutableArray *_list;
}

- (id)init
{
    _list = [NSMutableArray array];
    return self;
}

- (BOOL)load
{
    return [self loadWithCache:YES];
}

- (BOOL)loadWithCache:(BOOL)cache
{
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return YES;
}

- (BOOL)clear
{
    _list = [NSMutableArray array];
    return YES;
}

- (BOOL)setList:(NSMutableArray *)list;
{
    _list = list;
}

/**************** Override from Mutable Array	****************/
- (void)addObject:(id)anObject
{
    [_list addObject:anObject];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [_list insertObject:anObject atIndex:index];
}

- (void)removeLastObject
{
    [_list removeLastObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [_list removeObjectAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [_list replaceObjectAtIndex:index withObject:anObject];
}

/**************** Override from Immutable Array	****************/

- (NSUInteger)count
{
    return [_list count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [_list objectAtIndex:index];
}



@end

