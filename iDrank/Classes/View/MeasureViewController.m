//
//  MeasureViewController.m
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MeasureViewController.h"
#import "MainViewController.h"
#import "iDrankAppDelegate.h"
#import "ProfileSelectionViewController.h"
#import "UserController.h"

@implementation MeasureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //theme = [[Theme alloc] initWithTheme:0 andDelegate:self];
        //[self.view addSubview:[theme getView]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSensorStateChangeNotification:) name:@"stateChanged" object:[BACController sharedInstance]];
        [self receivedSensorStateChangeNotification:nil];
    }
    return self;
}

-(void)receivedSensorStateChangeNotification:(id)sender {
    int state = [[BACController sharedInstance] currentState];
    [self updateUIForStateChange:(int)state];
}

-(void)updateUIForStateChange:(int)state {
    NSLog(@"MeasureView received state change notification. State: %d", state);
    
    if (state == DISCONNECTED) {
        [readoutLabel setText:@""];
        [infoTitleLabel setText:@"While we wait..."];
        [infoBodyLabel setText:@"Make sure you haven't eaten or drank anything in the last 15 minutes   "];
        [measureAgainButton setHidden:YES];
    } else if (state == ON_WARMING) {
        [measureAgainButton setHidden:YES];
        [readoutLabel setText:@"Warming"];
        [UIView transitionWithView:shareCluster duration:1.0 options:UIViewAnimationCurveEaseIn animations:^{ [shareCluster setAlpha:0.0]; } completion:nil];
        [infoTitleLabel setText:@"Useful tip:"];
        [infoBodyLabel setText:@"Make sure you haven't eaten or drank anything in the last 15 minutes"];
    } else if (state == ON_READY) {
        [readoutLabel setText:@"Ready"];
        [infoTitleLabel setText:@"Ready to Blow"];
        [infoBodyLabel setText:@"Blow steadily into the sensor. We'll tell you when to stop!"];
    } else if (state == ON_BLOWING_INTO) {
        [readoutLabel setText:@"Reading! Keep Blowing..."];
    } else if (state == OFF) {
        double bac = [[BACController sharedInstance] getCurrentBAC];
        [readoutLabel setText:[NSString stringWithFormat:@"%.2f", bac]];
        [infoTitleLabel setText:[NSString stringWithFormat:@"%.2f BAC", bac]];
        [infoBodyLabel setText:[[Theme sharedInstance] getBodyLabel]];
        [measureAgainButton setHidden:NO];
        [self startThemeAnimations];
        [UIView transitionWithView:shareCluster duration:1.0 options:UIViewAnimationCurveEaseIn animations:^{ [shareCluster setAlpha:1.0]; 
        } completion:nil];
    }
}

-(void)startThemeAnimations {
    
}

-(IBAction)testCharIn:(id)sender {
    [[BACController sharedInstance] receivedChar:'ý'];
}

-(IBAction)testChar:(id)sender {
    [[BACController sharedInstance] sendTestChar];
}

-(IBAction)measureAgain:(id)sender {
    [[BACController sharedInstance] measureAgain];
}

-(IBAction)facebookButtonTapped:(id)sender {
    [[iDrankAppDelegate getInstance] sendToFacebook];    
}

-(IBAction)SMSButtonTapped:(id)sender {
    [[iDrankAppDelegate getInstance] sendToSMS];
}

-(IBAction)twitterButtonTapped:(id)sender {
    [[iDrankAppDelegate getInstance] sendToTwitter];
}


/*
-(IBAction)ripple:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:110 forView:self.view cache:NO];
    
    [circle setFrame:CGRectMake(arc4random()%320, arc4random()%480, 300, 300)];
    [UIView commitAnimations];
}
*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [readoutLabel setFont: [UIFont fontWithName: @"Crystal" size: readoutLabel.font.pointSize]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
