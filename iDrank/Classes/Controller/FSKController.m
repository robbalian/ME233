//
//  FSKController.m
//  iDrank
//
//  Created by Rob Balian on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FSKController.h"
#import "FSKSerialGenerator.h"
#include <ctype.h>
#import "iDrankAppDelegate.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

#define NO_INSTRUCTION -1

#define TIMEOUT_SECONDS (1.0)

#define ERROR_SIGNAL 'A'
#define TEST_CHAR 'T'

#define VERIFY_PING (0x01)
#define VERIFY_ACK  (0x02)
#define WARM_PING   (0x03)
#define WARM_ACK    (0x04)
#define OFF_PING    (0x05)
#define OFF_ACK     (0x06)

#define S_DATA_PING (0x07)// sensor value request - returns 8 bit value 
#define S_DATA_ACK  (0x08)


#define INSTRUCTION_BITS(c) c>>3
#define PACK_INSTRUCTION_BIT(c) c<<3


#define T_DATA_PING 'f' // temperature value request - return 8 bit value (10* temp [c])
#define V_DATA_PING 'g' // voltage value request - returns 7 bit value (10* voltage [V])

#define SERIAL_NUMBER_DATA_PING 'j'
#define BATCH_NUMBER_DATA_PING 'k'

@implementation FSKController

- (id) initWithDelegate:(BACController *)del {
    self = [super init];
    if (self != nil) {
        delegate = del;
        parsingState = IDLE;
        numBytesExpected = 0;
        charBuffer = [[NSMutableArray alloc] initWithCapacity:MAX_PAYLOAD];
        sendQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)testFSKController {
    NSLog(@"Testing FSK Controller --BEGIN--");
    /*[self receivedChar:(uint8_t)0xf3]; //packet header
     [self receivedChar:(uint8_t)0xFF]; //PAYLOAD
     [self receivedChar:(uint8_t)0x00]; //PAYLOAD
     [self receivedChar:(uint8_t)0xa4]; //PAYLOAD
     [self receivedChar:(uint8_t)0xa3]; //parity
     */
    [self device_verify];
    [self receivedChar:VERIFY_ACK<<3]; //fake ack
    
    [self requestReading];
    [self receivedChar:(char)(S_DATA_ACK<<3)+(char)0x03];
    [self receivedChar:(char)0xF1];
    
    
}


-(void)receivedChar:(char)c {
    //switch on the instruction we sent out..    
    char sentChar = (char)[((NSNumber *)[sendQueue objectAtIndex:0]) unsignedIntValue]>>3;
    NSLog(@"Received char. Sent char: %c, %u", sentChar, (uint8_t)sentChar);
    switch (sentChar) {
        case VERIFY_PING:
            if (c>>3 != VERIFY_ACK) {
                //not expecting this
                //for now we'll just let it timeout
                break;
            }
            [self communicationSuccess];
            [delegate receivedVerifiedAck];
            break;
        case WARM_PING:
            
            break;
        case OFF_PING:
            
            break;
        case S_DATA_PING:
            if ([self numBytesToExpect:S_DATA_PING] == numBytesExpected && c != S_DATA_ACK) {
                //this is the FIRST byte back, and we're not expecting this
                //should reject and try again here
            }
            [charBuffer addObject:[NSNumber numberWithUnsignedInt:(uint8_t)c]];
            if (numBytesExpected == 1) {
                //last byte! now process
                NSLog(@"Char Buffer: %@", charBuffer);
                int sensorData = ((([[charBuffer objectAtIndex:0] unsignedIntValue])&0x03)<<8) + [[charBuffer objectAtIndex:1] unsignedIntValue];
                [self communicationSuccess];
                [delegate receivedSensorData:sensorData];
            }
            break;
        default:
            break;
    }
    
    numBytesExpected--;
    if (numBytesExpected == 0) {
        parsingState = IDLE;
    }
    [self sendChars];
}

-(void)sendChars {
    if ([sendQueue count] > 0 && parsingState == IDLE) {
        numRetriesRemaining = [self numRetriesToDo:(char)([[sendQueue objectAtIndex:0] charValue]>>3)];
        [self sendCode:[[sendQueue objectAtIndex:0] charValue]];
        //start timeout timer!
        parsingState = EXPECTING;
        numBytesExpected = [self numBytesToExpect:INSTRUCTION_BITS((char)[((NSNumber *)[sendQueue objectAtIndex:0]) charValue])];
        [self startTimeout];
    } else {
        
    }
}

-(int)numBytesToExpect:(char)instruction {
    //micro returns different numbers of bytes based on different calls    
    //char instruction = INSTRUCTION_BITS(byte);
    if (instruction == SERIAL_NUMBER_DATA_PING || instruction == BATCH_NUMBER_DATA_PING) return 4;
    if (instruction == S_DATA_PING || instruction == V_DATA_PING || instruction == T_DATA_PING) return 2;
    return 1;
}

-(int)numRetriesToDo:(char)instruction {
    if (instruction == SERIAL_NUMBER_DATA_PING || instruction == BATCH_NUMBER_DATA_PING) return 2;
    if (instruction == S_DATA_PING || instruction == V_DATA_PING || instruction == T_DATA_PING) return 0; //there's a word for this, but it basically means we don't care if you get it
    if (instruction == VERIFY_PING) return 100; //umm?
    
    return 1; //retry pings/acks once
}

-(void)sendTestChar {
    [self sendCode:TEST_CHAR];
}

- (void)sendCode:(char)code {
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    NSLog(@"Sending Char: %c", code);
    [[iDrankAppDelegate getInstance].generator writeByte:code];
}

-(void)requestReading {
    [sendQueue addObject:[NSNumber numberWithUnsignedInt:((uint8_t)S_DATA_PING<<3)]];
    [self sendChars];
}

-(void)requestVoltage {
    
}

-(void)requestTemperature {
    
}

-(void)device_turnHeaterOff {
    
}

-(void)device_turnHeaterOn {
    
}

-(void)device_verify {
    [sendQueue addObject:[NSNumber numberWithUnsignedInt:((uint8_t)VERIFY_PING<<3)]];
    [self sendChars];
}

-(void)startTimeout {
    [self stopTimeout];
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:TIMEOUT_SECONDS target:self selector:@selector(timedOut) userInfo:nil repeats:NO];
}

-(void)communicationSuccess {
    [self stopTimeout];
    [sendQueue removeObjectAtIndex:0];
    [charBuffer removeAllObjects];
    NSLog(@"Communication SUCCESS!");
}

-(void)communicationFailure {
    NSLog(@"Communication ERROR");
    numRetriesRemaining-=1;
    [charBuffer removeAllObjects];
    if (numRetriesRemaining <= 0) {
        if ([sendQueue count] > 0) [sendQueue removeObjectAtIndex:0];
        NSLog(@"Not retrying, moving on");
    } else {
        NSLog(@"Retrying...");
    }
    //we're trying again, so reset some stuff
    parsingState = IDLE;
    
    [self sendChars]; //just keep swimming...
}

-(void)timedOut {
    NSLog(@"Timed out");
    [self stopTimeout];
    [self communicationFailure];
    //if we need to, redo the send
}

-(void)stopTimeout {
    if (timeoutTimer != nil) {
        if ([timeoutTimer isValid]) [timeoutTimer invalidate];
        timeoutTimer = nil;
    }
}

@end
