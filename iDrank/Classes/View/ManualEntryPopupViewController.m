//
//  ManualEntryPopupViewController.m
//  iDrank
//
//  Created by Rob Balian on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ManualEntryPopupViewController.h"
#import "BACController.h"

@implementation ManualEntryPopupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //[drinksLabel setText:[NSString stringWithFormat:@"%d", (int)[drinksStepper value]]];
    }
    return self;
}

-(IBAction)stepperIncremented:(id)sender {
    [self updateLabels];
}

-(void)updateLabels {
    //NSLog(@"Updating");
    [weightLabel setText:[NSString stringWithFormat:@"%d", (int)[weightStepper value]]];
    [drinksLabel setText:[NSString stringWithFormat:@"%d", (int)[drinksStepper value]]];
    [hoursLabel setText:[NSString stringWithFormat:@"%d", (int)[hoursStepper value]]];
}

-(IBAction)done:(id)sender {
    [[BACController sharedInstance] bacManuallyEnteredWithGender:([genderSelector selectedSegmentIndex] == 0) Weight:(int)[weightStepper value] Drinks:(int)[drinksStepper value] Hours:(int)[hoursStepper value]];
    [self.view removeFromSuperview];
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
    [self updateLabels];
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
