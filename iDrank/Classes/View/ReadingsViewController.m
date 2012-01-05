//
//  ReadingsViewController.m
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ReadingsViewController.h"
#import "iDrankAppDelegate.h"

@implementation ReadingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        results = ((iDrankAppDelegate *)[[UIApplication sharedApplication] delegate]).eventArray;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    BACEvent *event = (BACEvent *)[results objectAtIndex:[indexPath row]];
   // NSLog(@"%@", event);
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %.2f", event.name, [event.reading doubleValue]];
    
    return cell;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
       
    // Do any additional setup after loading the view from its nib.
}

-(void)refreshData {
    iDrankAppDelegate *appDel =(iDrankAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDel fetchRecords];
    results = appDel.eventArray;
    [tv reloadData];
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
