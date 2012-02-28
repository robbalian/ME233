//
//  FSKController.m
//  iDrank
//
//  Created by Rob Balian on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FSKController.h"

#define NO_INSTRUCTION -1

@implementation FSKController

- (id) initWithDelegate:(BACController *)del {
    self = [super init];
    if (self != nil) {
        delegate = del;
        parsingState = IDLE;
        currentInstruction = NO_INSTRUCTION;
        numCharsRemaining = 0;
        charBuffer = [[NSMutableArray alloc] initWithCapacity:MAX_PAYLOAD];
    }
    return self;
}

-(void)testFSKController {
    NSLog(@"Testing FSK Controller --BEGIN--");
    [self receivedChar:(uint8_t)0xf3]; //packet header
    [self receivedChar:(uint8_t)0xFF]; //PAYLOAD
    [self receivedChar:(uint8_t)0x00]; //PAYLOAD
    [self receivedChar:(uint8_t)0xa4]; //PAYLOAD
    [self receivedChar:(uint8_t)0xa3]; //parity
}

-(void)receivedChar:(char)c {
    NSLog(@"FSK got char: %u", (uint8_t)c);
    // char 11111100
    // First 6 are instruction bits, last 2 are how many subsequent bytes are coming
    //either the start of a packet or we're already expecting a packet parsed
    if (parsingState == IDLE) { //expect a header char
        //do we have a problem?
        
        numCharsRemaining = ((uint8_t)c) & 0x03; //grab rightmost characters
        currentInstruction = (char)c >> 2;
        
        parsingState = PARSING;
        
    } else if (parsingState == PARSING && numCharsRemaining > 0) {
        
        
        [charBuffer addObject:[NSNumber numberWithUnsignedChar:c]];
        numCharsRemaining--;
    } else { //no chars remaining in message, we must be getting the parity bit
        if ([self verifyPacket:c]) {
            //success! route this to the proper BAC function;
        } else {
            //failure, notify BAC controller
        }
        
        //success or failure
        [self resetBuffer];
    }
}

-(BOOL)verifyPacket:(char)hashByte {
    //simplest hash function
    NSLog(@"Calculating hash. charBuffer %@ hashByte: %u", charBuffer, (uint8_t)hashByte);
    
    int total = 0;
    for (NSNumber *num in charBuffer) {
        NSLog(@"Adding num: %d", [num intValue]);
        total += [num intValue];
    }
    NSLog(@"Total: %d", total);
    if ((uint8_t)hashByte == (total % 256)) {
        NSLog(@"Success!");
        return YES;
    } else {
        NSLog(@"Failed");
        return NO;
    }
}

-(void)sendPacketWithInstruction:(char)instructionChar andPayload:(id)payload {
    //not done yet
    
    //if (payload == 
    
    //do the opposite
    switch (instructionChar) {
        //case REQUEST_SENSOR_READING:
            
            break;
            
        default:
            break;
    }
}

-(void)resetBuffer { //only gets called after successful TX or failure
    [charBuffer removeAllObjects];
    parsingState = IDLE;
    currentInstruction = NO_INSTRUCTION;
}


@end
