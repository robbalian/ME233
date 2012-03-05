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
void checkCurrentAudioRoute(id appDel) {
   	iDrankAppDelegate *appDelegate = (iDrankAppDelegate *)appDel;
    
    
    UInt32 currentAudioRoute;                            // 1
    UInt32 propertySize = sizeof (currentAudioRoute);    // 2
    AudioSessionGetProperty (                                // 3
                             kAudioSessionProperty_AudioRoute,
                             &propertySize,
                             &currentAudioRoute
                             );
    
    //#ifdef USING_FSK
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
    //#endif    
}

void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
	
    UInt32 size = sizeof(CFDictionaryRef);
    CFDictionaryRef newRef;
    OSStatus error =  AudioSessionGetProperty(
                                              kAudioSessionProperty_AudioRouteDescription,
                                              &size,
                                              &newRef
                                              );
    
    NSLog(@"%@", newRef);
    NSLog(@"%@", error);
    
    //CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
    //SInt32 reasonVal;
    //CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
    checkCurrentAudioRoute(inUserData);

    //hmmm not sure this should be here
    // ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
    
    
    // Determine the specific type of audio route change that occurred.
    CFDictionaryRef routeChangeDictionary = inPropertyValue;
    
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
@synthesize facebook;

+ (iDrankAppDelegate*) getInstance
{
	return (iDrankAppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    
    facebook = [[Facebook alloc] initWithAppId:@"106106509509643" andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    /*if (![facebook isSessionValid]) {
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_likes", 
                                @"read_stream",
                                @"publish_actions",
                                @"publish_stream",
                                nil];
        [facebook authorize:permissions];
        [permissions release];
    }*/
    
    locationController = [LocationController sharedInstance];
    locationController.delegate = self;
    [locationController.locationManager startUpdatingLocation];

    
    MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];
    
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	[window addSubview:[mainViewController view]];
    [window makeKeyAndVisible];


	bacController = [BACController sharedInstance];
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
        /*OSStatus propertySetError = 0;
        UInt32 allowMixing = true;
        
        propertySetError = AudioSessionSetProperty (
                                                    kAudioSessionProperty_OverrideCategoryMixWithOthers,  // 1
                                                    sizeof (allowMixing),                                 // 2
                                                    &allowMixing                                          // 3
                                                    );
        
        NSLog(@"%@", propertySetError);
    */
    }else{
		//[session setCategory:AVAudioSessionCategoryPlayback error:nil];
	}
	//[session setActive:YES error:nil];
	//[session setPreferredIOBufferDuration:0.023220 error:nil];

    
    checkCurrentAudioRoute([iDrankAppDelegate getInstance]);
    
    
	recognizer = [[FSKRecognizer alloc] init];
	[recognizer addReceiver:bacController.fskController];

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

-(void)changeTheme:(int)themeNum {
    [[Theme sharedInstance] setTheme:themeNum];
    [mainViewController themeChanged];
    //pass it down until there's a view that can do something
    
    //do animation thing
    //switch tab to measureVC
    //[measureviewcontroller change/resetTheme
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}
#endif


-(void)addBAC:(id)sender {   
    BACEvent *event = (BACEvent *)[NSEntityDescription insertNewObjectForEntityForName:@"BACEvent" inManagedObjectContext:__managedObjectContext];  
    [event setTime:[NSDate date]];
    [event setReading:[NSNumber numberWithDouble:[[BACController sharedInstance] getCurrentBAC]]];
    [event setName:[[UserController sharedInstance] getUserName]];
    CLLocation *myLoc = [locationController getLastLocation];
    [event setLocation_lat:[NSNumber numberWithDouble:myLoc.coordinate.latitude]];
    [event setLocation_long:[NSNumber numberWithDouble:myLoc.coordinate.longitude]];
    [event setPlace_name:[[LocationController sharedInstance] getPlaceName]];
    
    
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

#pragma mark FACEBOOK DELEGATE METHODS

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    //[facebook dialog:@"feed" andDelegate:self];
}

#pragma mark LOCATION CALLBACKS

-(void)nearbyPlacesUpdated {
    //display
    NSLog(@"DICTIONARY : %@",[locationController getNearbyPlaces]);
    //PlaceSelectionViewController *psvc = [[PlaceSelectionViewController alloc] init];
    //[mainViewController presentModalViewController:psvc animated:YES];
}

#pragma mark SHARING

-(void)sendToFacebook {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"https://developers.facebook.com/docs/reference/dialogs/", @"link",
                                   @"http://fbrell.com/f8.jpg", @"picture",
                                   @"Stealth Project", @"name",
                                   @"Caption", @"caption",
                                   @"Using Dialogs to interact with users.", @"description",
                                   @"This app is awesome",  @"message",
                                   nil];
    
    [facebook dialog:@"feed" andParams:params andDelegate:self];
}

