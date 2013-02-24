//
//  LocalData.h
//  otherman-records
//
//  Created by Ca5 on 12/10/29.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Data.h"

@interface LocalData : Data <NSFetchedResultsControllerDelegate>
{
    NSString *_tableName;
    NSString *_sortKeyName;

}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;

- (id)initWithTableName:(NSString *)tableName sortKeyName:(NSString *)sortKeyName;

@end
