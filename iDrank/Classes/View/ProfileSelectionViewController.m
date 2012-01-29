//
//  ProfileSelectionViewController.m
//  iDrank
//
//  Created by Rob Balian on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileSelectionViewController.h"
#import "UserController.h"
#import "LocationController.h"

@implementation ProfileSelectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        places = [[LocationController sharedInstance] getNearbyPlaces];
    }
    return self;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Set up the cell...
    if ([tableView isEqual:namestv]) {
        int numRows = [[UserController sharedInstance] recentUserCount];
        NSString *cellValue = [[UserController sharedInstance] recentUserAtIndex:(numRows - [indexPath row]-1)];
        cell.textLabel.text = cellValue;
    } else if ([tableView isEqual:placestv]) {
        NSString *cellValue = [[places objectAtIndex:[indexPath row]] objectForKey:@"name"];
        cell.textLabel.text = cellValue;
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableView isEqual:namestv] ? [[UserController sharedInstance] recentUserCount] : [places count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:namestv]) {
        [[UserController sharedInstance] setUserName:[[[namestv cellForRowAtIndexPath:indexPath] textLabel] text]];
        [[UserController sharedInstance] removeUserNameFromRecents: [[[namestv cellForRowAtIndexPath:indexPath] textLabel] text]];
    } else {
        [[LocationController sharedInstance] setPlaceName:[[places objectAtIndex:[indexPath row]] objectForKey:@"name"]];
    }
    [self done:nil];
}

-(IBAction)done:(id)sender {
    [UIView transitionWithView:self.view duration:.35 options:UIViewAnimationCurveEaseInOut animations:^{ 
        self.view.transform = CGAffineTransformMakeTranslation(+320, 0);
    } completion:^(BOOL finished){
        [self.view removeFromSuperview];
        [self release];
    }];
    //if (![textBox.text isEqualToString:@""]) {
    //    [[UserController sharedInstance] setUserName:textBox.text];
    //    [self dismissModalViewControllerAnimated:YES];
    //}
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
//    [self.view setFrame:CGRectMake(180, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [UIView transitionWithView:self.view duration:.35 options:UIViewAnimationCurveEaseInOut animations:^{ 
        self.view.transform = CGAffineTransformMakeTranslation(-320, 0);
        //[self.view setFrame:CGRectMake(180, 0, self.view.frame.size.width, self.view.frame.size.height)];
    } completion:nil];

    
    [placestv reloadData];
    [namestv reloadData];
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
