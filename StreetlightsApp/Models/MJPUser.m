//
//  MJPUser.m
//  StreetlightsApp
//
//  Created by Matt on 8/25/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPUser.h"

@implementation MJPUser

- (id)initWithName:(NSString*)name email:(NSString*)email password:(NSString*)password
{
    self = [super init];
    if (self) {
        self.name = name;
        self.email = email;
        self.password = password;
        self.biography = @"";
    }
    return self;
}

+ (NSData*) getJSONFromUser:(MJPUser*) user {
    NSString *userString = [NSString stringWithFormat:@"name=%@&email=%@&password=%@&biography=%@",
                            user.name, user.email, user.password, user.biography];;
    NSData *data = [userString dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

+ (MJPUser*) getUserFromJSON:(NSDictionary*) userDictionary {
    MJPUser *user = [[MJPUser alloc] initWithName:[userDictionary objectForKey:@"name"] email:[userDictionary objectForKey:@"email"] password:[userDictionary objectForKey:@"password"]];
    return user;
}

- (UIImage*)getUserProfileImage {
    NSString *urlString = [NSString stringWithFormat:@"http://107.170.105.12/get_user_image/%@", self.email];
    UIImage* profileImage = [UIImage imageWithData:
                        [NSData dataWithContentsOfURL:
                         [NSURL URLWithString: urlString]]];
    return profileImage;
}
@end
