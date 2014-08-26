//
//  MJPStreamItem.m
//  StreetlightsApp
//
//  Created by Matt on 8/20/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPStreamItem.h"

@implementation MJPStreamItem
- (id)initWithUser:(MJPUser*)user description:(NSString*)description postedTimestamp:(NSNumber*)postedTimestamped expiredTimestamp:(NSNumber*)expiredTimestamp friend:(BOOL)isFriend latitude:(float)latitude longitude:(float)longitude {
    self = [super init];
    if (self) {
        self.user = user;
        self.description = description;
        self.postedTimestamp = postedTimestamped;
        self.expiredTimestamp = expiredTimestamp;
        self.isFriend = isFriend;
        self.latitude = latitude;
        self.longitude = longitude;
    }
    return self;
}

+ (NSArray*)getDummyStreamItems
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DummyData" ofType:@"json"];
    NSString *jsonData = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    return [MJPStreamItem getStreamItemsGivenFromJSON:jsonData];
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
    UIImage *userImage = [UIImage imageWithData:
                          [NSData dataWithContentsOfURL:
                           [NSURL URLWithString: [streamDictionary objectForKey:@"imageURL"]]]];
    
    BOOL isFriend = [[streamDictionary objectForKey:@"friend"] intValue];
    float latitude = [[streamDictionary objectForKey:@"latitude"] floatValue];
    float longitude = [[streamDictionary objectForKey:@"longitude"] floatValue];

    MJPStreamItem *newStreamItem = [[MJPStreamItem alloc] initWithUser:nil description:nil postedTimestamp:nil expiredTimestamp:nil friend:nil latitude:0.0 longitude:0.0];

    return newStreamItem;
}

@end
