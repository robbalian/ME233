//
//  MainViewController.h
//  SoftModemTerminal
//
//  Created by arms22 on 10/05/02.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//
#import "BACController.h"


@interface MainViewController : UIViewController <UITextFieldDelegate, BACControllerDelegate> {
	IBOutlet UITextView *textReceived;
    IBOutlet UILabel *bacLabel;

    IBOutlet UIImageView *bacBarIV;
    
    BACController *sensorController;
    
}

- (IBAction)showInfo;
-(void)updateUIForBAC;
- (void)sendCode:(char)code;

@end
