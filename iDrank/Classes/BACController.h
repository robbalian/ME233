//
//  BACController.h
//  Laser Tag
//
//  Created by Rob Balian on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CharReceiver.h"


enum {
    SENSOR_STATE_OFF = 0,
    SENSOR_STATE_WARMING,
    SENSOR_STATE_READY
};

@interface BACController : NSObject <CharReceiver>{
    NSMutableArray *readings;
    NSString *currentReading;
    int sensorState;
    id delegate;
}

+(BACController*) getInstance;
-(NSString *)storeReading:(char)c;
-(double)getCurrentBAC;

@end


@protocol BACControllerDelegate

-(void)sensorStateChanged:(int)state;
-(void)bacChanged:(double)bac;
-(void)startWithDelegate:(id)del;
@end