//
//  MainViewController.h
//  SoftModemTerminal
//
//  Created by arms22 on 10/05/02.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//
#import "BACController.h"
#import "MeasureViewController.h"
#import "StatusBar.h"
#import "ReadingsViewController.h"
#import "PrefsViewController.h"

@interface MainViewController : UIViewController <UITextFieldDelegate, BACControllerDelegate, UITabBarDelegate> {
	int currentTab;
    IBOutlet UITextView *textReceived;
    IBOutlet UILabel *bacLabel;

    IBOutlet UIImageView *bacBarIV;
    
    BACController *sensorController;
    
    IBOutlet UIActivityIndicatorView *warmupActivityIndicator;
    IBOutlet UILabel *warmupTimeLabel;
    IBOutlet UILabel *statusLabel;
    
    IBOutlet UITabBar *tabBar;
    
    ReadingsViewController *readingsVC;
    PrefsViewController *prefsVC;
    MeasureViewController *measureVC;
    
    StatusBar *statusBar;
    
    IBOutlet UIView *tabView;
    IBOutlet UIView *statusBarView;
}


-(IBAction)showInfo;
-(void)updateUIForBAC;
-(void)sendCode:(char)code;
-(IBAction)writeTestCharPushed:(id)sender;

@end
