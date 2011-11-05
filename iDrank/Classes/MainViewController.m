//
//  MainViewController.m
//  SoftModemTerminal
//
//  Created by arms22 on 10/05/02.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController


#define BAC_MAX_MEASURED_VALUE .20
#define BAC_BAR_HEIGHT 400.0
#define BAC_THRESHOLD_GREEN 157.0
#define BAC_THRESHOLD_YELLOW 225.0


BOOL isConnected = FALSE;

int ammoCounter = 10;
char *message = (char *)@"Got it!";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	sensorController = [BACController getInstance];
    [sensorController startWithDelegate:self];
}




-(void)updateUIForBAC {
    double bac = [sensorController getCurrentBAC];
    bacLabel.text = [NSString stringWithFormat:@"%00.3f", bac];
    
    int height = (bac/BAC_MAX_MEASURED_VALUE)*BAC_BAR_HEIGHT;
    [UIView transitionWithView:self.view duration:0.5 options:UIViewAnimationOptionCurveEaseOut+UIViewAnimationOptionBeginFromCurrentState animations:^{ 
        [bacBarIV setFrame:CGRectMake(
                                      bacBarIV.frame.origin.x,
                                      460-(height),
                                      bacBarIV.frame.size.width, bacBarIV.frame.size.height)];
    } completion:nil];
    if (height < BAC_THRESHOLD_GREEN) {
        [bacBarIV setImage:[UIImage imageNamed:@"bar_green.png"]];
    }
    if (height > BAC_THRESHOLD_GREEN) {
        [bacBarIV setImage:[UIImage imageNamed:@"bar_yellow.png"]];
    }
    if (height > BAC_THRESHOLD_YELLOW) {
        [bacBarIV setImage:[UIImage imageNamed:@"bar_red.png"]];
    }

}

//## BAC CONTROLLER DELEGATE METHODS

-(void)bacChanged:(double)bac {
    [self updateUIForBAC];
}

-(void)sensorStateChanged:(int)state {
    //update user instructions
    if (state == SENSOR_STATE_READY) {
        [warmupTimeLabel setHidden:YES];
        [warmupActivityIndicator setHidden:YES];
        [warmupActivityIndicator stopAnimating];
        [statusLabel setText:@"Ready! Blow into the sensor"];
    }
}

-(void)warmupSecondsLeft:(int)seconds {
    [warmupTimeLabel setHidden:NO];
    [warmupActivityIndicator setHidden:NO];
    [warmupTimeLabel setText:[NSString stringWithFormat:@"%d", seconds]];
    [warmupActivityIndicator startAnimating];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)dealloc {
    [super dealloc];
}


@end
