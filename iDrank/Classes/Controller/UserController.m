//
//  UserController.m
//  iDrank
//
//  Created by Rob Balian on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserController.h"
#define MAX_RECENT_USERS 6

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
        //ideally get from defaults
        
        userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserString"];
        recentUsers = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentUsersArray"];
        
        if (!recentUsers) {
            recentUsers = [[NSMutableArray alloc] init];
        }
        if (!userName) {
            userName = [[NSString alloc] init];
            if ([recentUsers count] == 0) [self setUserName:@"User"];
        }
    }
    return self;
}

-(void)setUserName:(NSString *)name {
    if ([userName isEqualToString:name]) return;
    NSString *duplicateName = nil;
    for (NSString *storedName in recentUsers) {
        if ([storedName isEqualToString:name]) {
            duplicateName = storedName;
        }
    }
    [self removeUserNameFromRecents:duplicateName];
    
    if (userName != nil && ![userName isEqualToString:@""]) {
        [recentUsers addObject:userName];
    }
    userName = [name copy];
    //notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userChanged" object:self];
    
    if ([recentUsers count] > MAX_RECENT_USERS) {
        [recentUsers removeObjectAtIndex:0];
    }
    
    [self saveToDefaults];
}

-(void)removeUserNameFromRecents:(NSString *)name {
    [recentUsers removeObject:name];
    [self saveToDefaults];
    /*for (int i=0; i<[recentUsers count]; i++) {
     if ([[recentUsers objectAtIndex:i] isEqualToString:name]) {
     
     }
     }*/
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

-(void)saveToDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:recentUsers forKey:@"recentUsersArray"];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"currentUserString"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
