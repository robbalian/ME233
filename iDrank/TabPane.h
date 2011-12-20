//
//  TabPane.h
//  iDrank
//
//  Created by Rob Balian on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TabPane : UIViewController {
    UIViewController *parent;
}
@property (nonatomic, retain) UIViewController *parent;
@end
