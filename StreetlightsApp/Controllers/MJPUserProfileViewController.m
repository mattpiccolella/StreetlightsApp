//
//  MJPUserProfileViewController.m
//  StreetlightsApp
//
//  Created by Matt on 8/20/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPAppDelegate.h"
#import "MJPUserProfileViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MJPLoginViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AWSiOSSDKv2/S3.h>
#import "MJPConstants.h"
#import "MJPAWSS3Utils.h"
#import "MJPFileUploadUtils.h"

@interface MJPUserProfileViewController ()
- (IBAction)logoutButton:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UINavigationItem *userFirstName;
@property (strong, nonatomic) IBOutlet UILabel *numberOfFriends;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPosts;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
- (IBAction)editProfile:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *userImage;
- (IBAction)changeUserImage:(id)sender;

@end

@implementation MJPUserProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.appDelegate hasUserCredentials]) {
        if ([self.appDelegate currentUser] != nil) {
            NSLog(@"YES");
            [self setProfileUI:[self.appDelegate currentUser]];
        } else {
            NSLog(@"NO");
            // TODO: Parse should retrieve this otherwise. But, we should have it.
        }
    } else {
        [self loginRedirect];
    }
}

- (void)setProfileUI:(PFObject*) user {
    [self.userName setText:user[@"name"]];
    [self.userFirstName setTitle:user[@"name"]];
    // TODO: Do stuff with number of friends, etc.
    //[self.userImage.imageView setImage:[user getUserProfileImage]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginRedirect {
    MJPLoginViewController *loginViewController = [[MJPLoginViewController alloc] init];
    self.appDelegate.window.rootViewController = loginViewController;
}

- (IBAction)logoutButton:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"email"];
    [userDefaults removeObjectForKey:@"password"];
    [userDefaults removeObjectForKey:@"user_id"];
    [userDefaults synchronize];
    [self loginRedirect];
}

- (IBAction)editProfile:(id)sender {
    // TODO: Present the edit view. Allow users to edit their profile.
}
- (IBAction)changeUserImage:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    NSLog(@"This is it!");
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *newUserImage = info[UIImagePickerControllerOriginalImage];
        NSData *imageData = UIImageJPEGRepresentation(newUserImage, 0.7);
        /*
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [[self.appDelegate currentUser] email]];
        NSString *userId = [[self.appDelegate currentUser] email];
        
        NSMutableURLRequest *profPicRequest = [MJPFileUploadUtils getProfileImageUploadRequestWithData:imageData andFileName:fileName andUserId:userId];
        NSURLSessionDataTask *profPicRequestTask = [[NSURLSession sharedSession] dataTaskWithRequest:profPicRequest completionHandler:^(NSData *data,
                                                                                                                          NSURLResponse *response,
                                                                                                                          NSError *error) {
            if (!error) {
                NSDictionary *dataResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (!dataResponse) {
                    NSLog(@"FUCK WHY THE FUCK IS IT NULL?");
                }
                if (!data) {
                    NSLog(@"HOW CAN THE FUCKING DATA BE NULL?");
                }
                if ([[dataResponse objectForKey:@"status"]  isEqual:@"success"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setProfileUI:[self.appDelegate currentUser]];
                    });
                } else {
                    NSLog(@"Something went wrong.");
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
        [profPicRequestTask resume];
         */
        
    } else {
        // TODO: Display an error in the case the user entered something other than an image.
        NSLog(@"ERROR");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

+(NSString*)generateRandomString:(int)num {
    NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}
@end
