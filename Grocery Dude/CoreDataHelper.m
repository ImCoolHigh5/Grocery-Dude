//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by Jason Welch on 5/19/14.
//  Copyright (c) 2014 Stevenson University. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

#pragma mark - FILES

NSString *storeFilename = @"Grocery-Dude.sqlite";

// To persist anything to disk, Core Data needs to know where in the file system persistent store files should be located
#pragma mark - PATHS

// returns an NSString representing the path to the application's documents directory
- (NSString*) applicationDocumentDirectory {
	
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	return [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) lastObject];
}

// appends a directory called Stores to the application's documents directory and then returns it in an NSURL
- (NSURL*) applicationStoresDirectory {
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	NSURL *storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentDirectory]] URLByAppendingPathComponent:@"Stores"];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
		NSError *error = nil;
		
		if ([fileManager createDirectoryAtURL:storesDirectory
				  withIntermediateDirectories:YES
								   attributes:nil
										error:&error]) {
			MyLog(@"Successfully created Stores directory");
		} else {
			MyLog(@"FAILED to create Stores directory: %@", error);
		}
	}
	
	return storesDirectory;
}

// appends the persistent store filename to the store's directory path
- (NSURL*) storeURL {
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFilename];
}

// Contains the three methods responsible for the initial setup of Core Data
#pragma mark - SETUP

// runs automatically when an instance of CoreDataHelper is created
- (id) init {
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	self = [super init];
	
	// Alternative to if(self) {...} else return nil
	if (!self) {
		return nil;
	}
	
	// Points to the managed object model, which is initiated from all available data model files (object graphs) found in the main bundle
	_model = [NSManagedObjectModel mergedModelFromBundles:nil];
	// Points to a persistant store coordinator, which is initialized based on the _model pointer to the managed object model just created
	_coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
	// Points to a managed object context, which is initialized with a concurrency type that tells it to run on a "main thread" queue
	_context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	
	[_context setPersistentStoreCoordinator:_coordinator];
	
	return self;
}

//
- (void) loadStore {
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	// Don't load store if it's already loaded
	if (_store)
		return;
	
	NSDictionary *options = @{NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}};
	
	// Used to capture any errors that occur during setup
	NSError *error = nil;
	// Holds a pointer a SQLite persistent store, added via addPersistentStoreWithType
	_store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
										configuration:nil
												  URL:[self storeURL]
											  options:options
												error:&error];
	if (!_store) {
		MyLog(@"Failed to add store. Error: %@", error);
		abort();
	} else {
		MyLog(@"Successfully added store: %@", _store);
	}
}

// Just calls loadStore
- (void) setupCoreData {
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	[self loadStore];
}

// Saving changes from _context to the _store
#pragma mark - SAVING

// Sending the context a save: message
-(void) saveContext {
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	if ([_context hasChanges]) {
		NSError *error = nil;
		if ([_context save:&error]) {
			MyLog(@"_context SAVED changes to persistent store");
		} else {
			MyLog(@"Failed to save _context: %@", error);
		}
	} else {
		MyLog(@"SKIPPED _context save, there are no changes!");
	}
}
@end
