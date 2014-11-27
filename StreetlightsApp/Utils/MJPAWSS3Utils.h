//  MJPAWSS3Utils.h
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AWSiOSSDKv2/S3.h>

@interface MJPAWSS3Utils : NSObject

@property (strong, nonatomic) AWSS3TransferManager *transferManager;

+ (AWSServiceConfiguration*) serviceConfiguration;

@end
