//
//  ReadingsViewController.h
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReadingsTableViewCell.h"


@interface ReadingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *results;
    IBOutlet UITableView *tv;
    
    IBOutlet ReadingsTableViewCell *readingsCell;
    
}

@property (nonatomic, retain) IBOutlet ReadingsTableViewCell *readingsCell;

-(void)refreshData;
-(NSString *)dateDiff:(NSDate *)origDate;

//share
-(IBAction)SMS:(id)sender;
-(IBAction)facebook:(id)sender;
-(IBAction)twitter:(id)sender;


@end
