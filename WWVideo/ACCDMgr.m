//
//  ACCDMgr.m
//  WWVideo
//
//  Created by Andrew Cavanagh on 3/7/14.
//  Copyright (c) 2014 WeddingWire. All rights reserved.
//

#import "ACCDMgr.h"

@implementation ACCDMgr

+ (ACCDMgr *)sharedInstance {
    static ACCDMgr *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (NSFetchedResultsController *)procureVidoesWithDelegate:(id<NSFetchedResultsControllerDelegate>)delegate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Video" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:0];
    [fetchRequest setFetchLimit:0];
    [fetchRequest setIncludesSubentities:YES];
    [fetchRequest setIncludesPropertyValues:YES];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    [aFetchedResultsController setDelegate:delegate];
    
    [aFetchedResultsController performFetch:nil];
    
    return aFetchedResultsController;
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
