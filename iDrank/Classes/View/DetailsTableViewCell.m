//
//  DetailsTableViewCell.m
//  iDrank
//
//  Created by Rob Balian on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailsTableViewCell.h"

@implementation DetailsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
                [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

@end
