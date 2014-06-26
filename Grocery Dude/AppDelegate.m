//
//  AppDelegate.m
//  Grocery Dude
//
//  Created by Jason Welch on 5/19/14.
//  Copyright (c) 2014 Stevenson University. All rights reserved.
//

#import "AppDelegate.h"
#import "Item.h"
/* Listing 3.2
 #import "Measurement.h" */
/* Listing 3.4
 #import "Amount.h" */
/* Listing 3.10 */
#import "Unit.h"

@implementation AppDelegate

- (void)demo {
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	/* Listing 3.2
	 // Time for a ton of test data using Management entities
	 for (int i = 1; i < 5000; i++) {
	 Measurement *newMeasurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement"
	 inManagedObjectContext:_coreDataHelper.context];
	 
	 newMeasurement.abc = [NSString stringWithFormat:@"--->> LOTS OF TEST DATA x%i", i];
	 MyLog(@"Inserted %@", newMeasurement.abc);
	 }
	 [_coreDataHelper saveContext];
	 */
	/* Listing 3.3
	 // fetches a small sample of Measurement data (50) to show what is in the persistant store
	 NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
	 [request setFetchLimit:50];
	 NSError *error = nil;
	 NSArray *fetchedObjects = [_coreDataHelper.context executeFetchRequest:request error:&error];
	 
	 if (error) {
	 MyLog(@"%@", error);
	 } else {
	 for (Measurement *measurement in fetchedObjects) {
	 MyLog(@"Fetched Object = %@", measure.abc);
	 }
	 }
	 */
	/* Listing 3.4
	 // fetches a small sample of Measurement data (50) to show what is in the persistant store
	 NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Amount"];
	 [request setFetchLimit:50];
	 NSError *error = nil;
	 NSArray *fetchedObjects = [_coreDataHelper.context executeFetchRequest:request error:&error];
	 
	 if (error) {
	 MyLog(@"%@", error);
	 } else {
	 for (Amount *amount in fetchedObjects) {
	 MyLog(@"Fetched Object = %@", amount.xyz);
	 }
	 }
	 */
	
	/* Listing 3.4 */
	// fetches a small sample of Measurement data (50) to show what is in the persistant store
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
	[request setFetchLimit:50];
	NSError *error = nil;
	NSArray *fetchedObjects = [_coreDataHelper.context executeFetchRequest:request error:&error];
	
	if (error) {
		MyLog(@"%@", error);
	} else {
		for (Unit *unit in fetchedObjects) {
			MyLog(@"Fetched Object = %@", unit.name);
		}
	}
	
	
	//	[[[_coreDataHelper model] fetchRequestTemplateForName:@"Test"] copy];
	
	
	//	NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
	//	[request setSortDescriptors:[NSArray arrayWithObject:sort]];
	//
	//	NSPredicate *filter = [NSPredicate predicateWithFormat:@"name != %@", @"Coffee"];
	//	[request setPredicate:filter];
	
	//	NSArray *fetchedObjects = [_coreDataHelper.context executeFetchRequest:request error:nil];
	//
	//	for (Item *item in fetchedObjects) {
	//		MyLog(@"Deleting Object '%@'", item.name);
	//		[_coreDataHelper.context deleteObject:item];
	//		MyLog(@"Fetched Object = %@", item.name);
	//	}
	
	//	NSArray *newItemNames = [NSArray arrayWithObjects:@"Apples", @"Milk", @"Bread", @"Cheese", @"Sausages", @"Butter", @"Orange Juice", @"Cereal", @"Coffee", @"Eggs", @"Tomatoes", @"Fish", nil];
	//
	//	for (NSString *newItemName in newItemNames) {
	//		Item *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
	//													  inManagedObjectContext:_coreDataHelper.context];
	//		newItem.name = newItemName;
	//		MyLog(@"Inserted New Managed Object for '%@'", newItem.name);
	//	}
}



// Returns a non-nil CoreDataHelper instance
- (CoreDataHelper*)cdh {
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	if (!_coreDataHelper) {
		_coreDataHelper = [CoreDataHelper new];
		[_coreDataHelper setupCoreData];
	}
	
	return _coreDataHelper;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	[[self cdh] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	
	// Access to an appropriate context
	[self cdh];
	[self demo];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	MyLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	[[self cdh] saveContext];
}

@end
