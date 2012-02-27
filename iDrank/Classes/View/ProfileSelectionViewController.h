//
//  ProfileSelectionViewController.h
//  iDrank
//
//  Created by Rob Balian on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
    IBOutlet UITextField *textBox;
    IBOutlet UIButton *enterButton;
    IBOutlet UITableView *namestv;
    
    UITextField *newUserTF;
    
    
    IBOutlet UITableView *placestv;
    NSArray *places;
}

-(IBAction)addNewUser:(id)sender;
-(IBAction)done:(id)sender;
@end
