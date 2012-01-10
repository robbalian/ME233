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
#import "Theme.h"
#import "FBConnect.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Twitter/Twitter.h>
#import "LocationController.h"
#import "PlaceSelectionViewController.h"

#ifdef USING_HIJACK
#import "HiJackMgr.h"
#endif




@class MainViewController;
@class AudioSignalAnalyzer, FSKSerialGenerator, FSKRecognizer;

@interface iDrankAppDelegate : NSObject <UIApplicationDelegate, AVAudioSessionDelegate, FBSessionDelegate, FBDialogDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> { //, HiJackDelegate> {
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
    
    Theme *theme;
    
    Facebook *facebook;
    
    LocationController *locationController;
}


//Hijack Functions
#ifdef USING_HIJACK
-(int)receive:(UInt8)data;
-(BOOL)sendData:(UInt8)data;
#endif

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)addBAC:(id)sender;
-(void)changeTheme:(int)themeNum;

//LOCATION
-(void)nearbyLocationsUpdated;

//SOCIAL
-(void)sendToFacebook;
-(void)sendToEmail;
-(void)sendToSMS;
-(void)sendToTwitter;

-(void)verifySensor;

@property (nonatomic, retain) Theme *theme;
@property (nonatomic, retain) Facebook *facebook;

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

