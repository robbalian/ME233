//
//  MeasureViewController.h
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BACController.h"


@interface MeasureViewController : UIViewController  {
    IBOutlet UILabel *readoutLabel;
    IBOutlet UILabel *infoBodyLabel;
    IBOutlet UILabel *infoTitleLabel;
    IBOutlet UIButton *measureAgainButton;
    IBOutlet UIImageView *circle;  
    
    IBOutlet UIView *shareCluster;
}

-(IBAction)testChar:(id)sender;
-(void)setViewForThemeAnimated:(BOOL)animated;
-(IBAction)facebookButtonTapped:(id)sender;

//-(IBAction)ripple:(id)sender;
@end