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
    THEME_COLLEGE,
    NUM_THEMES
};    


@interface Theme : NSObject {
    int themeNum;
    NSArray *textDict;
}

-(id)initWithTheme:(int)theme;
-(UIView *)getView:(id)sender;
-(int)getThemeNum;
-(void)setTheme:(int)newTheme;
-(NSString *)getBodyLabel;

@end
