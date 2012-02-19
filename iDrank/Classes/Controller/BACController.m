//
//  BACController.m
//  Laser Tag
//
//  Created by Rob Balian on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BACController.h"
#import "iDrankAppDelegate.h"
#import "FSKSerialGenerator.h"
#include <ctype.h>

#define MIN_BLOW_DURATION 3.0
#define NO_BLOW_DURATION 10.0

#define ERROR_SIGNAL 'A'
#define TEST_CHAR 'T'

#define VERIFY_PING 'a'
#define VERIFY_ACK 'b'

#define WARM_PING 'c'
#define WARM_ACK 'd'

#define READY_PING 'e'
#define READY_ACK 'f'

#define OFF_PING 'g'
#define OFF_ACK 'h'


@implementation BACController

@synthesize eventArray, managedObjectContext, fetchedResultsController;

+(BACController*)sharedInstance {
    
	static BACController *_sharedInstance;
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
        });
    }
    
    return _sharedInstance;
}


-(void)sendTestChar {
    [self sendCode:TEST_CHAR];
}

-(id)init {
    if ((self = [super init])) {
        readings = [[NSMutableArray alloc] init];
        currentReading = [[[NSString alloc] init] retain];
        //testing       
    }
    return self;
}

-(void)sensorUnplugged {
    [self setState:DISCONNECTED];
    if (warmTimer != nil && ![warmTimer isEqual:[NSNull null]] && [warmTimer isValid]) [warmTimer invalidate]; 
    NSLog(@"Sensor unplugged");
}

-(void)verifySensor {
    NSLog(@"Verifying sensor...");
    [self sendCode:VERIFY_PING];
    if ([verifyRetryTimer isValid]) {
        [verifyRetryTimer invalidate];
        verifyRetryTimer = nil;
    }
    if (sensorState == DISCONNECTED) {
        verifyRetryTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(verifySensor) userInfo:nil repeats:NO];
    }
}

//Char TX
- (void) receivedChar:(char)input {
    
    //if we're not in read mode:
    if (sensorState < ON_READY) {
        NSLog(@"Received Char %c", input);
        switch (input) {
            case VERIFY_ACK:
                //verified!
                [self setState:OFF];
                [self sendCode:WARM_PING];
                if (verifyRetryTimer != nil && [verifyRetryTimer isValid]) { [verifyRetryTimer invalidate];
                    verifyRetryTimer = nil;
                }
                break;
            case OFF_ACK:
                [self setState:OFF];
                NSLog(@"Sensor State: OFF");
                break;
            
            case WARM_ACK:
                [self setState:ON_WARMING];
                [self startWarmupTimer];
                break;
            case READY_ACK:
                //start looking for blow
                [self setState:ON_READY];
                //start timer to turn the device off if unused
                noBlowTimer = [NSTimer scheduledTimerWithTimeInterval:NO_BLOW_DURATION target:self selector:@selector(noBlowTimerExpired) userInfo:nil repeats:NO];
            case TEST_CHAR:
                NSLog(@"Received Test Char");
                break;
            default:
                NSLog(@"Communication Error. Unexpected Char value");
                break;
        }
    } else {
        //else if we are in read mode, store the reading:
        [self storeReading:input];
    }
    
}


-(void)warmTimerExpired {
    [self sendCode:READY_PING];
}

-(void)blowDetected {
    [NSTimer scheduledTimerWithTimeInterval:MIN_BLOW_DURATION target:self selector:@selector(blowEnded) userInfo:nil repeats:NO];
    //start blowing timer
    //play sound!
    NSLog(@"Blow Detected");
    [self setState:ON_BLOWING_INTO];
    //now we're in business! storeReading should log these now!
}

-(void)blowEndedPrematurely {
    //display message
    [self setState:ON_READY];
    NSLog(@"Blow ended prematurely...");
    //[self startStayWarmTimer];
    //basically just regress to ON_READY state
}

-(void)blowEnded {
    //show bac via UI
    [self calculateBAC];
    NSLog(@"Successful blow! Show reading: ");
    //[self setState:OFF]; DON"T SET STATE UNTIL WE GET AN ACK
    [self setState:UNKNOWN];
    [self sendCode:OFF_PING];
}

- (void) sendCode:(char)code {
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    NSLog(@"Sending Char: %c", code);
    [[iDrankAppDelegate getInstance].generator writeByte:code];
}

-(void)storeReading:(char)c {
    //ok we have to check if you're actually blowing into it
    [readings addObject:[NSNumber numberWithInt:(uint8_t)c]];
    NSLog(@"Stored Reading: %u", (uint8_t)c);
    //if 
    if (sensorState == ON_READY && [self detectSensorBlow]) [self blowDetected];
    
    /*if (sensorState == SENSOR_STATE_READY && [self detectSensorBlow]) {
     [self setState:SENSOR_STATE_READING];
     readTimer = [NSTimer scheduledTimerWithTimeInterval:SENSOR_READ_SECONDS target:self selector:@selector(doneReading:) userInfo:nil repeats:NO];
     //start timer
     
     }*/
    //[delegate bacChanged:[self getCurrentBAC]];
}


//NOT IN USE NOW (probably need soon)
-(void)doneReading:(id)sender {
    [self calculateBAC];
    calculateTimer = [NSTimer scheduledTimerWithTimeInterval:SENSOR_CALCULATE_SECONDS target:self selector:@selector(doneCalculating:) userInfo:nil repeats:NO];
}


-(void)measureAgain {
    //start warming from current temp state (hmm)
    [self sendCode:WARM_PING];
    [readings removeAllObjects];
}

-(void)doneCalculating:(id)sender {
    [((iDrankAppDelegate *)[[UIApplication sharedApplication] delegate]) addBAC:nil];
}



//CALCULATION

-(void)calculateBAC {
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
    
    
    currentBAC = ((double)(arc4random() % 40)) / 100.0;
    //return bac > 0 ? bac : 0;
    //return .4*(((double)(rand()%10))/10.0);
}

-(BOOL)detectSensorBlow {
    
    //read last X readings
    //is it being used? GO
    
    if ([((NSNumber *)[readings objectAtIndex:([readings count]-1)]) intValue] > 225) return YES;
    return NO;
}


//TIMERS
-(void)warmTimerTick:(id)sender {
    if (secondsTillWarm > 1) {
        secondsTillWarm-= 1;
        [delegate warmupSecondsLeft:secondsTillWarm];
    } else {
        if (warmTimer) [warmTimer invalidate];
        warmTimer = nil;
        [self warmTimerExpired];
    }
}

-(void)startWarmupTimer {
    secondsTillWarm = SENSOR_WARMUP_SECONDS;
    warmTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(warmTimerTick:) userInfo:nil repeats:YES];
}

-(void)noBlowTimerExpired {
    //ok you didn't blow in time. Shut off sensor to save battery, jerk.
    //[self setState:OFF];
    [self setState:UNKNOWN];
    [self sendCode:OFF_PING];
}

//GETTERS AND SETTERS

-(double)getCurrentBAC {
    return currentBAC;
}

-(int)currentState {
    return sensorState;
}

-(void)setDelegate:(id)del {
    delegate = del;
}

-(void)setState:(int)state {
    
    
    sensorState = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stateChanged" object:self];
}


@end
