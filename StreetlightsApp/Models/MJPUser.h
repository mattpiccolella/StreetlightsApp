//
//  MJPUser.h
//  StreetlightsApp
//
//  Created by Matt on 8/25/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJPUser : NSObject

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* biography;
@property (strong, nonatomic) NSString* password;
@property (strong, nonatomic) NSString* email;

@property (assign, readwrite) int userId;

- (id)initWithName:(NSString*)name email:(NSString*)email password:(NSString*)password;

+ (NSData*) getJSONFromUser:(MJPUser*) user;

@end
