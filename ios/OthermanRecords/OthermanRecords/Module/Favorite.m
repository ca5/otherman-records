//
//  Favorite.m
//  OthermanRecords
//
//  Created by ca54makske on 13/02/24.
//  Copyright (c) 2013年 Otherman-Records. All rights reserved.
//

#import "Favorite.h"

@implementation Favorite

+ (id)instance
{
    static dispatch_once_t pred;
    static Favorite *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[[self class] alloc] init];
    });
    return shared;
}

- (id)init
{
    return [super initWithTableName:@"Favorite" sortKeyName:@"timeStamp"];
}

- (void)addFavoliteWithCutnum:(NSString *)cutnum tracknum:(NSNumber *)tracknum
{
    NSLog(@"addFavoliteWithCutNum");
    [self addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                     cutnum, @"cutnum",
                     tracknum, @"tracknum",
                     nil]
     ];
    NSLog(@"addFavoliteWithCutNum");

}

- (void)deleteFavoliteAtIndex:(NSUInteger) index
{
    [self removeObjectAtIndex:index];
}

/**************** Override from  LocalData	****************/
- (void)addObject:(id)anObject
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    [newManagedObject setValue:[anObject objectForKey:@"cutnum"] forKey:@"cutnum"];
    [newManagedObject setValue:[anObject objectForKey:@"tracknum"] forKey:@"tracknum"];
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self load];
}

@end
