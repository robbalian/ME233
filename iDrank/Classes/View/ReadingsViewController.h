//
//  ReadingsViewController.h
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *results;
    IBOutlet UITableView *tv;
    
}

-(void)refreshData;
-(NSString *)dateDiff:(NSDate *)origDate;



@end
