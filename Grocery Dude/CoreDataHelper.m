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
	
	/* Listing 3.9 */
	// Don't load store if it's already loaded
	if (_store) {
		return;
	}
	
	BOOL useMigrationManager = YES;
	
	if (useMigrationManager && [self isMigrationNecessaryForStore:[self storeURL]]) {
		[self performBackgroundManagedMigrationForStore:[self storeURL]];
	} else {
		
		NSDictionary *options =
		@{
		  // automatically attempts to migrate lower versioned persistent stores
		  NSMigratePersistentStoresAutomaticallyOption:@YES,
		  // attempts to infer a best guess at what attributes from the source model entities end up as attriblutes in the destination mmodel entities
		  NSInferMappingModelAutomaticallyOption:@YES, // disable when testing a mapping model
		  NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}
		  
		  };
		
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
	/* Listing 3.1
	 // Don't load store if it's already loaded
	 if (_store)
	 return;
	 
	 NSDictionary *options =
	 @{
	 // automatically attempts to migrate lower versioned persistent stores
	 NSMigratePersistentStoresAutomaticallyOption:@YES,
	 // attempts to infer a best guess at what attributes from the source model entities end up as attriblutes in the destination mmodel entities
	 NSInferMappingModelAutomaticallyOption:@YES, // disable when testing a mapping model
	 NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"}
	 
	 };
	 
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
	 */
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

/* Listing 3.5 */
#pragma mark - MIGRATION MANAGER

- (BOOL)isMigrationNecessaryForStore:(NSURL*)storeUrl {
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self storeURL].path]) {
		MyLog(@"SKIPPED MIGRATION: Source database missing.");
		return NO;
	}
	
	NSError *error = nil;
	NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
																							  URL:storeUrl
																							error:&error];
	NSManagedObjectModel *destinationModel = _coordinator.managedObjectModel;
	
	if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
		MyLog(@"SKIPPED MIGRATION: Source is already compatible.");
		return NO;
	}
	return YES;
}

/* Listing 3.6 */
- (BOOL)migrateStore:(NSURL*)sourceStore {
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	BOOL success = NO;
	NSError *error = nil;
	
	//STEP 1 - Gather the Source, Destination, and Mapping Model
	NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
																							  URL:sourceStore
																							error:&error];
	NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];
	
	NSManagedObjectModel *destinModel = _model;
	
	NSMappingModel *mappingModel = [NSMappingModel *mappingFromBundles:nil forSourceModel:sourceModel destinationModel:destinModel];
	
	// STEP 2 - Perform migration, assuming the mapping model isn't null
	if (mappingModel) {
		NSError *error = nil;
		NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel
																			  destinationModel:destinModel];
		[migrationManager addObserver:self
						   forKeyPath:@"migrationProgress"
							  options:NSKeyValueObservingOptionNew
							  context:NULL];
		
		NSURL *destinStore = [[self applicationStoresDirectory] URLByAppendingPathComponent:@"temp.sqlite"];
		
		success = [migrationManager migrateStoreFromURL:sourceStore
												   type:NSSQLiteStoreType
												options:nil
									   withMappingModel:mappingModel
									   toDestinationURL:destinStore
										destinationType:NSSQLiteStoreType
									 destinationOptions:nil
												  error:&error];
		
		if (success) {
			//STEP 3 - Replace the old store with the new migrated store
			if ([self replaceStore:sourceStore withStore:destinStore]) {
				MyLog(@"SUCCESSFULLY MIGRATED %@ to the Current Model", sourceStore.path);
				[migrationManager removeObserver:self
									  forKeyPath:@"migrationProgress"];
			}
		}
		else {
			MyLog(@"FAILED MIGRATION: %@", error);
		}
	}
	
	else {
		MyLog(@"FAILED MIGRATION: Mapping Model is null");
	}
	// indicates migration has finished, regardless of outcome
	return YES;
}

/* Listing 3.7 */
- (void)observeValueForKeyPath: (NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
	
	if ([keyPath isEqualToString:@"migrationProgress"]) {
		dispatch_async(dispatch_get_main_queue() ^{
			
			float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
			self.migrationVC.progressView.progress = progress;
			int percentage = progress * 100;
			NSString *string = [NSString stringWithFormat:@"Migration Progress: %i%%", percentage];
			
			MyLog(@"%@", string);
			self.migrationVC.label.text = string;
		});
	}
}

- (BOOL)replaceStore:(NSURL*)old withStore:(NSURL*)new {
	
	BOOL success = NO;
	NSError *Error = nil;
	
	if ([[NSFileManager defaultManager] removeItemAtURL:old error:&Error]) {
		
		Error = nil;
		
		if ([[NSFileManager defaultManager] moveItemAtURL:new toURL:old error:&Error]) {
			success = YES;
		}
		else {
			MyLog(@"FAILED to re-home new store %@", Error);
		}
	}
	else {
		MyLog(@"FAILED to remove old store %@: Error:%@", old, Error);
	}
	return success;
}

/* Listing 3.8 */
- (void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL {
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	// Show migration progress view preventing the user from using the app
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	self.migrationVC = [sb instantiateViewControllerWithIdentifier:@"migration"];
	UIApplication *sa = [UIApplication sharedApplication];
	UINavigationController *nc = (UINavigationController*)sa.keyWindow.rootViewController;
	[nc presentViewController:self.migrationVC animated:NO completion:nil];
	
	// Perform migration in the background, so it doesn't freeze the UI.
	// This way progress can be shown to the user
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
		BOOL done = [self migrationStore:storeURL];
		
		if (done) {
			//When migration finishes, add the newly migrated store
			dispatch_async(dispatch_get_main_queue(), ^{
				
				NSError *error = nil;
				_store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
													configuration:nil
															  URL:[self storeURL]
														  options:nil
															error:&error];
				if (!_store) {
					MyLog(@"Failed to add a migrated store. Error: %@", error);
					abort();
				}
				else {
					MyLog(@"Successfully added a migratd store: %@", _store);
				}
				[self.migrationVC dissmissViewControllerAnimated:NO completion:nil];
				self.migrationVC = nil;
			});
		}
		
	});
}


@end