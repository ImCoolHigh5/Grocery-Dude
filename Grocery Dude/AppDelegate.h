//
//  AppDelegate.h
//  Grocery Dude
//
//  Created by Jason Welch on 5/19/14.
//  Copyright (c) 2014 Stevenson University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) CoreDataHelper *coreDataHelper;

@end
