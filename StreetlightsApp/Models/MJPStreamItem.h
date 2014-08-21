//
//  MJPStreamItem.h
//  StreetlightsApp
//
//  Created by Matt on 8/20/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJPStreamItem : NSObject

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *postInfo;
@property (strong, nonatomic) UIImage *userImage;

@property (assign, readwrite) BOOL isFriend;

- (id)initWithUserName:(NSString*)name post:(NSString*)postInfo userImage:(UIImage*)userImage friend:(BOOL)isFriend;
+ (NSArray*) getDummyStreamItems;

@end
