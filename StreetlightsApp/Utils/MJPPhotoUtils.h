//
//  MJPPhotoUtils.h
//  Around
//
//  Created by Matt on 1/1/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJPPhotoUtils : NSObject

+ (UIImage*) croppedImageWithInfo:(NSDictionary*)info;

+ (void) circularCrop:(UIImageView*)image;

@end
