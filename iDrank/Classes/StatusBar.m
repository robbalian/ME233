//
//  StatusBar.m
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StatusBar.h"

@implementation StatusBar

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSensorStateChangeNotification:) name:@"stateChanged" object:[BACController getInstance]];
        
        sensorController = [BACController getInstance];
        [sensorController setDelegate:self];
    }
    return self;
}

//## BAC CONTROLLER DELEGATE METHODS

-(void)bacChanged:(double)bac {
    //[self updateUIForBAC];
}

-(void)sensorStateChanged:(int)state {
    
}

//-(void)sensorStateChanged:(int)state {
-(void)receivedSensorStateChangeNotification:(id)sender {
    int state = [[BACController getInstance] currentState];
//update user instructions
    if (state >= SENSOR_STATE_OFF) {
        [statusIV setImage:[UIImage imageNamed:@"Sensor_enabled.png"]];
        if (state == SENSOR_STATE_OFF  ) {
            [coverView setFrame:CGRectMake(49, 7, 251, 38)];
            [statusLabel setText:@"Sensor Off"];
        }
        if (state == SENSOR_STATE_WARMING) {
            [statusLabel setText:@"Warming Up..."];
        
            [UIView transitionWithView:self.view duration:SENSOR_WARMUP_SECONDS options:UIViewAnimationCurveLinear+UIViewAnimationOptionBeginFromCurrentState animations:^{ 
            [coverView setFrame:CGRectMake(49+251, 7, 0, 38)];
            
             } completion:nil];

        } else if (state == SENSOR_STATE_READY) {
            [statusLabel setText:@"READY!"];
            //probably do some modal popup
        }
    } else {
        [coverView setFrame:CGRectMake(49, 7, 251, 38)];
        [statusIV setImage:[UIImage imageNamed:@"Sensor_disabled.png"]];
        [statusLabel setText:@"Plug in an iDrank Sensor"];
    }
}

//}

-(void)warmupSecondsLeft:(double)seconds {
    NSLog(@"%f", seconds);
    double percent = (double)((double)(SENSOR_WARMUP_SECONDS - seconds) / (double)SENSOR_WARMUP_SECONDS);
    double change = percent*((double)251.0);
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
