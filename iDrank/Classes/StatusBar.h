//
//  StatusBar.h
//  iDrank
//
//  Created by Rob Balian on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BACController.h"

@interface StatusBar : UIViewController <BACControllerDelegate> {
    IBOutlet UILabel *statusLabel;
    IBOutlet UIImageView *statusIV;
    IBOutlet UIView *coverView;
    
   BACController *sensorController;
}

@end
