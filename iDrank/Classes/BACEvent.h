//
//  BACEvent.h
//  iDrank
//
//  Created by Rob Balian on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BACEvent : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * reading;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * idrank_id;

@end
