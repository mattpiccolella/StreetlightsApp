//
//  MJPQueryUtils.h
//  StreetlightsApp
//
//  Created by Matt on 11/26/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface MJPQueryUtils : NSObject

+ (PFQuery*) getStreamItemsForLatitude:(float)latitude longitude:(float)longitude radius:(float)radius;

@end