-(void)sendToSMS {
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    
    //picker.recipients = [NSArray arrayWithObject:@"123456789"];   // your recipient number or self for testing
    NSString *emailBody = [NSString stringWithFormat:@"Just blew a %.2f with iDrank. Come join me at %@!", [[BACController sharedInstance] getCurrentBAC], [[LocationController sharedInstance] getPlaceName]];
    
    
    picker.body = emailBody;
    
    [mainViewController presentViewController:picker animated:YES completion:nil];
    //[mainViewController presentModalViewController:picker animated:YES];
    picker = nil;
    NSLog(@"SMS fired");
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [mainViewController dismissModalViewControllerAnimated:YES];
    /*switch (result) {
        case MessageComposeResultSent:
            [FlurryAPI logEvent:@"share_sms_sent" withParameters:nil];
            break;
        case MessageComposeResultCancelled:
            [FlurryAPI logEvent:@"share_sms_cancelled" withParameters:nil];
            break;
        case MessageComposeResultFailed:
            [FlurryAPI logEvent:@"share_sms_failed" withParameters:nil];
            break;
        default:
            break;
    }*/
}

-(void)sendToEmail {
    NSLog(@"Send Email Start");
    if([MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setModalPresentationStyle:UIModalPresentationFullScreen];
        [picker setModalInPopover:YES];
        //[picker setMailComposeDelegate:self];
        //NSLog(((UINavigationItem *)[picker.navigationBar]).title);
        //[picker setView:self.view];
        // Set the subject of email
        [picker setSubject:@"Just measured my BAC using iDrank"];
        
        
        // Add email addresses
        // Notice three sections: "to" "cc" and "bcc"	
        [picker setToRecipients:[NSArray arrayWithObjects:nil]];
        
        
        // Fill out the email body text
        
        // Create NSData object as PNG image data from camera image
        //NSLog(@"converting to nsdata");
        //NSData *data = UIImagePNGRepresentation(imageView.image);
        //NSLog(@"done");
        
        NSString *emailBody = [NSString stringWithFormat:@"<html><body>Just blew %@ BAC using iDrank<br />Get your own from iPhone Breathalyzer at <a href=\"http://www.kickstarter.com\">D.tect</a></body></html>", [[BACController sharedInstance] getCurrentBAC]];
        
        
        // This is not an HTML formatted email
        [picker setMessageBody:emailBody isHTML:YES];
        
        
        // Attach image data to the email
        // 'CameraImage.png' is the file name that will be attached to the email
        //[picker addAttachmentData:data mimeType:@"image/jpeg" fileName:@"CameraImage"];
        
        // Show email view	
        
        [mainViewController presentModalViewController:picker animated:YES];
        //[[[[UIApplication sharedApplication] delegate] ] presentModalViewController:picker animated:YES];
        //[picker release];
        picker = nil;
        
    }

}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
    [mainViewController dismissModalViewControllerAnimated:YES]; 
    NSLog(@"Send End");
    //[controller dismissModalViewControllerAnimated:YES];
    /*switch (result) {
        case MFMailComposeResultCancelled:
            [FlurryAPI logEvent:@"share_mail_cancelled" withParameters:nil];
            break;
        case MFMailComposeResultSaved:
            [FlurryAPI logEvent:@"share_mail_saved" withParameters:nil];
            break;
        case MFMailComposeResultFailed:
            [FlurryAPI logEvent:@"share_mail_failed" withParameters:nil];
            break;
        case MFMailComposeResultSent:
            [FlurryAPI logEvent:@"share_mail_sent" withParameters:nil];
            break;
        default:
            break;
    }*/
}

-(void)sendToTwitter {
    // Create the view controller
    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    
    // Optional: set an image, url and initial text
    //[twitter addImage:[UIImage imageNamed:@"iOSDevTips.png"]];
    [twitter addURL:[NSURL URLWithString:[NSString stringWithString:@"http://iOSDeveloperTips.com/"]]];
    [twitter setInitialText:@"Tweet from iOS 5 app using the Twitter framework."];
    
    // Show the controller
    [mainViewController presentModalViewController:twitter animated:YES];
    
    // Called when the tweet dialog has been closed
    twitter.completionHandler = ^(TWTweetComposeViewControllerResult result) 
    {
        NSString *title = @"Tweet Status";
        NSString *msg; 
        
        if (result == TWTweetComposeViewControllerResultCancelled)
            msg = @"Tweet compostion was canceled.";
        else if (result == TWTweetComposeViewControllerResultDone)
            msg = @"Tweet composition completed.";
        
        // Show alert to see how things went...
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        
        // Dismiss the controller
        [mainViewController dismissModalViewControllerAnimated:YES];
    };
}


-(void)playAif:(NSString *)filename {
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:filename ofType:@"aif"];
    if (path) { // test for path, to guard against crashes
        AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path],&soundID);
        AudioServicesPlaySystemSound (soundID);
    } else {
        NSLog(@"Can't find audio file!");
    }
}


- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end
