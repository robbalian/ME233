//
//  ReadingsViewController.m
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ReadingsViewController.h"
#import "iDrankAppDelegate.h"
#import "ReadingsTableViewCell.h"

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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReadingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil){
        NSLog(@"New Cell Made");
    
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ReadingsTableViewCell" owner:nil options:nil];
        for (id ob in topLevelObjects) {
            if ([ob isKindOfClass:[ReadingsTableViewCell class]]) {
                cell = (ReadingsTableViewCell *)ob;
                break;
            }
        }

        ///cell = (ReadingsTableViewCell *)[[ReadingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    
    BACEvent *event = (BACEvent *)[results objectAtIndex:[indexPath row]];
    // NSLog(@"%@", event);
    /*cell.textLabel.text = [NSString stringWithFormat:@"%@ : %.2f", event.name, [event.reading doubleValue]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ at %@", [self dateDiff:event.time], event.place_name];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    */
    if ([event.place_name isEqualToString:@"unknown"]) {
        cell.placeLabel.text = @"";
    } else {
        cell.placeLabel.text = [NSString stringWithFormat:@"@ %@", event.place_name];
    }
    cell.timeLabel.text = [NSString stringWithFormat:@"%@", [self dateDiff:event.time]];
    cell.bacLabel.text = [NSString stringWithFormat:@"%.2f", [event.reading doubleValue]];
    cell.userNameLabel.text = event.name;
    
    
    return cell;
}

-(NSString *)dateDiff:(NSDate *)origDate {
    //NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //[df setFormatterBehavior:NSDateFormatterBehavior10_4];
    //[df setDateFormat:@"EEE, dd MMM yy HH:mm:ss VVVV"];
    //NSDate *convertedDate = [df dateFromString:origDate];
    //[df release];
    NSDate *todayDate = [NSDate date];
    double ti = [origDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if(ti < 1) {
        return @"never";
    } else      if (ti < 60) {
        return @"less than a minute ago";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours ago", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    } else {
        return @"never";
    }   
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
