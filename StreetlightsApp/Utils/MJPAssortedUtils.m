//
//  MJPAssortedUtils.m
//  Around
//
//  Created by Matt on 1/13/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPAssortedUtils.h"
#import <Parse/Parse.h>

@implementation MJPAssortedUtils

+ (NSString*)stringForRemainingTime:(NSInteger)numberOfMinutes {
    if (numberOfMinutes < 60) {
        return [NSString stringWithFormat:@"%dm", numberOfMinutes];
    } else {
        return [NSString stringWithFormat:@"%dh", numberOfMinutes / 60];
    }
}

+ (PFObject*) getPFObjectWithName:(NSString*)name email:(NSString*)email password:(NSString*)password; {
    PFObject *parseUser = [PFObject objectWithClassName:@"User"];
    parseUser[@"name"] = name;
    parseUser[@"email"] = email;
    parseUser[@"password"] = password;
    return parseUser;
}

@end
