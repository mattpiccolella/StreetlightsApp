//  MJPFileUploadUtils.h
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import <Foundation/Foundation.h>

@interface MJPFileUploadUtils : NSObject

+ (NSMutableURLRequest*)getProfileImageUploadRequestWithData:(NSData*)imageData andFileName:(NSString*)fileName andUserId:(NSString*)userId;

@end
