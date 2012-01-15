//
//  ReadingsTableViewCell.h
//  iDrank
//
//  Created by Rob Balian on 1/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ReadingsTableViewCell : UITableViewCell {
    IBOutlet UILabel *userNameLabel;
    IBOutlet UILabel *placeLabel;
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *bacLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *userNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *placeLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *bacLabel;

@end
