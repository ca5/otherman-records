//
//  LocalData.m
//  otherman-records
//
//  Created by Ca5 on 12/10/29.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "LocalData.h"
#import "AppDelegate.h"

@implementation LocalData
{

}

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;




- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:_tableName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:_sortKeyName ascending:NO];

    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
    
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OthermanTables" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"OthermanTables.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

/*
- (void)insertNewObject:(NSDate *)timestamp
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:timestamp forKey:@"timeStamp"];
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}*/

- (void)deleteObject: (NSManagedObject *)object
{
    NSManagedObjectContext *managedObjectContext =[self.fetchedResultsController managedObjectContext];
    [managedObjectContext deleteObject:object];
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (id)initWithTableName:(NSString *)tableName sortKeyName:sortKeyName;
{
    _tableName = tableName;
    _sortKeyName = sortKeyName;
    return [super init];
}


/**************** Override from Data	****************/


- (BOOL)loadWithCache:(BOOL)force
{
    [super clear];
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if(error){
        NSString *error_str = [error localizedDescription];
        NSLog(@"[ERR]load localData error:%@", error_str);
        return NO;
    } else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        int maxNum = (int)[sectionInfo numberOfObjects];
        for(int i=0; i<maxNum; i++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
            NSLog(@"load localData [%d] :%@",i , [[object valueForKey:@"timeStamp"] description]);
            [super addObject:[object dictionaryWithValuesForKeys:[[[object entity] attributesByName] allKeys]]];
            NSLog(@"load localData2 [%d] :%@",i , [[self objectAtIndex:i] description]);
        }
    }
    return YES;
}

- (BOOL)clear
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    int maxNum = (int)[sectionInfo numberOfObjects];
    for(int i=0; i<maxNum; i++){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self deleteObject:object];
    }
    return YES;
}


/**************** Override from Mutable Array	****************/

- (void)addObject:(id)anObject
{
    /* should be overridden */
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setValue:anObject forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self load];
}


- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [self addObject:anObject]; //ignore order
}

- (void)removeLastObject
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    int maxNum = (int)[sectionInfo numberOfObjects];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:maxNum-1 inSection:0];
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self deleteObject:object];
    [self load];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self deleteObject:object];
    [self load];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [self removeObjectAtIndex:index];
    [self addObject:anObject];//ignore order
    [self load];
}


@end
