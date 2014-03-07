//
//  ACCDMgr.h
//  WWVideo
//
//  Created by Andrew Cavanagh on 3/7/14.
//  Copyright (c) 2014 WeddingWire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video.h"

@interface ACCDMgr : NSObject

+ (ACCDMgr *)sharedInstance;
- (NSFetchedResultsController *)procureVidoesWithDelegate:(id<NSFetchedResultsControllerDelegate>)delegate;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, strong) NSManagedObjectContext *context;
@end
