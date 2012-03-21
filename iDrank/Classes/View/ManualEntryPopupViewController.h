//
//  ManualEntryPopupViewController.h
//  iDrank
//
//  Created by Rob Balian on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManualEntryPopupViewController : UIViewController {
    IBOutlet UIStepper *weightStepper;
    IBOutlet UIStepper *drinksStepper;
    IBOutlet UIStepper *hoursStepper;
    IBOutlet UISegmentedControl *genderSelector;
    
    IBOutlet UILabel *weightLabel;
    IBOutlet UILabel *drinksLabel;
    IBOutlet UILabel *hoursLabel;
    
    
}

-(IBAction)done:(id)sender;
-(IBAction)stepperIncremented:(id)sender;
-(void)updateLabels;

@end
