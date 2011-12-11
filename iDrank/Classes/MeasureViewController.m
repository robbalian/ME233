//
//  MeasureViewController.m
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MeasureViewController.h"

@implementation MeasureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSensorStateChangeNotification:) name:@"stateChanged" object:[BACController getInstance]];

        
    }
    return self;
}

-(void)receivedSensorStateChangeNotification:(id)sender {
    int state = [[BACController getInstance] currentState];
    
    if (state == SENSOR_STATE_DISCONNECTED) {
        [readoutLabel setText:@""];
        [infoTitleLabel setText:@"While we wait..."];
        [infoBodyLabel setText:@"Did you know that vodka is a proven cure for ugliness?"];
        [measureAgainButton setHidden:YES];
    } else if (state == SENSOR_STATE_WARMING) {
        [measureAgainButton setHidden:YES];
        [readoutLabel setText:@"Warming"];
    } else if (state == SENSOR_STATE_READY) {
        [readoutLabel setText:@"Ready"];
    } else if (state == SENSOR_STATE_READING) {
        [readoutLabel setText:@"Reading..."];
        //play sound or vibrate on loop
    } else if (state == SENSOR_STATE_CALCULATING) {
        [readoutLabel setText:@"Calculating..."];
    } else if (state == SENSOR_STATE_DONE) {
        double bac = [[BACController getInstance] getCurrentBAC];
        [readoutLabel setText:[NSString stringWithFormat:@"%.2f", bac]];
        [infoTitleLabel setText:[NSString stringWithFormat:@"%.2f BAC", bac]];
        [infoBodyLabel setText:@"This text"];
        [measureAgainButton setHidden:NO];
    }
    
}

-(IBAction)changeTheme:(id)sender {
    //theme 1
    //to theme 2
    //add theme 2 to top, hidden
    //animation: view 2 not hidden, view 1 hidden
    //remove view 1
    NSArray *nibObjs;
    //if (arc4random() % 2 == 0) {
        nibObjs = [[NSBundle mainBundle] loadNibNamed:@"CollegeThemeViewController" owner:self options:nil];
    //} else {
    //    nibObjs = [[NSBundle mainBundle] loadNibNamed:@"MeasureViewController" owner:self options:nil];
    //}
    UIView *aView = [nibObjs objectAtIndex:0];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:NO];
    //REMOVES TOP VIEW
    for (UIView *sub in self.view.subviews) {
        [sub removeFromSuperview];
    }
    [self.view addSubview:aView];
    
    
    //[aView setHidden:YES];
    //[self.view addSubview:aView];
    
    //[aView setHidden:NO];
    //[circle setFrame:CGRectMake(arc4random()%320, arc4random()%480, 300, 300)];
    [UIView commitAnimations];
}

-(IBAction)testChar:(id)sender {
    [[BACController getInstance] sendTestChar];
}

-(IBAction)measureAgain:(id)sender {
    [[BACController getInstance] measureAgain];
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
