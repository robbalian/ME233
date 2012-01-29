//
//  CollegeThemeViewController.h
//  iDrank
//
//  Created by Rob Balian on 1/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MeasureViewController.h"
#import <QuartzCore/CATransform3D.h>
#import <QuartzCore/CALayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioToolbox.h>

@interface CollegeThemeViewController : MeasureViewController {
    IBOutlet UIImageView *needle;
    IBOutlet UILabel *label0;
    IBOutlet UILabel *label1;
    IBOutlet UILabel *label2;
    AVAudioPlayer *audioPlayer;
}

-(void)receivedSensorStateChangeNotification:(id)sender;
-(IBAction)playSound:(id)sender;

@end
