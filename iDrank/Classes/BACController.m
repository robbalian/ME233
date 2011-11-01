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
        
    }
    return self;
}

-(void)startWithDelegate:(id)del {
    //set delegate for callbacks
    delegate = del;
    //turn on sensor
    //start timer
    
    
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
    if (c == 32) {
        int num = [currentReading intValue];
        [readings addObject:[NSNumber numberWithInt:num]];
        returnVal = currentReading;
        currentReading = @"";
    } else {
        returnVal = nil;
        NSString *str = [currentReading stringByAppendingFormat:@"%c",c];
        currentReading = str;
        [currentReading retain];
    }
    [delegate bacChanged:[self getCurrentBAC]];
    return returnVal;
}

-(double)getCurrentBAC {
    int total = 0;
    int numReadings = 0;
    for (int i=[readings count]-10; i<[readings count]; i++) {
        if (i < 0) continue;
        total += [(NSNumber *)[readings objectAtIndex:i] intValue];
        numReadings +=1;
    }
    double average = (double)total / numReadings;
    double bac = (average-500)*.0008; 
    
    //return bac > 0 ? bac : 0;
    return .4*(((double)(rand()%10))/10.0);
}

-(void)testReceiveChar:(id)sender {
    for (int i=0; i<3; i++) {
        char c = rand() % 10 + '0';
        [self receivedChar:c];
    }
    [self receivedChar:' '];
}


- (void) receivedChar:(char)input {
    [self storeReading:input];
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
