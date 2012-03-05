//
//  FSKController.h
//  iDrank
//
//  Created by Rob Balian on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CharReceiver.h"

typedef enum {
    IDLE = 0,
    EXPECTING
} ParsingState;

#define MAX_PAYLOAD 4 //bytes

@class BACController;

@protocol FSKDelegate <NSObject>
@required
-(void)receivedSensorData:(int)data;
-(void)receivedVoltageData:(double)data;
-(void)receivedTemperatureData:(double)data;
-(void)receivedVerifiedAck;
-(void)receivedHeaterOnAck;
-(void)receivedHeaterOffAck;
-(void)receivedOffAck;

@end

@interface FSKController : NSObject <CharReceiver> {
    BACController *delegate;
    int parsingState;
    int numBytesExpected;
    
    int numRetriesRemaining;
    
    NSMutableArray *charBuffer;
    NSMutableArray *sendQueue;
    
    NSTimer *timeoutTimer;
}

-(id)initWithDelegate:(BACController *)del;
-(void)receivedChar:(char)c;
-(void)sendChars;
-(void)sendCode:(char)c;
-(int)numBytesToExpect:(char)instruction;
-(void)startTimeout;
-(void)stopTimeout;
-(void)timedOut;
-(void)communicationSuccess;
-(void)communicationFailure;
-(int)numRetriesToDo:(char)instruction;
-(int)getDataFromCharBuffer;

-(void)testFSKController;

-(void)requestReading;
-(void)requestVoltage;
-(void)requestTemperature;

-(void)device_turnHeaterOff;
-(void)device_turnHeaterOn;
-(void)device_verify;

@end
