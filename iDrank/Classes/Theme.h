//
//  Theme.h
//  iDrank
//
//  Created by Rob Balian on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    THEME_STANDARD = 0,
    THEME_COLLEGE
};    


@interface Theme : NSObject {
    
}

-(void)initWithTheme:(int)theme;

@end
