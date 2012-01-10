//
//  UserController.m
//  iDrank
//
//  Created by Rob Balian on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserController.h"

@implementation UserController

+(UserController*)sharedInstance {
	static UserController *_sharedInstance;
	if(!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
        });
    }
    return _sharedInstance;
}

-(id)init {
    if ((self = [super init])) {
        recentUsers = [[NSMutableArray alloc] init];
        userName = [[NSString alloc] init];
    }
    return self;
}

-(void)setUserName:(NSString *)name {
    if (userName != nil && ![userName isEqualToString:@""]) {
        [recentUsers addObject:userName];
    }
    userName = [name copy];
    //notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userChanged" object:self];
}

-(NSString *)getUserName {
    return userName;
}

-(NSString *)recentUserAtIndex:(int)index {
    return [recentUsers objectAtIndex:index];    
}

-(int)recentUserCount {
    return [recentUsers count];
}


@end
