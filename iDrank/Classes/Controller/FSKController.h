//
//  FSKController.h
//  iDrank
//
//  Created by Rob Balian on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    IDLE = 0,
    PARSING
} ParsingState;

#define MAX_PAYLOAD 4 //bytes

@class BACController;

@interface FSKController : NSObject {
    BACController *delegate;
    int parsingState;
    int numCharsRemaining;
    char currentInstruction;
    NSMutableArray *charBuffer;
}

-(id)initWithDelegate:(BACController *)del;
-(void)resetBuffer;
-(void)receivedChar:(char)c;
-(BOOL)verifyPacket:(char)hashByte;

@end
