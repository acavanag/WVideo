//
//  Video.h
//  WWVideo
//
//  Created by Andrew Cavanagh on 3/7/14.
//  Copyright (c) 2014 WeddingWire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Video : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * image;

@end
