//
//  MJPUser.m
//  StreetlightsApp
//
//  Created by Matt on 8/25/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPUser.h"

@implementation MJPUser

- (id)initWithFirstName:(NSString*)firstName fullName:(NSString*)fullName email:(NSString*)email 
{
    self = [super init];
    if (self) {
        self.firstName = firstName;
        self.fullName = fullName;
        self.email = email;
        self.biography = @"";
    }
    return self;
}

+ (NSData*) getJSONFromUser:(MJPUser*) user {
    NSDictionary *userData = [[NSDictionary alloc] initWithObjects:@[user.firstName, user.fullName, user.email, user.biography]
                                                           forKeys:@[@"firstName", @"fullName", @"email", @"biography"]];
    return [NSJSONSerialization dataWithJSONObject:userData options:0 error:nil];
}
@end
