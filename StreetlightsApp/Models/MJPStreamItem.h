//  MJPStreamItem.h
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import <Foundation/Foundation.h>
#import "MJPUser.h"

@interface MJPStreamItem : NSObject

@property (strong, nonatomic) MJPUser *user;
@property (strong, nonatomic) NSString *postDescription;
@property (strong, nonatomic) NSNumber *postedTimestamp;
@property (strong, nonatomic) NSNumber *expiredTimestamp;

@property (assign, readwrite) BOOL isFriend;

@property (assign, readwrite) float latitude;
@property (assign, readwrite) float longitude;

- (id)initWithUser:(MJPUser*)user description:(NSString*)description postedTimestamp:(NSNumber*)postedTimestamped
  expiredTimestamp:(NSNumber*)expiredTimestamp friend:(BOOL)isFriend
              latitude:(float)latitude longitude:(float)longitude;

@end
