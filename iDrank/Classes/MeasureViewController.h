//
//  MeasureViewController.h
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BACController.h"
#import "TabPane.h"

@interface MeasureViewController : TabPane  {
    IBOutlet UILabel *readoutLabel;
    IBOutlet UILabel *infoBodyLabel;
    IBOutlet UILabel *infoTitleLabel;
    IBOutlet UIButton *measureAgainButton;
    IBOutlet UIImageView *circle;    
}

-(IBAction)testChar:(id)sender;
-(void)animateThemeChange;

//-(IBAction)ripple:(id)sender;
@end