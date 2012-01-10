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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLocationChangeNotification:) name:@"locationChanged" object:[LocationController sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUserChangeNotification:) name:@"userChanged" object:[UserController sharedInstance]];
        placeLabel.adjustsFontSizeToFitWidth = YES;
        userNameLabel.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

-(void)receivedSensorStateChangeNotification:(id)sender {
    int state = [[BACController sharedInstance] currentState];
    Theme *theme = [[iDrankAppDelegate getInstance] theme];
    if (state == SENSOR_STATE_DISCONNECTED) {
        [readoutLabel setText:@""];
        [infoTitleLabel setText:@"While we wait..."];
        [infoBodyLabel setText:@"Did you know that vodka is a proven cure for ugliness?"];
        [measureAgainButton setHidden:YES];
    } else if (state == SENSOR_STATE_WARMING) {
        [measureAgainButton setHidden:YES];
        [readoutLabel setText:@"Warming"];
        [UIView transitionWithView:shareCluster duration:1.0 options:UIViewAnimationCurveEaseIn animations:^{ [shareCluster setAlpha:0.0]; } completion:nil];
    } else if (state == SENSOR_STATE_READY) {
        [readoutLabel setText:@"Ready"];
    } else if (state == SENSOR_STATE_READING) {
        [readoutLabel setText:@"Reading..."];
        //play sound or vibrate on loop
    } else if (state == SENSOR_STATE_CALCULATING) {
        [readoutLabel setText:@"Calculating..."];
    } else if (state == SENSOR_STATE_DONE) {
        double bac = [[BACController sharedInstance] getCurrentBAC];
        [readoutLabel setText:[NSString stringWithFormat:@"%.2f", bac]];
        [infoTitleLabel setText:[NSString stringWithFormat:@"%.2f BAC", bac]];
        [infoBodyLabel setText:[theme getBodyLabel]];
        [measureAgainButton setHidden:NO];
        [UIView transitionWithView:shareCluster duration:1.0 options:UIViewAnimationCurveEaseIn animations:^{ [shareCluster setAlpha:1.0]; } completion:nil];
    }
    
}

-(void)receivedLocationChangeNotification:(id)sender {
    [placeLabel setText:[[LocationController sharedInstance] getPlaceName]];
}

-(void)receivedUserChangeNotification:(id)sender {
    [userNameLabel setText:[[UserController sharedInstance] getUserName]];
}

-(void)setViewForThemeAnimated:(BOOL)animated {
    //theme 1
    //to theme 2
    //add theme 2 to top, hidden
    //animation: view 2 not hidden, view 1 hidden
    //remove view 1

    //} else {
    //    nibObjs = [[NSBundle mainBundle] loadNibNamed:@"MeasureViewController" owner:self options:nil];
    //}
    
    //if (!theme) theme = [[Theme alloc] initWithTheme:0 andDelegate:self];

    //[theme setTheme:([theme getThemeNum]+1) % NUM_THEMES];
    
    UIView *aView = [[iDrankAppDelegate getInstance].theme getView:self];
    
if (animated) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
    //REMOVES TOP VIEW
    //for (UIView *sub in self.view.subviews) {
        //[sub removeFromSuperview];
    //}
    
    
    
    
    //[aView setHidden:YES];
    [self.view addSubview:aView];
    
    //[aView setHidden:NO];
    //[circle setFrame:CGRectMake(arc4random()%320, arc4random()%480, 300, 300)];
    [UIView commitAnimations];
} else {
    [self.view addSubview:aView];
}
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


-(IBAction)placeButtonTapped:(id)sender {
    PlaceSelectionViewController *psvc = [[PlaceSelectionViewController alloc] init];
    [((iDrankAppDelegate *)[iDrankAppDelegate getInstance]).mainViewController presentModalViewController:psvc animated:YES];
}

-(IBAction)profileButtonTapped:(id)sender {
    ProfileSelectionViewController *psvc = [[ProfileSelectionViewController alloc] init];
    [((iDrankAppDelegate *)[iDrankAppDelegate getInstance]).mainViewController presentModalViewController:psvc animated:YES];
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
    [self setViewForThemeAnimated:NO];

    // Do any additional setup after loading the view from its nib.
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
