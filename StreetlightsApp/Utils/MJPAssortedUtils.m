//
//  MJPAssortedUtils.m
//  Around
//
//  Created by Matt on 1/13/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPAssortedUtils.h"
#import <Parse/Parse.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation MJPAssortedUtils

+ (NSString*)stringForRemainingTime:(NSInteger)numberOfMinutes {
    if (numberOfMinutes < 60) {
        return [NSString stringWithFormat:@"%dm", numberOfMinutes];
    } else {
        return [NSString stringWithFormat:@"%dh", numberOfMinutes / 60];
    }
}

+ (PFObject*)getPFObjectWithName:(NSString*)name email:(NSString*)email password:(NSString*)password; {
    PFObject *parseUser = [PFObject objectWithClassName:@"User"];
    parseUser[@"name"] = name;
    parseUser[@"email"] = email;
    parseUser[@"password"] = password;
    return parseUser;
}

+ (UIImagePickerController*)getLibraryImagePicker {
    return [MJPAssortedUtils getImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

+ (UIImagePickerController*)getCameraImagePicker {
    return [MJPAssortedUtils getImagePicker:UIImagePickerControllerSourceTypeCamera];
}

+ (UIImagePickerController*)getImagePicker:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = type;
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    imagePicker.allowsEditing = YES;
    return imagePicker;
}

+ (UIImage*)getDefaultUserImage {
    return [UIImage imageNamed:@"images.jpeg"];
}

+ (BOOL)isValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
