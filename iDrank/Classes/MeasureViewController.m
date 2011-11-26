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
        [readoutLabel setText:[NSString stringWithFormat:@"%.02f", [[BACController getInstance] getCurrentBAC]]];
        [measureAgainButton setHidden:NO];
    }
    
}

-(IBAction)measureAgain:(id)sender {
    [[BACController getInstance] measureAgain];
}


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
