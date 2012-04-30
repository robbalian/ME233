//
//  ReadingsViewController.m
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ReadingsViewController.h"
#import "iDrankAppDelegate.h"
#import "DetailsTableViewCell.h"
#import "DetailsImageTableViewCell.h"

@implementation ReadingsViewController

@synthesize readingsCell;

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
    if ([[results objectAtIndex:[indexPath row]] isKindOfClass:[NSNumber class]]) {
        if ([(NSNumber *)[results objectAtIndex:[indexPath row]] intValue] == 1) {
            return 100.0;
        } else {
            return 375.0;
        } 
    } else {
            return 60.0;
    }
    //return ([[results objectAtIndex:[indexPath row]] isKindOfClass:[NSNumber class]]) ? 100 : 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    id obj = [results objectAtIndex:[indexPath row]];
    if ([obj isKindOfClass:[NSNumber class]]) {
        if ([(NSNumber *)obj intValue] == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"detailsCellID"];
            if (cell == nil) {
                NSLog(@"New Details Cell Made");
                
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DetailsTableViewCell" owner:self options:nil];
                for (id ob in topLevelObjects) {
                    if ([ob isKindOfClass:[DetailsTableViewCell class]]) {
                        cell = (DetailsTableViewCell *)ob;
                        break;
                    }
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                //cell = [[DetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailsCellID"];
                return cell;            
            }
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"detailsImageCellID"];
            if (cell == nil) {
                NSLog(@"New ImageDetails Cell Made");
                
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"DetailsImageTableViewCell" owner:self options:nil];
                for (id ob in topLevelObjects) {
                    if ([ob isKindOfClass:[DetailsImageTableViewCell class]]) {
                        cell = (DetailsImageTableViewCell *)ob;
                        break;
                    }
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                //cell = [[DetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailsCellID"];
                return cell;            
            }    
            
        }
    } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if (cell == nil){
            NSLog(@"New Cell Made");
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ReadingsTableViewCell" owner:self options:nil];
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
            ((ReadingsTableViewCell *)cell).placeLabel.text = @"";
        } else {
            ((ReadingsTableViewCell *)cell).placeLabel.text = [NSString stringWithFormat:@"@ %@", event.place_name];
        }
        ((ReadingsTableViewCell *)cell).timeLabel.text = [NSString stringWithFormat:@"%@", [self dateDiff:event.time]];
        ((ReadingsTableViewCell *)cell).bacLabel.text = [NSString stringWithFormat:@"%.2f", [event.reading doubleValue]];
        ((ReadingsTableViewCell *)cell).userNameLabel.text = event.name;
        ((ReadingsTableViewCell *)cell).userInteractionEnabled = YES;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {       
    //[[tv cellForRowAtIndexPath:indexPath] setFrame:CGRectMake(0, 0, 320, 100)];
    
    //hacky way to determine what's a result row and what's a dropdown row
    if ([[results objectAtIndex:[indexPath row]] isKindOfClass:[NSNumber class]]) {
        [self removeDetailRowAtIndex:indexPath.row];
    } else if (indexPath.row+1 < [results count] && [[results objectAtIndex:([indexPath row]+1)] isKindOfClass:[NSNumber class]]) {
        [self removeDetailRowAtIndex:indexPath.row+1];
    } else {
        //int randNum  = rand()%2;
        NSNumber *num = [[NSNumber alloc] initWithInt:1];
        [results insertObject:num atIndex:indexPath.row+1];
        NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
        [tv insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
    [[tv cellForRowAtIndexPath:indexPath] setHighlighted:NO];
}

-(void)removeDetailRowAtIndex:(int)row {
    DetailsTableViewCell *detailRow = (DetailsTableViewCell *)[results objectAtIndex:row];
    //[detailRow release];
    //[detailRow release];
    [results removeObjectAtIndex:row];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];    
    [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
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
