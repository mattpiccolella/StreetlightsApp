//
//  MJPPhotoUtils.m
//  Around
//
//  Created by Matt on 1/1/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPPhotoUtils.h"

@implementation MJPPhotoUtils

+ (UIImage*) croppedImageWithInfo:(NSDictionary*)info {
    UIImage *newUserImage = info[UIImagePickerControllerOriginalImage];
    CGSize size = newUserImage.size;
    CGRect cropRect = [[info objectForKey:@"UIImagePickerControllerCropRect"] CGRectValue];
    UIGraphicsBeginImageContext(cropRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // checks and corrects the image orientation.
    UIImageOrientation orientation = [newUserImage imageOrientation];
    if(orientation == UIImageOrientationUp) {
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1, -1);
        
        cropRect = CGRectMake(cropRect.origin.x,
                              -cropRect.origin.y,
                              cropRect.size.width,
                              cropRect.size.height);
    }
    else if(orientation == UIImageOrientationRight) {
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextRotateCTM(context, -M_PI/2);
        size = CGSizeMake(size.height, size.width);
        
        cropRect = CGRectMake(cropRect.origin.y,
                              cropRect.origin.x,
                              cropRect.size.height,
                              cropRect.size.width);
    }
    else if(orientation == UIImageOrientationDown) {
        CGContextTranslateCTM(context, size.width, 0);
        CGContextScaleCTM(context, -1, 1);
        
        cropRect = CGRectMake(-cropRect.origin.x,
                              cropRect.origin.y,
                              cropRect.size.width,
                              cropRect.size.height);
    }
    
    // draws the image in the correct place.
    CGContextTranslateCTM(context, -cropRect.origin.x, -cropRect.origin.y);
    CGContextDrawImage(context,
                       CGRectMake(0,0, size.width, size.height),
                       newUserImage.CGImage);
    // and pull out the cropped image
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}

+ (void) circularCrop:(UIImageView *)imageView {
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.clipsToBounds = YES;
}

@end
