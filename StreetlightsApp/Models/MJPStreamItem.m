//
//  MJPStreamItem.m
//  StreetlightsApp
//
//  Created by Matt on 8/20/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPStreamItem.h"

@implementation MJPStreamItem

- (id)initWithUserName:(NSString*)name post:(NSString*)postInfo userImage:(UIImage*)userImage friend:(BOOL)isFriend
              latitude:(float)latitude longitude:(float)longitude
{
    self = [super init];
    if (self) {
        self.userName = name;
        self.postInfo = postInfo;
        self.userImage = userImage;
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

    MJPStreamItem *newStreamItem = [[MJPStreamItem alloc] initWithUserName:[streamDictionary objectForKey:@"userName"] post:[streamDictionary objectForKey:@"postInfo"] userImage:userImage friend:isFriend latitude:latitude longitude:longitude];

    return newStreamItem;
}

@end
