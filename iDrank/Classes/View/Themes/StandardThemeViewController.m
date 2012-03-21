//
//  StandardThemeViewController.m
//  iDrank
//
//  Created by Rob Balian on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StandardThemeViewController.h"

#define TICK_DURATION 0.1
#define TOTAL_TICKS 30

@implementation StandardThemeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)receivedSensorStateChangeNotification:(id)sender {
    [super receivedSensorStateChangeNotification:sender];
    
    int state = [[BACController sharedInstance] currentState];
    NSLog(@"MeasureView received state change notification. State: %d", state);

    if (state == OFF) {
        ticks = 0;
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(suspenseTick) userInfo:nil repeats:NO]; 
    }
}

-(IBAction)fakeReading:(id)sender {
    [[BACController sharedInstance] bacManuallyEnteredWithGender:YES Weight:150 Drinks:(rand() % 10) Hours:(rand() % 6)];
}

-(void)suspenseTick {
    if (ticks < TOTAL_TICKS) {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(suspenseTick) userInfo:nil repeats:NO];
    }
    NSString *bacString = @"";
    double bac = [[BACController sharedInstance] getCurrentBAC];
    
    int first = ticks > (TOTAL_TICKS/4) ? 0 : (rand()%10);
    int second = ticks > 2*(TOTAL_TICKS/4) ? ((int)(bac*10.0))%10 : (rand()%10);
    int third = ticks > 3*(TOTAL_TICKS/4) ? ((int)(round((bac*100.0))))%10 : (rand()%10);
    
    [readoutLabel setText:[NSString stringWithFormat:@"%d.%d%d", first, second, third]];
    ticks++;
}

-(void)displayFinalReading {
    double bac = [[BACController sharedInstance] getCurrentBAC];
    [readoutLabel setText:[NSString stringWithFormat:@"%.2f", bac]];
    [infoTitleLabel setText:[NSString stringWithFormat:@"%.2f BAC", bac]];
    [measureAgainButton setHidden:NO];
    [self startThemeAnimations];
    [UIView transitionWithView:shareCluster duration:1.0 options:UIViewAnimationCurveEaseIn animations:^{ [shareCluster setAlpha:1.0]; 
    } completion:nil];
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
