//
//  MJPUser.h
//  StreetlightsApp
//
//  Created by Matt on 8/25/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJPUser : NSObject

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* fullName;
@property (strong, nonatomic) NSString* biography;
@property (strong, nonatomic) NSString* email;

@property (assign, readwrite) int userId;

- (id)initWithFirstName:(NSString*)firstName fullName:(NSString*)fullName email:(NSString*)email;

@end
