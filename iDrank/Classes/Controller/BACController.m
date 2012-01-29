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

#define SIGNAL_VERIFY_PING 'a'
#define SIGNAL_VERIFY_ACK 'c'

#define SIGNAL_ON_PING 'e'
#define SIGNAL_ON_ACK 'g'

#define SIGNAL_READY_PING 'i'
#define SIGNAL_READY_ACK 'k'

#define SIGNAL_OFF_PING 'm'
#define SIGNAL_OFF_ACK 'o'


#define TEST_CHAR 'z'

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
    //NSLog(@"sending test char: %c", TEST_CHAR);
    
#ifdef USING_HIJACK
    [((iDrankAppDelegate *)[[UIApplication sharedApplication] delegate]) sendData:'z'];
#endif

#ifdef TARGET_IPHONE_SIMULATOR
    //[self setState:SENSOR_STATE_CALCULATING];
    //send past READING
    if (sensorState == SENSOR_STATE_READY) [self doneReading:nil];
#else
#ifdef USING_FSK
    [self sendCode:TEST_CHAR];
#endif
#endif
}

-(id)init {
    if ((self = [super init])) {
        readings = [[NSMutableArray alloc] init];
        currentReading = [[[NSString alloc] init] retain];
        //testing
        //[self setState:SENSOR_STATE_WARMING];        
    }
    return self;
}

-(void)verifySensor {
    NSLog(@"Verifying sensor");
#ifdef NO_IDRANK
    ///[self fetchRecords];
    [self setState:SENSOR_STATE_WARMING];
    [self startWarmupTimer];
#else
    [self sendCode:SIGNAL_VERIFY_PING];
    [self setState:SENSOR_STATE_VERIFYING];
#endif
}

-(void)sensorUnplugged {
    [self setState:SENSOR_STATE_DISCONNECTED];
    if (warmTimer != nil && [warmTimer isValid]) [warmTimer invalidate]; 
    NSLog(@"Sensor unplugged");
}

-(void)setDelegate:(id)del {
    delegate = del;
}

//Char TX
- (void) receivedChar:(char)input {
    NSLog(@"Received Char %d", (uint8_t)input);
    if (sensorState == SENSOR_STATE_VERIFYING && input == SIGNAL_VERIFY_ACK) {
        [self setState:SENSOR_STATE_OFF];
        [self sendCode:SIGNAL_ON_PING];
        NSLog(@"Verified, turning on");
    } else if (sensorState == SENSOR_STATE_OFF && input == SIGNAL_ON_ACK) {
        [self setState:SENSOR_STATE_WARMING];
        [self startWarmupTimer];
        //now we wait...
        //Timer starts here
        NSLog(@"Sensor on, warming up");
    } else if (sensorState == SENSOR_STATE_WARMING && input == SIGNAL_READY_ACK) {
        [self setState:SENSOR_STATE_READY];
        //now ready to read
        NSLog(@"Sensor ready to read");
        
    } else if (sensorState == SENSOR_STATE_READING || sensorState == SENSOR_STATE_READY) {
        [self storeReading:input];
    }
}

-(void)warmTimerTick:(id)sender {
    if (secondsTillWarm > 1) {
        secondsTillWarm-= 1;
        [delegate warmupSecondsLeft:secondsTillWarm];
    } else {
        if (warmTimer) [warmTimer invalidate];
        warmTimer = nil;
#ifdef NO_IDRANK
        [self setState:SENSOR_STATE_READY];
#else
        [self sendCode:SIGNAL_READY_PING];
#endif   
        //notify sensor that it should be ready
        //wait for ack in receivedChar
        //[self setState:SENSOR_STATE_READY];
    }
}

-(void)setState:(int)state {
    sensorState = state;
    //[delegate sensorStateChanged:state];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stateChanged" object:self];
}

-(void)startWarmupTimer {
    secondsTillWarm = SENSOR_WARMUP_SECONDS;
    warmTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(warmTimerTick:) userInfo:nil repeats:YES];
}

- (void) sendCode:(char)code {
    UInt32 sessionCategory = kAudioSessionCategory_AmbientSound;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    
    NSLog(@"Sending Char: %c", code);
 		[[iDrankAppDelegate getInstance].generator writeByte:code];
}

-(NSString *)storeReading:(char)c {
    NSString *returnVal = @"";
    [readings addObject:[NSNumber numberWithInt:(uint8_t)c]];
    if (sensorState == SENSOR_STATE_READY && [self detectSensorBlow]) {
        [self setState:SENSOR_STATE_READING];
            readTimer = [NSTimer scheduledTimerWithTimeInterval:SENSOR_READ_SECONDS target:self selector:@selector(doneReading:) userInfo:nil repeats:NO];
        //start timer
        
    }
    //[delegate bacChanged:[self getCurrentBAC]];
    return returnVal;
}

-(void)doneReading:(id)sender {
    [self setState:SENSOR_STATE_CALCULATING];
    [self sendCode:SIGNAL_OFF_PING]; //error checking later...
    //turn heater off, done with sensor now

    [self calculateBAC];
    calculateTimer = [NSTimer scheduledTimerWithTimeInterval:SENSOR_CALCULATE_SECONDS target:self selector:@selector(doneCalculating:) userInfo:nil repeats:NO];
}

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


-(void)measureAgain {
    //start warming from current temp state (estimated)
    [self startWarmupTimer];
    [self sendCode:SIGNAL_ON_PING];
    [self setState:SENSOR_STATE_WARMING];
}

-(void)doneCalculating:(id)sender {
    [((iDrankAppDelegate *)[[UIApplication sharedApplication] delegate]) addBAC:nil];
    [self setState:SENSOR_STATE_DONE];
    [self setState:SENSOR_STATE_OFF];
    //[self addBAC:nil]; //add to our database on the phone
}

-(BOOL)detectSensorBlow {
    //read last X readings
    //is it being used? GO
    
    return YES;
}

-(double)getCurrentBAC {
    return currentBAC;
}

-(int)currentState {
    return sensorState;
}

//TEST CODE for no device
-(void)testReceiveChar:(id)sender {
        char c = rand() % 155 + 100;
        [self receivedChar:c];
}

@end
