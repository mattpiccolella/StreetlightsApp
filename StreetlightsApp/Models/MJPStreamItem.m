//
//  MJPStreamItem.m
//  StreetlightsApp
//
//  Created by Matt on 8/20/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPStreamItem.h"
#import <Parse/Parse.h>

@implementation MJPStreamItem
- (id)initWithUser:(MJPUser*)user description:(NSString*)description postedTimestamp:(NSNumber*)postedTimestamped expiredTimestamp:(NSNumber*)expiredTimestamp friend:(BOOL)isFriend latitude:(float)latitude longitude:(float)longitude {
    self = [super init];
    if (self) {
        self.user = user;
        self.postDescription = description;
        self.postedTimestamp = postedTimestamped;
        self.expiredTimestamp = expiredTimestamp;
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

+ (PFObject*)getPFObjectFromStreamItem:(MJPStreamItem*)streamItem {
    PFObject *parseStreamItem = [PFObject objectWithClassName:@"StreamItem"];
    [parseStreamItem setObject:[streamItem user] forKey:@"user"];
    [parseStreamItem setObject:[streamItem postDescription] forKey:@"description"];
    [parseStreamItem setObject:[streamItem postedTimestamp] forKey:@"postedTimestamp"];
    [parseStreamItem setObject:[streamItem expiredTimestamp] forKey:@"expiredTimestamp"];
    [parseStreamItem setObject:[NSNumber numberWithFloat:streamItem.latitude] forKey:@"latitude"];
    [parseStreamItem setObject:[NSNumber numberWithFloat:streamItem.longitude] forKey:@"longitude"];
    return parseStreamItem;
}

+ (NSArray*)getStreamItemsGivenFromJSON:(NSString*)json
{
    NSMutableArray *streamItems = [[NSMutableArray alloc] init];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSArray *jsonItems = [result objectForKey:@"streamItems"];
    for (NSDictionary *item in jsonItems) {
        [streamItems addObject:[MJPStreamItem getStreamItemFromDictionary:item]];
    }
    return streamItems;
}

+ (MJPStreamItem*)getStreamItemFromDictionary:(NSDictionary*)streamDictionary
{
    MJPUser *postUser = [MJPUser getUserFromJSON:[streamDictionary objectForKey:@"user"]];
    NSString *description = [streamDictionary objectForKey:@"description"];
    NSNumber *postedTimestamp = [streamDictionary objectForKey:@"postedTimestamp"];
    NSNumber *expiredTimestamp = [streamDictionary objectForKey:@"expiredTimestamp"];
    
    BOOL isFriend = [[streamDictionary objectForKey:@"friend"] intValue];
    float latitude = [[streamDictionary objectForKey:@"latitude"] floatValue];
    float longitude = [[streamDictionary objectForKey:@"longitude"] floatValue];

    MJPStreamItem *newStreamItem = [[MJPStreamItem alloc] initWithUser:postUser description:description
        postedTimestamp:postedTimestamp expiredTimestamp:expiredTimestamp friend:isFriend
        latitude:latitude longitude:longitude];

    return newStreamItem;
}

@end
