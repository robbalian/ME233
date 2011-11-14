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
    SENSOR_STATE_DISCONNECTED = 0,
    SENSOR_STATE_OFF,
    SENSOR_STATE_WARMING,
    SENSOR_STATE_CALCULATING,
    SENSOR_STATE_READY
};

@interface BACController : NSObject <CharReceiver>{
    NSMutableArray *readings;
    NSString *currentReading;
    int sensorState;
    id delegate;
    int secondsTillWarm;
    NSTimer *warmTimer;
}

-(int)getSecondsUntilSensorWarmedUp;
+(BACController*) getInstance;
-(NSString *)storeReading:(char)c;
-(double)getCurrentBAC;
-(void)receivedChar:(char)input;
-(void)sendCode:(char)code;
-(void)setState:(int)state;
-(void)sendTestChar;


@end


@protocol BACControllerDelegate


-(void)warmupSecondsLeft:(int)seconds;
-(void)sensorStateChanged:(int)state;
-(void)bacChanged:(double)bac;
-(void)startWithDelegate:(id)del;
@end