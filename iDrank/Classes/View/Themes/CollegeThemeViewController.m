//
//  CollegeThemeViewController.m
//  iDrank
//
//  Created by Rob Balian on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CollegeThemeViewController.h"
#import "iDrankAppDelegate.h"

@implementation CollegeThemeViewController

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [label0 setFont: [UIFont fontWithName: @"Crystal" size: label0.font.pointSize]];
    [label1 setFont: [UIFont fontWithName: @"Crystal" size: label1.font.pointSize]];
    [label2 setFont: [UIFont fontWithName: @"Crystal" size: label2.font.pointSize]];

    
    [self setAnchorPoint:CGPointMake(.647, .347) forView:needle];
    needle.transform = CGAffineTransformMakeRotation(-.135);
    //needle.center = CGPointMake(center.x + 35, center.y+35);
    [UIView transitionWithView:self.view duration:.45 options:UIViewAnimationCurveEaseIn animations:^{ 
        needle.transform = CGAffineTransformMakeRotation(2.435);
        NSLog(@"First needle move");
    } completion:^(BOOL finished){
        [UIView transitionWithView:self.view duration:.45 options:UIViewAnimationCurveEaseOut animations:^{ 
            needle.transform = CGAffineTransformMakeRotation(-.135);
            NSLog(@"second needle move");
        } completion:nil];
    }];
    // Do any additional setup after loading the view from its nib.
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

-(void)receivedSensorStateChangeNotification:(id)sender {
    [super receivedSensorStateChangeNotification:sender];
    int state = [[BACController sharedInstance] currentState];
    NSLog(@"MeasureView received state change notification. State: %d", state);
    double bac = [[BACController sharedInstance] getCurrentBAC];
    
    
    if (state == SENSOR_STATE_DISCONNECTED) {
        [readoutLabel setText:@""];
        [self setReadoutLabels:0];
        [measureAgainButton setHidden:YES];
        bac = 0;
    } else if (state == SENSOR_STATE_WARMING) {
        [measureAgainButton setHidden:YES];
        //[readoutLabel setText:@"Warming"];
        [UIView transitionWithView:shareCluster duration:1.0 options:UIViewAnimationCurveEaseIn animations:^{ [shareCluster setAlpha:0.0]; } completion:nil];
    } else if (state == SENSOR_STATE_READY) {
        bac = 0;
        [self setReadoutLabels:0];
        //[readoutLabel setText:@"Ready"];
    } else if (state == SENSOR_STATE_READING) {
        bac = 0;
        //[readoutLabel setText:@"Reading..."];
        //play sound or vibrate on loop
    } else if (state == SENSOR_STATE_CALCULATING) {
        bac = 0;
        //[readoutLabel setText:@"Calculating..."];
    } else if (state == SENSOR_STATE_DONE || state == SENSOR_STATE_OFF) {
        [self setReadoutLabels:bac];
        [readoutLabel setText:[NSString stringWithFormat:@"%.2f", bac]];
        [measureAgainButton setHidden:NO];
        [UIView transitionWithView:shareCluster duration:1.0 options:UIViewAnimationCurveEaseIn animations:^{ [shareCluster setAlpha:1.0]; 
        } completion:nil];
    }
    

    
    NSLog(@"Speedometer setting to BAC: %f", bac);
    [UIView transitionWithView:self.view duration:1.0 options:UIViewAnimationCurveEaseOut animations:^{ 
        needle.transform = CGAffineTransformMakeRotation(2.3*(bac/.40) - .135);
    } completion:nil];
}

-(void)setReadoutLabels:(double)num {
    NSString *str = [NSString stringWithFormat:@"%.2f",num];
    //NSLog(str);
    [label0 setText:[NSString stringWithFormat:@"%c", [str characterAtIndex:0]]];
    [label1 setText:[NSString stringWithFormat:@"%c", [str characterAtIndex:2]]];
    [label2 setText:[NSString stringWithFormat:@"%c", [str characterAtIndex:3]]];
}

-(IBAction)playSound:(id)sender {
    
    
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    
    
    
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/ding.mp3", [[NSBundle mainBundle] resourcePath]]];
    
	NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	//audioPlayer.numberOfLoops = -1;
    
	if (audioPlayer == nil)
		NSLog([error description]);
	else
		[audioPlayer play];
    
    //[[iDrankAppDelegate getInstance] playAif:@"ding"];
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
