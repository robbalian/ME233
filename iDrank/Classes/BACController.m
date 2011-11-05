//
//  BACController.m
//  Laser Tag
//
//  Created by Rob Balian on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BACController.h"
#import "SoftModemTerminalAppDelegate.h"
#import "FSKSerialGenerator.h"
#include <ctype.h>

#define NO_DEVICE 1

#define SIGNAL_SENSOR_POWER_ON 'a'
#define SIGNAL_SENSOR_POWER_OFF 'b'
#define SENSOR_WARMUP_SECONDS 10


@implementation BACController

BACController *instance;


+ (BACController *)getInstance {
    if (instance == nil) {
        instance = [[BACController alloc] init];
    }
    return instance;
}


-(id)init {
    if ((self = [super init])) {
        readings = [[NSMutableArray alloc] init];
        currentReading = [[[NSString alloc] init] retain];
        
        //testing
        [self setState:SENSOR_STATE_WARMING];
    
    }
    return self;
}


-(void)warmTimerTick:(id)sender {
    if (secondsTillWarm > 1) {
        secondsTillWarm--;
        [delegate warmupSecondsLeft:secondsTillWarm];
    } else {
        [warmTimer invalidate];
        [self setState:SENSOR_STATE_READY];
    }
}

-(void)setState:(int)state {
    sensorState = state;
    [delegate sensorStateChanged:state];
}

-(void)startWithDelegate:(id)del {
    //set delegate for callbacks
    delegate = del;
    if (sensorState != SENSOR_STATE_DISCONNECTED) {
        [self sendCode:SIGNAL_SENSOR_POWER_ON];
        //need some error checking to make sure it pings back
        
        secondsTillWarm = SENSOR_WARMUP_SECONDS;
        warmTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(warmTimerTick:) userInfo:nil repeats:YES];
    }
    
    //if (sensor plugged in) {
        //turn on sensor
        //wait for ready
        /* WAYS TO CHECK FOR READY
         
        //[delegate sensorStateChanged:SENSOR_STATE_WARMING
         Temp sensor (iphone interprets temps and alcohol readings)
         Start 15-30 second timer
         Wait until values stabilize (this one might work)
         
         */
    
    //} else (if sensor isn't plugged in) {
        
        //[delegate sensorStateChanged:SENSOR_STATE_DISCONNECTED
        
    //}
    
    /*[NSTimer scheduledTimerWithTimeInterval:2.0f
     target:self
     selector:@selector(sendA:)
     userInfo:nil
     repeats:YES];
     */
    
#ifdef NO_DEVICE
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(testReceiveChar:) userInfo:nil repeats:YES];
#endif
}

-(NSString *)storeReading:(char)c {
    NSString *returnVal = @"";    
    [readings addObject:[NSNumber numberWithInt:(uint8_t)c]];
    [delegate bacChanged:[self getCurrentBAC]];
    return returnVal;
}

-(double)getCurrentBAC {
    int total = 0;
    int numReadings = 0;
    for (int i=[readings count]-10; i<[readings count]; i++) {
        if (i < 0) continue;
        int reading = [(NSNumber *)[readings objectAtIndex:i] intValue];
        total += reading;
        numReadings +=1;
    }
    double average = (double)total / numReadings;
    double bac = (average-125)*.0011;
    
        
    return bac > 0 ? bac : 0;
    //return .4*(((double)(rand()%10))/10.0);
}


//TEST CODE for no device
-(void)testReceiveChar:(id)sender {
        char c = rand() % 155 + 100;
        [self receivedChar:c];
}


- (void) receivedChar:(char)input {
    [self storeReading:input];
    NSLog(@"%d", (uint8_t)input);
}

- (void) sendCode:(char)code {
	NSLog(@"Sending Char: %c", code);
    for (int i = 0; i < 1; i++) {
		[[SoftModemTerminalAppDelegate getInstance].generator writeByte:code];
	}
	for (int i = 0; i < 1; i++) {
		[[SoftModemTerminalAppDelegate getInstance].generator writeByte:0x04];
	}
}


@end
