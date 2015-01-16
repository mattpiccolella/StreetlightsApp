//
//  MJPAssortedUtils.h
//  Around
//
//  Created by Matt on 1/13/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface MJPAssortedUtils : NSObject

+ (NSString*)stringForRemainingTime:(NSInteger)numberOfMinutes;

+ (PFObject*) getPFObjectWithName:(NSString*)name email:(NSString*)email password:(NSString*)password;

+ (UIImagePickerController*)getCameraImagePicker;

+ (UIImagePickerController*)getLibraryImagePicker;

+ (UIImage*)getDefaultUserImage;

+ (BOOL)isValidEmail:(NSString *)checkString;

+ (NSString*)completeStringForRemainingTime:(NSTimeInterval)timeInterval;

@end
