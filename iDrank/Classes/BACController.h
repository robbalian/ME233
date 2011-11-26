//
//  BACController.h
//  Laser Tag
//
//  Created by Rob Balian on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CharReceiver.h"

#define SENSOR_WARMUP_SECONDS 5

enum {
    SENSOR_STATE_DISCONNECTED = 0,
    SENSOR_STATE_VERIFYING,
    SENSOR_STATE_OFF, //CONNECTED >=2 
    SENSOR_STATE_WARMING,
    SENSOR_STATE_READY,
    SENSOR_STATE_READING
};

@interface BACController : NSObject <CharReceiver>{
    NSMutableArray *readings;
    NSString *currentReading;
    int sensorState;
    id delegate;
    double secondsTillWarm;
    NSTimer *warmTimer;
}

-(void)setDelegate:(id)del;
-(int)getSecondsUntilSensorWarmedUp;
+(BACController*) getInstance;
-(NSString *)storeReading:(char)c;
-(double)getCurrentBAC;
-(void)receivedChar:(char)input;
-(void)sendCode:(char)code;
-(void)setState:(int)state;
-(void)sendTestChar;
-(void)verifySensor;
-(void)sensorUnplugged;

-(int)currentState;
@end


@protocol BACControllerDelegate


-(void)warmupSecondsLeft:(double)seconds;
-(void)sensorStateChanged:(int)state;
-(void)bacChanged:(double)bac;
-(void)startWithDelegate:(id)del;
@end