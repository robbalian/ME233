//
//  StatusBar.m
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StatusBar.h"
#import "UserController.h"
#import "LocationController.h"
#import "ProfileSelectionViewController.h"
#import "iDrankAppDelegate.h"
#import "MainViewController.h"

@implementation StatusBar

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSensorStateChangeNotification:) name:@"stateChanged" object:[BACController sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLocationChangeNotification:) name:@"locationChanged" object:[LocationController sharedInstance]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUserChangeNotification:) name:@"userChanged" object:[UserController sharedInstance]];
        //namePlaceLabel.adjustsFontSizeToFitWidth = YES;
        
        sensorController = [BACController sharedInstance];
        [sensorController setDelegate:self];
    }
    return self;
}


-(void)receivedLocationChangeNotification:(id)sender {
    [namePlaceLabel setText:[NSString stringWithFormat:@"%@ @ %@", [[UserController sharedInstance] getUserName], [[LocationController sharedInstance] getPlaceName]]];
}

-(void)receivedUserChangeNotification:(id)sender {
    [namePlaceLabel setText:[NSString stringWithFormat:@"%@ @ %@", [[UserController sharedInstance] getUserName], [[LocationController sharedInstance] getPlaceName]]];
}


//## BAC CONTROLLER DELEGATE METHODS

-(void)receivedSensorStateChangeNotification:(id)sender {
    int state = [[BACController sharedInstance] currentState];
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


-(IBAction)profileButtonTapped:(id)sender {
    ProfileSelectionViewController *psvc = [[ProfileSelectionViewController alloc] init];
    [psvc.view setFrame:CGRectMake(0, 0, psvc.view.frame.size.width, psvc.view.frame.size.height)];
    [((iDrankAppDelegate *)[iDrankAppDelegate getInstance]).mainViewController.view addSubview:psvc.view];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [namePlaceLabel setText:[[UserController sharedInstance] getUserName]];

    
#ifdef USING_SIM
    //this shit is a hack
    [[BACController sharedInstance] verifySensor]; //fake that there's a headphone jack
#endif
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
