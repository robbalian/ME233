//
//  SoftModemTerminalAppDelegate.m
//  SoftModemTerminal
//
//  Created by arms22 on 10/05/02.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "iDrankAppDelegate.h"
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
	
	iDrankAppDelegate *appDelegate = (iDrankAppDelegate *)inUserData;
    
    // ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
    
    UInt32 currentAudioRoute;                            // 1
    UInt32 propertySize = sizeof (currentAudioRoute);    // 2
    AudioSessionGetProperty (                                // 3
                             kAudioSessionProperty_AudioRoute,
                             &propertySize,
                             &currentAudioRoute
                             );
    
#ifdef USING_FSK
    NSString *str = [[NSString alloc] initWithFormat:@"%@", currentAudioRoute];
    if ([str isEqualToString:@"HeadsetInOut"] || [str isEqualToString:@"HeadphonesAndMicrophone"]) {
        //got 4 pin adapter
        //might want to check  || [str isEqualToString:@"HeadphonesAndMicrophone"] as well
        [appDelegate verifySensor];
    } else if ([str isEqualToString:@"ReceiverAndMicrophone"]) {
        //unplugged
        [appDelegate sensorUnplugged];
    }
    NSLog(@"%@", str);
#endif    
    
    
    // Determines the reason for the route change, to ensure that it is not
    //		because of a category change.
    CFDictionaryRef	routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
    
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
    
    //int routeChangeReason = 0;
    
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {

    } else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {

    } else if (routeChangeReason == kAudioSessionRouteChangeReason_CategoryChange) {
        //gets called at least once at the beginning of every session, or when we try to mess with the category settings
    } else {
       //we don't know why the route changed... probably have to reset. This is unlikely
    }
    
    NSLog(@"change reason %d", routeChangeReason);
}

@implementation iDrankAppDelegate

@synthesize analyzer;
@synthesize generator;
@synthesize window;
@synthesize mainViewController;
#ifdef OBJ_C
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize eventArray;
#endif
+ (iDrankAppDelegate*) getInstance
{
	return (iDrankAppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    
    MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];
    
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];


	bacController = [BACController getInstance];
#ifdef OBJ_C
    bacController.managedObjectContext = [self managedObjectContext];
#endif
    
#ifdef USING_FSK
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
#endif    
    
#ifdef USING_HIJACK
    hijack = [[HiJackMgr alloc] init];
	[hijack setDelegate:self];
#endif
    
    [self fetchRecords];
    [self addBAC:nil];
    
	return YES;
}

#ifdef USING_HIJACK
-(int)receive:(UInt8)data
{
    NSLog(@"Hijack received data: %d", data);
    return data;
}

-(BOOL)sendData:(UInt8)data {
    if ([hijack send:data] == 1) {
        NSLog(@"Hijack sent data");
        return YES;
    } else {
        NSLog(@"Hijack failed to send data");
        return NO;
    }
}
#endif

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
	
#ifdef USING_FSK
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
#endif
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

//CORE DATA
#ifdef OBJ_C
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    __managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iDrank.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}
#endif


-(void)addBAC:(id)sender {   
    
    BACEvent *event = (BACEvent *)[NSEntityDescription insertNewObjectForEntityForName:@"BACEvent" inManagedObjectContext:__managedObjectContext];  
    [event setTime:[NSDate date]];
    [event setReading:[NSNumber numberWithDouble:.03]];
    //[event setUser_id:<#(NSNumber *)#>];
    [event setName:@"Rob"];
    
    NSError *error;  
    
    if(![__managedObjectContext save:&error]){  
        
        //This is a serious error saying the record  
        //could not be saved. Advise the user to  
        //try again or restart the application.   
        
    }  
    
    [eventArray insertObject:event atIndex:0];
    
    
}  

- (void)fetchRecords {   
    
    // Define our table/entity to use  
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BACEvent" inManagedObjectContext:__managedObjectContext];   
    
    // Setup the fetch request  
    NSFetchRequest *request = [[NSFetchRequest alloc] init];  
    [request setEntity:entity];   
    
    // Define how we will sort the records  
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];  
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];  
    [request setSortDescriptors:sortDescriptors];  
    [sortDescriptor release];   
    
    // Fetch the records and handle an error  
    NSError *error;  
    NSMutableArray *mutableFetchResults = [[__managedObjectContext executeFetchRequest:request error:&error] mutableCopy];   
    
    if (!mutableFetchResults) { 
        // Handle the error.  
        // This is a serious error and should advise the user to restart the application  
    }   
    
    // Save our fetched data to an array  
    
    [self setEventArray:mutableFetchResults];
    [mutableFetchResults release];  
    [request release];  
}   



#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
