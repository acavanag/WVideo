//
//  WWAppDelegate.h
//  WWVideo
//
//  Created by Andrew Cavanagh on 3/7/14.
//  Copyright (c) 2014 WeddingWire. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
