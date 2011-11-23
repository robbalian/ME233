//
//  SoftModemTerminalAppDelegate.m
//  SoftModemTerminal
//
//  Created by arms22 on 10/05/02.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "SoftModemTerminalAppDelegate.h"
#import "MainViewController.h"
#import "AudioSignalAnalyzer.h"
#import "FSKSerialGenerator.h"
#import "FSKRecognizer.h"

#pragma mark Audio session callbacks_______________________

// Audio session callback function for responding to audio route changes. If playing 
//		back application audio when the headset is unplugged, this callback pauses 
//		playback and displays an alert that allows the user to resume or stop playback.
//
//		The system takes care of iPod audio pausing during route changes--this callback  
//		is not involved with pausing playback of iPod audio.
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
	
	SoftModemTerminalAppDelegate *appDelegate = (SoftModemTerminalAppDelegate *)inUserData;
    
    // ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
    
    UInt32 currentAudioRoute;                            // 1
    UInt32 propertySize = sizeof (currentAudioRoute);    // 2
    AudioSessionGetProperty (                                // 3
                             kAudioSessionProperty_AudioRoute,
                             &propertySize,
                             &currentAudioRoute
                             );
    
    
    NSString *str = [[NSString alloc] initWithFormat:@"%@", currentAudioRoute];
    if ([str isEqualToString:@"HeadsetInOut"]) {
        //got 4 pin adapter
        //might want to check  || [str isEqualToString:@"HeadphonesAndMicrophone"] as well
        [appDelegate verifySensor];
    } else if ([str isEqualToString:@"ReceiverAndMicrophone"]) {
        //unplugged
        [appDelegate sensorUnplugged];
    }
    NSLog(@"%@", str);
    
    
    
    // Determines the reason for the route change, to ensure that it is not
    //		because of a category change.
    CFDictionaryRef	routeChangeDictionary = inPropertyValue;
    
    CFNumberRef routeChangeReasonRef =
    CFDictionaryGetValue (
                          routeChangeDictionary,
                          CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
    );
    
    SInt32 routeChangeReason;
    
    CFNumberGetValue (
                      routeChangeReasonRef,
                      kCFNumberSInt32Type,
                      &routeChangeReason
                      );
    
    /*
     enum {
     kAudioSessionRouteChangeReason_Unknown                    = 0,
     kAudioSessionRouteChangeReason_NewDeviceAvailable         = 1,
     kAudioSessionRouteChangeReason_OldDeviceUnavailable       = 2,
     kAudioSessionRouteChangeReason_CategoryChange             = 3,
     kAudioSessionRouteChangeReason_Override                   = 4,
     // this enum has no constant with a value of 5
     kAudioSessionRouteChangeReason_WakeFromSleep              = 6,
     kAudioSessionRouteChangeReason_NoSuitableRouteForCategory = 7
     };
     */
    
    
    // "Old device unavailable" indicates that a headset was unplugged, or that the
    //	device was removed from a dock connector that supports audio output. This is
    //	the recommended test for when to pause audio.
    
    
    
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {

    } else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {

    } else if (routeChangeReason == kAudioSessionRouteChangeReason_CategoryChange) {
        //gets called at least once at the beginning of every session, or when we try to mess with the category settings
    } else {
       //we don't know why the route changed... probably have to reset. This is unlikely
    }
    
    NSLog(@"change reason %d", routeChangeReason);
}

@implementation SoftModemTerminalAppDelegate

@synthesize analyzer;
@synthesize generator;
@synthesize window;
@synthesize mainViewController;

+ (SoftModemTerminalAppDelegate*) getInstance
{
	return (SoftModemTerminalAppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];

    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];

	bacController = [BACController getInstance];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
	session.delegate = self;
    
    // Registers the audio route change listener callback function
	AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     self
    );
    
	if(session.inputIsAvailable){
		[session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
	}else{
		[session setCategory:AVAudioSessionCategoryPlayback error:nil];
	}
	[session setActive:YES error:nil];
	[session setPreferredIOBufferDuration:0.023220 error:nil];

    
    
	recognizer = [[FSKRecognizer alloc] init];
	[recognizer addReceiver:bacController];

	generator = [[FSKSerialGenerator alloc] init];
	[generator play];

	analyzer = [[AudioSignalAnalyzer alloc] init];
	[analyzer addRecognizer:recognizer];

	if(session.inputIsAvailable){
		[analyzer record];
	}
    
   /// hijack = [[HiJackMgr alloc] init];
	//[hijack setDelegate:self];

	return YES;
}

-(void)verifySensor {
    [bacController verifySensor];
}

-(void)sensorUnplugged {
    [bacController sensorUnplugged];
}


//Almost positive this never, ever gets called... thanks
- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
{
	NSLog(@"inputIsAvailableChanged %d",isInputAvailable);
	
	AVAudioSession *session = [AVAudioSession sharedInstance];
	
	[analyzer stop];
	[generator stop];
	
	if(isInputAvailable){
		[session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
		[analyzer record];
	}else{
		[session setCategory:AVAudioSessionCategoryPlayback error:nil];
	}
	[generator play];
}


//these do though, when you push the headphones button
- (void)beginInterruption
{
	NSLog(@"beginInterruption");
}

- (void)endInterruption
{
	NSLog(@"endInterruption");
}

- (void)endInterruptionWithFlags:(NSUInteger)flags
{
	NSLog(@"endInterruptionWithFlags: %x",flags);
}

- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
