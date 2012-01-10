//
//  PlaceSelectionViewController.h
//  iDrank
//
//  Created by Rob Balian on 1/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tv;
    NSArray *places;
}

-(IBAction)cancelTapped:(id)sender;

@end
