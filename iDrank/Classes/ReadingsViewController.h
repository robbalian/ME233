//
//  ReadingsViewController.h
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TabPane.h"

@interface ReadingsViewController : TabPane <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *results;
    IBOutlet UITableView *tv;
}

-(void)refreshData;



@end
