//
//  BACController.m
//  Laser Tag
//
//  Created by Rob Balian on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BACController.h"
#import "iDrankAppDelegate.h"

#define MIN_BLOW_DURATION 5.0
#define NO_BLOW_DURATION 18.0

#define BLOW_DETECT_THRESHOLD (.01)

#define SENSOR_READINGS_DELAY (.01)

#define TARGET_SENSOR_VALUE 445


@implementation BACController

@synthesize eventArray, managedObjectContext, fetchedResultsController;
@synthesize fskController;

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




-(id)init {
    if ((self = [super init])) {
        readings = [[NSMutableArray alloc] init];
        currentReading = [[[NSString alloc] init] retain];
        //testing
        fskController = [[FSKController alloc] initWithDelegate:self];
        //[fskController testFSKController];
        
        expectingReading = NO;
//#ifdef NO_DEVICE
        //[self verifySensor];
//#endif
    }
    return self;
}

-(void)sensorUnplugged {
    [self setState:DISCONNECTED];
    if (warmTimer != nil && ![warmTimer isEqual:[NSNull null]] && [warmTimer isValid]) [warmTimer invalidate]; 
    if (noBlowTimer != nil && ![noBlowTimer isEqual:[NSNull null]] && [noBlowTimer isValid]) [noBlowTimer invalidate]; 
    
    
    [readings removeAllObjects];
    [fskController sensorUnplugged];
    NSLog(@"Sensor unplugged");
}

-(void)verifySensor {
#ifdef NO_DEVICE
    //set to "connected"
    //[self receivedChar:VERIFY_ACK];
    //[self setState:<#(int)#>
    //[self receivedChar:WARM_ACK];
    
#else
    if (sensorState == DISCONNECTED) {
        NSLog(@"Verifying sensor...");
        [fskController device_verify];
        verifyRetryTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(verifySensor) userInfo:nil repeats:NO];
    } 
#endif
}


-(void)warmTimerExpired {
    //all warmed up, we're in ready mode
    //NSLog(<#NSString *format, ...#>)
    [self setState:ON_READY];
    //start no blow timer so we don't keep heater on too long if no one blows
    noBlowTimer = [[NSTimer scheduledTimerWithTimeInterval:NO_BLOW_DURATION target:self selector:@selector(noBlowTimerExpired) userInfo:nil repeats:NO] retain];
    maxSensorDifference = 0;
}

-(void)requestSensorReadingFromDevice {
    [fskController requestReading];
    NSLog(@"Requesting Sensor Data from Device");
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
    [self stopRequestingSensorData];
    [self setState:ON_READY];
    NSLog(@"Blow ended prematurely...");
    currentBAC = 0.0;
    //currentBAC = 0.0;
    //[self startStayWarmTimer];
    //basically just regress to ON_READY state
}

-(void)blowEnded {
    //show bac via UI
    
    [self stopRequestingSensorData];
    if (noBlowTimer != nil && ![noBlowTimer isEqual:[NSNull null]] && [noBlowTimer isValid]) {
        [noBlowTimer invalidate];
        noBlowTimer = nil;
    }
    [self calculateBAC];
    NSLog(@"Successful blow! Show reading: ");
    [((iDrankAppDelegate *)[[UIApplication sharedApplication] delegate]) addBAC:nil];
    NSLog(@"Logging BAC");
    [self setState:UNKNOWN];
    [fskController device_turnHeaterOff];
    
#ifdef NO_DEVICE
    [self setState:OFF];
#endif
}



-(void)storeReading:(int)reading {
    //ok we have to check if you're actually blowing into it
    //structure! [{timestamp:001259235, reading:163}, ...]
    
    NSDictionary *readingDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] - readingStartSeconds], @"time", [NSNumber numberWithInt:reading],@"reading", nil];
    [readings addObject:readingDict];
    NSLog(@"Stored Reading: %d", reading);
    //if 
    if (sensorState == ON_READY && [self detectSensorBlow]) [self blowDetected];
    
    
    
    /*if (sensorState == SENSOR_STATE_READY && [self detectSensorBlow]) {
     [self setState:SENSOR_STATE_READING];
     readTimer = [NSTimer scheduledTimerWithTimeInterval:SENSOR_READ_SECONDS target:self selector:@selector(doneReading:) userInfo:nil repeats:NO];
     //start timer
     
     }*/
    //[delegate bacChanged:[self getCurrentBAC]];
}

-(void)sendTestChar {
    [fskController sendTestChar];
}


//NOT IN USE NOW (probably need soon)
-(void)doneReading:(id)sender {
    [self calculateBAC];
    calculateTimer = [NSTimer scheduledTimerWithTimeInterval:SENSOR_CALCULATE_SECONDS target:self selector:@selector(doneCalculating:) userInfo:nil repeats:NO];
}

-(void)measureAgain {
    //start warming from current temp state (hmm)
    [fskController device_turnHeaterOn];
    [readings removeAllObjects];
#ifdef NO_DEVICE
    [self verifySensor];
    
#endif
    
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
        int reading = [(NSNumber *)[[readings objectAtIndex:i] objectForKey:@"reading"] intValue];
        total += reading;
        numReadings +=1;
    }
    double average = (double)total / numReadings;
    double bac = (average-125)*.0011;
    
    //Get at me Wolfram Alpha y = 0.0000825397 x^2-0.00171429 x+0.00888889
    double x = (double)maxSensorDifference;
    currentBAC = (0.0000825397*(x*x))-(0.00171429*x)+0.00888889;
    
    //currentBAC = ((double)maxSensorDifference-10.0) / 180.0;
    if (currentBAC <= .01) currentBAC = 0.0;
    
    //currentBAC = ((double)(arc4random() % 40)) / 100.0;
    //return bac > 0 ? bac : 0;
    //return .4*(((double)(rand()%10))/10.0);
}

