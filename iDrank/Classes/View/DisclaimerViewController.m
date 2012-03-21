//
//  DisclaimerViewController.m
//  iDrank
//
//  Created by Rob Balian on 3/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DisclaimerViewController.h"

@implementation DisclaimerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)done:(id)sender {
    [self.view removeFromSuperview];
    //[self.parentViewController dismissModalViewControllerAnimated:YES];
}

-(IBAction)disagree:(id)sender {
    //umm? alertview? kick you out?
    [[[UIAlertView alloc] initWithTitle:@"Disclaimer" message:@"We can't let you use iDrank unless you read and agree to our legal terms!" delegate:self cancelButtonTitle:@"More on BAC" otherButtonTitles:@"Ok, I'll read them", nil] show];
}

-(void)alertViewCancel:(UIAlertView *)alertView {
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) return; //they're going to stay!
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://en.wikipedia.org/wiki/Blood_alcohol_content"]];
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
