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
    IBOutlet UIView *shareCluster;
    IBOutlet UILabel *placeLabel;
    IBOutlet UILabel *userNameLabel;
}

-(IBAction)testChar:(id)sender;

//sharing
-(IBAction)facebookButtonTapped:(id)sender;
-(IBAction)SMSButtonTapped:(id)sender;
-(IBAction)twitterButtonTapped:(id)sender;

//login/place
-(IBAction)placeButtonTapped:(id)sender;
-(IBAction)profileButtonTapped:(id)sender;

@end