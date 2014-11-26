//
//  MJPQueryUtils.m
//  StreetlightsApp
//
//  Created by Matt on 11/26/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPQueryUtils.h"

@implementation MJPQueryUtils

+ (PFQuery*) getStreamItemsForLatitude:(float)latitude longitude:(float)longitude radius:(float)radius {
    PFQuery *streamItemQuery = [PFQuery queryWithClassName:@"StreamItem"];
    float MILES_PER_LONG = 53.0;
    float MILES_PER_LAT = 69.0;
    NSNumber *max_long = [NSNumber numberWithFloat:(longitude + (radius / MILES_PER_LONG))];
    NSNumber *min_long = [NSNumber numberWithFloat:(longitude - (radius / MILES_PER_LONG))];
    NSNumber *max_lat = [NSNumber numberWithFloat:(latitude + (radius / MILES_PER_LAT))];
    NSNumber *min_lat = [NSNumber numberWithFloat:(latitude - (radius / MILES_PER_LAT))];
    NSNumber *currentTime = [NSNumber numberWithLong:[NSDate timeIntervalSinceReferenceDate]];
    [streamItemQuery whereKey:@"longitude" lessThan:max_long];
    NSLog(@"Min and Max Long: %@ %@", max_long, min_long);
    NSLog(@"Min and Max Lat: %@ %@", max_lat, min_lat);
    [streamItemQuery whereKey:@"longitude" greaterThan:min_long];
    [streamItemQuery whereKey:@"latitude" lessThan:max_lat];
    [streamItemQuery whereKey:@"latitude" greaterThan:min_lat];
    NSLog(@"Expired Timestamp: %@", currentTime);
    [streamItemQuery whereKey:@"expiredTimestamp" greaterThan:currentTime];
    [streamItemQuery includeKey:@"user"];
    [streamItemQuery includeKey:@"profilePicture"];
    [streamItemQuery addDescendingOrder:@"postedTimestamp"];
    return streamItemQuery;
}

@end
