//
//  BACController.h
//  Laser Tag
//
//  Created by Rob Balian on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CharReceiver.h"
#import "Event.h"

#define SENSOR_WARMUP_SECONDS 5
#define SENSOR_READ_SECONDS 4
#define SENSOR_CALCULATE_SECONDS 3

enum {
    SENSOR_STATE_DISCONNECTED = 0,
    SENSOR_STATE_VERIFYING,
    SENSOR_STATE_OFF, //CONNECTED >=2 
    SENSOR_STATE_WARMING,
    SENSOR_STATE_READY,
    SENSOR_STATE_READING,
    SENSOR_STATE_CALCULATING,
    SENSOR_STATE_DONE
};

@interface BACController : NSObject <CharReceiver>{
    NSMutableArray *readings;
    NSString *currentReading;
    int sensorState;
    id delegate;
    double secondsTillWarm;
    NSTimer *warmTimer;
    NSTimer *readTimer;
    NSTimer *calculateTimer;
    
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    NSMutableArray *eventArray;
}

//CoreData Methods
-(void)fetchRecords;
-(void)addBAC:(id)sender;

-(void)setDelegate:(id)del;
+(BACController*) getInstance;
-(NSString *)storeReading:(char)c;
-(double)getCurrentBAC;
-(void)receivedChar:(char)input;
-(void)sendCode:(char)code;
-(void)setState:(int)state;
-(void)sendTestChar;
-(void)verifySensor;
-(void)sensorUnplugged;
-(BOOL)detectSensorBlow;
-(void)doneReading:(id)sender;
-(void)doneCalculating:(id)sender;

-(int)currentState;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic, retain) NSMutableArray *eventArray;

@end


@protocol BACControllerDelegate


-(void)warmupSecondsLeft:(double)seconds;
-(void)sensorStateChanged:(int)state;
-(void)bacChanged:(double)bac;
-(void)startWithDelegate:(id)del;
@end