//
//  StandardThemeViewController.h
//  iDrank
//
//  Created by Rob Balian on 1/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MeasureViewController.h"


@interface StandardThemeViewController : MeasureViewController {
    int ticks;
    IBOutlet UIView *fakeButtonCluster;
}

-(IBAction)fakeReading:(id)sender;
-(IBAction)hideFakeButtons:(id)sender;
-(IBAction)showFakeButtons:(id)sender;

@end