-(BOOL)detectSensorBlow {
    if ([readings count] < 2) return NO;
    //read last X readings
    //is it being used? GO
    int num = 0;
    //ok basically always at this point
    for (int i=0; i<2; i++) {
        //starting with second-to-latest value...
        num += [((NSNumber *)[[readings objectAtIndex:([readings count]-i-2)] objectForKey:@"reading"]) intValue];
    }
    double average = ((double)num/2.0);
    double difference = fabs((average - (double)[((NSNumber *)[[readings objectAtIndex:([readings count]-1)] objectForKey:@"reading"]) intValue]) / average);
    
    if (difference > BLOW_DETECT_THRESHOLD) return YES;
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
    NSLog(@"Starting warmup timer");
    secondsTillWarm = SENSOR_WARMUP_SECONDS;
    warmTimer = [[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(warmTimerTick:) userInfo:nil repeats:YES] retain];
}

-(void)noBlowTimerExpired {
    //ok you didn't blow in time. Shut off sensor to save battery, jerk.
    //[self setState:OFF];
    NSLog(@"No Blow Timer Expired");
    noBlowTimer = nil;
    [self stopRequestingSensorData];
    
    [self setState:UNKNOWN];
    [fskController device_turnHeaterOff];
    currentBAC = 0.0;
}

-(void)stopRequestingSensorData {
    if (sensorReadingTimer != nil && [sensorReadingTimer isValid]) {
        [sensorReadingTimer invalidate];
        sensorReadingTimer = nil;
    }
    expectingReading = NO;
}



//FSK Delegate Functions



-(void)receivedSensorData:(int)data {
    if (sensorState == ON_WARMING || sensorState == ON_READY || sensorState == ON_BLOWING_INTO) {
        [self requestSensorReadingFromDevice]; //omg request ANOTHER ONE
    }
    if (data < 100) return;
    
    
    if (sensorState == ON_WARMING) sensorInitialReading = data; //update this while we're warming so we can get a good diff
    
    if (sensorState == ON_BLOWING_INTO && sensorInitialReading - data > maxSensorDifference) maxSensorDifference = sensorInitialReading - data;
    NSLog(@"Received Sensor Data: %d", data);
    
    [self storeReading:data];
    
        [self checkDoneWarming];
}

-(void)checkDoneWarming {
    if ([readings count] < 3) return;
    int num = 0;
    for (int i=0; i<3; i++) {
        num += [((NSNumber *)[[readings objectAtIndex:([readings count]-i-1)] objectForKey:@"reading"]) intValue];
    }
    double average = ((double)num/3.0);
    if (sensorState == ON_WARMING && average > TARGET_SENSOR_VALUE) {
        //we're going to stop warming prematurely
        if (warmTimer && [warmTimer isValid]) [warmTimer invalidate];
        warmTimer = nil;
        [self warmTimerExpired];
    }
}

-(void)receivedVerifiedAck {
    NSLog(@"Received Verify Ack");
    currentBAC = 0.0;
    [self setState:OFF];
    [fskController device_turnHeaterOn];
}

-(void)receivedVoltageData:(double)data {
    
}

-(void)receivedTemperatureData:(double)data {
    
}

-(void)receivedHeaterOnAck {
    [self setState:ON_WARMING];
    [self startWarmupTimer];
    [self requestSensorReadingFromDevice];
    readingStartSeconds = [[NSDate date] timeIntervalSince1970];
}

-(void)receivedHeaterOffAck {
    NSLog(@"Heater OFF");
    [self setState:OFF];
    [self writeFileToDocumentDirectory];
}

-(void)receivedOffAck {
    
}

//GETTERS AND SETTERS

-(int)getLatestSensorReading {
    if ([readings count] == 0) return -1;
    return [[[readings objectAtIndex:([readings count]-1)] objectForKey:@"reading"] intValue];
}

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
    if (sensorState == state) return;
    sensorState = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stateChanged" object:self];
}

//debugging data methods

- (void) writeFileToDocumentDirectory
{
    
    NSString *csvString = @"Seconds, Reading\r\n";
    NSLog(@"Readings dict: %@", readings);
    
    for (NSDictionary *dict in readings) {
        csvString = [csvString stringByAppendingFormat:@"%f,%d\r\n", [(NSNumber *)[dict objectForKey:@"time"] doubleValue], [(NSNumber *)[dict objectForKey:@"reading"] intValue]];
    }
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        // Path to save dictionary
        NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"MM-dd 'at' HH_mm_ss"];
        NSString *fileName = [NSString stringWithFormat:@"%@.csv", [formatter stringFromDate:[NSDate date]]];
        
        NSString  *dictPath = [[paths objectAtIndex:0] 
                               stringByAppendingPathComponent:fileName];
        NSLog(@"Path: %@", dictPath);
        NSLog(@"Writing Output File to iTunes : %@", fileName);
        
        // Write dictionary
        [csvString writeToFile:dictPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
    }
}

@end