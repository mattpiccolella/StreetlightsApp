//  MJPAWSS3Utils.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPAWSS3Utils.h"
#import "MJPConstants.h"
#import <AWSiOSSDKv2/AWSCredentialsProvider.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/S3.h>


@implementation MJPAWSS3Utils

- (instancetype)init {
    self = [super init];
    if (self) {
        self.transferManager = [self transferManager];
    }
    return self;
}

+ (AWSServiceConfiguration*) serviceConfiguration {
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider credentialsWithRegionType:AWSRegionAPNortheast1 accountId:AWSAccountID identityPoolId:CognitoPoolID unauthRoleArn:CognitoRoleUnauth authRoleArn:CognitoRoleAuth];
    
    [[credentialsProvider getIdentityId] continueWithSuccessBlock:^id(BFTask *task){
        // TODO: Do more stuff upcon completion.
        return nil;
    }];
    
    AWSServiceConfiguration *config = [AWSServiceConfiguration configurationWithRegion:AWSRegionAPNortheast1 credentialsProvider:credentialsProvider];
    return config;
}

- (AWSS3TransferManager*) transferManager {
    return [[AWSS3TransferManager alloc] initWithConfiguration:[MJPAWSS3Utils serviceConfiguration] identifier:@"UnAuthTransferManager"];
}

- (AWSS3TransferManagerUploadRequest*) requestForURL:(NSURL*)url {
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = S3BucketName;
    uploadRequest.key = [[NSUUID UUID] UUIDString];
    uploadRequest.body = url;
    uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        if (totalBytesSent == totalBytesExpectedToSend) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Stop activity indicator, or something.
            });
        }
    };
    return uploadRequest;
}

- (void) uploadImage:(AWSS3TransferManagerUploadRequest*)uploadRequest {
    [[self.transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            if (task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused) {
                // TODO: Need to do this.
            }
        } else {
            // TODO: Error. Fix.
        }
        return nil;
    }];
}
@end
