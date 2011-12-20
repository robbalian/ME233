//
//  Theme.m
//  iDrank
//
//  Created by Rob Balian on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Theme.h"

@implementation Theme

-(id)initWithTheme:(int)theme andDelegate:(id)del {
    if (self = [super init]) {
        themeNum = theme;
        delegate = del;
    }
    return self;
    //UIImageView *
}

-(UIView *)getView {

    NSString *nibName;
    switch (themeNum) {
        case THEME_STANDARD:
            nibName = @"StandardThemeView";
            break;
        case THEME_COLLEGE:
            nibName = @"CollegeThemeView";
            break;
        default:
            nibName = @"StandardThemeView";
            break;
    }
    NSArray *nibObjs;
    nibObjs = [[NSBundle mainBundle] loadNibNamed:nibName owner:delegate options:nil];
    return [nibObjs objectAtIndex:0];
}

-(int)getThemeNum {
    return themeNum;
}

-(void)setTheme:(int)newTheme {
    themeNum = newTheme;
}

@end
