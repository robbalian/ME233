//
//  Event.h
//  iDrank
//
//  Created by Rob Balian on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * blood_alcohol_content;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * user_id;

@end
