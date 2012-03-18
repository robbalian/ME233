//
//  BACController.h
//  Laser Tag
//
//  Created by Rob Balian on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BACEvent.h"
#import "FSKController.h"
//#import "iDrankAppDelegate.h"

#define SENSOR_WARMUP_SECONDS 15
#define SENSOR_READ_SECONDS 1
#define SENSOR_CALCULATE_SECONDS 1

#define USING_SIM 1

typedef enum {
    UNKNOWN = -1,
    DISCONNECTED = 0,
    OFF,
    ON_WARMING,
    ON_READY,
    ON_BLOWING_INTO
} SensorState;

@interface BACController : NSObject <FSKDelegate>{
    NSMutableArray *readings;
    NSString *currentReading;
    int sensorState;
    id delegate;
    double secondsTillWarm;
    double currentBAC;
    NSTimer *warmTimer;
    NSTimer *readTimer;
    NSTimer *calculateTimer;
    NSTimer *verifyRetryTimer;
    NSTimer *noBlowTimer;
    NSTimer *sensorReadingTimer;
    
    int maxSensorDifference;
    int sensorInitialReading;

    FSKController *fskController;
    
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *fetchedResultsController;
    NSMutableArray *eventArray;
    
    BOOL expectingReading;
    
    //calibration
    double readingStartSeconds;
}

+(BACController *)sharedInstance;

-(void)setDelegate:(id)del;
-(void)storeReading:(int)reading;
-(double)getCurrentBAC;
-(void)setState:(int)state;
-(void)startWarmupTimer;
-(void)verifySensor;
-(void)sensorUnplugged;
-(BOOL)detectSensorBlow;
-(void)measureAgain;
-(void)doneReading:(id)sender;
-(void)doneCalculating:(id)sender;
-(void)calculateBAC;
-(void)requestSensorReadingFromDevice;
-(void)stopRequestingSensorData;
-(void)writeFileToDocumentDirectory;

-(int)getLatestSensorReading;

-(int)currentState;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;  
@property (nonatomic, retain) NSMutableArray *eventArray;

@property (nonatomic, retain) FSKController *fskController;

@end


@protocol BACControllerDelegate

-(void)warmupSecondsLeft:(double)seconds;
-(void)sensorStateChanged:(int)state;
-(void)bacChanged:(double)bac;
-(void)startWithDelegate:(id)del;
@end