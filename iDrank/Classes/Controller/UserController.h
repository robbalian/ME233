//
//  UserController.h
//  iDrank
//
//  Created by Rob Balian on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserController : NSObject {
    NSString *userName;
    NSMutableArray *recentUsers;
    
    //FB Credentials
    //Theme prefs
}

-(void)setUserName:(NSString *)name;
-(NSString *)getUserName;
-(NSString *)recentUserAtIndex:(int)index;
-(int)recentUserCount;
-(void)removeUserNameFromRecents:(NSString *)name;

-(void)saveToDefaults;
+(UserController *)sharedInstance;
@end
