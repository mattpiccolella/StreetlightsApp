//  MJPQueryUtils.h
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface MJPQueryUtils : NSObject

+ (PFQuery*) getStreamItemsForLatitude:(float)latitude longitude:(float)longitude radius:(float)radius;
+ (PFQuery*) getStreamItemsForUser:(PFObject*)user;
+ (PFQuery*) getUserQueryForEmail:(NSString*)email password:(NSString*)password;
+ (PFQuery*) getStreamItemsForMinPoint:(CLLocationCoordinate2D)minPoint maxPoint:(CLLocationCoordinate2D)maxPoint ;

@end
