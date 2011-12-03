//
//  SoftModemTerminalAppDelegate.h
//  SoftModemTerminal
//
//  Created by arms22 on 10/05/02.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#define OBJ_C 1
//#define USING_HIJACK 1
#define USING_FSK 1

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioSession.h>
#import "BACController.h"

#ifdef USING_HIJACK
#import "HiJackMgr.h"
#endif




@class MainViewController;
@class AudioSignalAnalyzer, FSKSerialGenerator, FSKRecognizer;

@interface iDrankAppDelegate : NSObject <UIApplicationDelegate, AVAudioSessionDelegate> { //, HiJackDelegate> {
#ifdef USING_FSK
    AudioSignalAnalyzer* analyzer;
	FSKSerialGenerator* generator;
	FSKRecognizer* recognizer;
#endif
    UIWindow *window;
    MainViewController *mainViewController;
    BACController *bacController;
#ifdef USING_HIJACK
    HiJackMgr *hijack;
    

#endif

    NSMutableArray *eventArray;

}


//Hijack Functions
-(int)receive:(UInt8)data;
-(BOOL)sendData:(UInt8)data;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(void)addBAC:(id)sender;

#ifdef OBJ_C
//CORE DATA
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSMutableArray *eventArray;

#endif



@property (nonatomic, retain) AudioSignalAnalyzer* analyzer;
@property (nonatomic, retain) FSKSerialGenerator* generator;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainViewController;

+ (iDrankAppDelegate*) getInstance;

@end

