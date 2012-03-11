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

#define TIMEOUT_SECONDS (3.0)

#define VERIFY_PING (0x01)
#define VERIFY_ACK  (0x02)
#define WARM_PING   (0x03)
#define WARM_ACK    (0x04)
#define OFF_PING    (0x05)
#define OFF_ACK     (0x06)

#define S_DATA_PING (0x07)// sensor value request - returns 8 bit value 
#define S_DATA_ACK  (0x08)

#define T_DATA_PING (0x09) // temperature value request - return 8 bit value (10* temp [c])
#define T_DATA_ACK  (0x0a)

#define V_DATA_PING (0x0b) // voltage value request - returns 7 bit value (10* voltage [V])
#define V_DATA_ACK  (0x0c)
#define SERIAL_NUMBER_DATA_PING (0x0d)
#define SERIAL_NUMBER_DATA_ACK  (0x0e)


#define TEST_CHAR (0x0f)
#define ERROR_SIGNAL (0x10) 

#define INSTRUCTION_BITS(c) c>>3
#define PACK_INSTRUCTION_BIT(c) c<<3


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
    
    //veryify test
    [self device_verify];
    [self receivedChar:VERIFY_ACK<<3]; //fake ack
    
    //sensor data test
    [self requestReading];
    [self receivedChar:(char)(S_DATA_ACK<<3)+(char)0x03];
    [self receivedChar:(char)0xF1];
}


-(void)receivedChar:(char)c {
    NSLog(@"received char");
    //switch on the instruction we sent out..    
    if ([sendQueue count] == 0) {
        NSLog(@"No items in the send queue! something is wrong");
        [self communicationFailure];
        return;
    }
    char sentChar = (char)[((NSNumber *)[sendQueue objectAtIndex:0]) unsignedIntValue]>>3;
    NSLog(@"Received char: (%c, %u) -- Sent char: (%c, %u)", c, (uint8_t)c, sentChar, (uint8_t)sentChar);
    switch (sentChar) {
        case VERIFY_PING:
            if (c>>3 != VERIFY_ACK) {
                //not expecting this
                [self communicationFailure];
                break;
            }
            
            //OK HERE"S THE THING: must send delegate call before commSuccess. It empties the charBuffer so we can't get meaninful info out... just do it
            [delegate receivedVerifiedAck];
            [self communicationSuccess];
            break;
        case WARM_PING:
            if (c>>3 != WARM_ACK) {
                [self communicationFailure];
                break;
            }
            
            [delegate receivedHeaterOnAck];
            [self communicationSuccess];
            break;
        case OFF_PING:
            if (c>>3 != OFF_ACK) {
                [self communicationFailure];
                break;
            }
            [delegate receivedHeaterOffAck];
            [self communicationSuccess];
            break;
        case S_DATA_PING:
            if ([self numBytesToExpect:S_DATA_PING] == numBytesExpected && INSTRUCTION_BITS(c) != S_DATA_ACK) {
                //this is the FIRST byte back, and we're not expecting this
                [self communicationFailure];
            } else {
                [charBuffer addObject:[NSNumber numberWithUnsignedInt:(uint8_t)c]];
                if (numBytesExpected == 1) {
                    //last byte! now process
                    NSLog(@"Char Buffer: %@", charBuffer);
                    [delegate receivedSensorData:[self getDataFromCharBuffer]];
                    [self communicationSuccess];
                }
            }
            break;
        case V_DATA_PING:
            if ([self numBytesToExpect:V_DATA_PING] == numBytesExpected && c != V_DATA_ACK) {
                //this is the FIRST byte back, and we're not expecting this
                [self communicationFailure];
                break;
            }
            [charBuffer addObject:[NSNumber numberWithUnsignedInt:(uint8_t)c]];
            if (numBytesExpected == 1) {
                //last byte! now process
                NSLog(@"Char Buffer: %@", charBuffer);
                
                [delegate receivedVoltageData:[self getDataFromCharBuffer]];
                [self communicationSuccess];
            }
            break;
        case TEST_CHAR:
            if (c>>3 != TEST_CHAR) {
                [self communicationFailure];
                break;
            }
            [self communicationSuccess];
            NSLog(@"Got Test Char!");
            break;
        default:
            [self communicationFailure];
            break;
    }
    
    numBytesExpected--;
    if (numBytesExpected == 0) {
        parsingState = IDLE;
    }
    [self sendChars];
}

-(int)getDataFromCharBuffer {
    //((([[charBuffer objectAtIndex:0] unsignedIntValue])&0x03)<<8) + [[charBuffer objectAtIndex:1] unsignedIntValue];
    NSLog(@"Get data from char buffer...");
    int val = 0;
    for (int i=[charBuffer count]-1; i>0; i--) {
        val += [[charBuffer objectAtIndex:i] unsignedIntValue]<<(8*([charBuffer count]-1-i));
    }
    val += ([[charBuffer objectAtIndex:0] unsignedIntValue]&0x03)<<8*([charBuffer count]-1);
    return val;
}

-(void)sendChars {
    if ([sendQueue count] > 0 && parsingState == IDLE) {
        NSLog(@"%@", sendQueue);
        NSLog(@"Send chars...");
        if (numRetriesRemaining == -1) numRetriesRemaining = [self numRetriesToDo:(char)([[sendQueue objectAtIndex:0] charValue]>>3)];
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
    if (instruction == SERIAL_NUMBER_DATA_PING) return 4;
    if (instruction == S_DATA_PING || instruction == V_DATA_PING || instruction == T_DATA_PING) return 2;
    return 1;
}

-(int)numRetriesToDo:(char)instruction {
    if (instruction == SERIAL_NUMBER_DATA_PING) return 2;
    if (instruction == S_DATA_PING || instruction == V_DATA_PING || instruction == T_DATA_PING) return 0; //there's a word for this, but it basically means we don't care if you get it
    if (instruction == VERIFY_PING) return 1; //umm?
    
    return 1; //retry pings/acks once
}

-(void)sendTestChar {
    [sendQueue addObject:[NSNumber numberWithUnsignedInt:((uint8_t)TEST_CHAR<<3)]];
    [self sendChars];
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
    [sendQueue addObject:[NSNumber numberWithUnsignedInt:((uint8_t)V_DATA_PING<<3)]];
    [self sendChars];
}

-(void)requestTemperature {
    [sendQueue addObject:[NSNumber numberWithUnsignedInt:((uint8_t)T_DATA_PING<<3)]];
    [self sendChars];
}

-(void)device_turnHeaterOff {
    [sendQueue addObject:[NSNumber numberWithUnsignedInt:((uint8_t)OFF_PING<<3)]];
    [self sendChars];
}

-(void)device_turnHeaterOn {
    [sendQueue addObject:[NSNumber numberWithUnsignedInt:((uint8_t)WARM_PING<<3)]];
    [self sendChars];
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
        numRetriesRemaining = -1; //set this so that we get a new value for the new char we send
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
