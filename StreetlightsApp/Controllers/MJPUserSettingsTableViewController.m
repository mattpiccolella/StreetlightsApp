//
//  MJPUserSettingsTableViewController.m
//  Around
//
//  Created by Matt on 1/2/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPUserSettingsTableViewController.h"
#import "MJPAppDelegate.h"
#import "MJPPhotoUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MJPLoginViewController.h"
#import "MJPChangePasswordViewController.h"
#import "MJPQueryUtils.h"
#import "MJPPostHistoryTableViewController.h"

@interface MJPUserSettingsTableViewController ()
@property (strong, nonatomic) IBOutlet UIButton *profilePicture;
- (IBAction)changeProfilePicture:(id)sender;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *userEmail;
- (IBAction)logout:(id)sender;
- (IBAction)changePassword:(id)sender;
- (IBAction)viewPostHistory:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *facebookSharing;
- (IBAction)shareWithFacebook:(id)sender;

@end

@implementation MJPUserSettingsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back.png"] landscapeImagePhone:[UIImage imageNamed:@"Back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPushed)];
    
    self.appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [self setProfileUI:self.appDelegate.currentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProfileUI:(PFObject*) user {
    [self.userName setText:user[@"name"]];
    [self.userEmail setText:user[@"email"]];
    // TODO: Do stuff with number of friends, etc.
    if (self.appDelegate.currentUser[@"profilePicture"]) {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *profilePicture = [UIImage imageWithData:[self.appDelegate.currentUser[@"profilePicture"] getData]];
            dispatch_async( dispatch_get_main_queue(), ^{
                [self.profilePicture setImage:profilePicture forState:UIControlStateNormal];
                [self.profilePicture setImage:profilePicture forState:UIControlStateSelected];
            });
        });
    }
    [MJPPhotoUtils circularCrop:self.profilePicture.imageView];
    // Handle Facebook sharing name.
    [self facebookSharingUI:[FBSession activeSession]];
    [self.navigationItem setTitle:@"Profile"];
}

- (IBAction)changeProfilePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *croppedImage = [MJPPhotoUtils croppedImageWithInfo:info];
        NSData *imageData = UIImageJPEGRepresentation(croppedImage, 0.7);
        PFFile *userPhoto = [PFFile fileWithData:imageData];
        PFObject *userPhotoObject = [self.appDelegate currentUser];
        userPhotoObject[@"profilePicture"] = userPhoto;
        [userPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.appDelegate setCurrentUser:userPhotoObject];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.profilePicture.imageView setImage:[UIImage imageWithData:[[userPhotoObject objectForKey:@"profilePicture"] getData]]];
                    [MJPPhotoUtils circularCrop:self.profilePicture.imageView];
                });
            } else {
                // TODO: Display better errors.
            }
        }];
        
    } else {
        // TODO: Display an error in the case the user entered something other than an image.
        NSLog(@"ERROR");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)backButtonPushed {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)logout:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"email"];
    [userDefaults removeObjectForKey:@"password"];
    [userDefaults removeObjectForKey:@"user_id"];
    [userDefaults synchronize];
    [self loginRedirect];
}

- (IBAction)changePassword:(id)sender {
    MJPChangePasswordViewController *changePassword = [[MJPChangePasswordViewController alloc] init];
    [self.navigationController pushViewController:changePassword animated:YES];
}

- (IBAction)viewPostHistory:(id)sender {
    PFQuery *streamItemQuery = [MJPQueryUtils getStreamItemsForUser:self.appDelegate.currentUser];
    [streamItemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        MJPPostHistoryTableViewController *postHistory = [[MJPPostHistoryTableViewController alloc] initWithPosts:objects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:postHistory animated:YES];
        });
    }];
}

- (void)loginRedirect {
    MJPLoginViewController *loginViewController = [[MJPLoginViewController alloc] init];
    self.appDelegate.window.rootViewController = loginViewController;
}
- (IBAction)shareWithFacebook:(id)sender {
    // Open a session showing the user the login UI
    // You must ALWAYS ask for public_profile permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
        [self facebookSharingUI:session];
    }];
    
    // TODO: Add functionality to remove Facebook sharing.
}

- (void) facebookSharingUI:(FBSession*)session {
    if (session.state == FBSessionStateOpen) {
        [self fetchFacebookUserName];
    } else if (session.state == FBSessionStateCreatedTokenLoaded) {
        // This is the state on app launch with cached access token.
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (session.state == FBSessionStateOpen) {
                [self fetchFacebookUserName];
            }
        }];
    } else {
        // Doesn't seem to be logged in. Do nothing.
    }
}

- (void)fetchFacebookUserName {
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
         if (!error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.facebookSharing setTitle:user.name forState:UIControlStateNormal];
             });
         } else {
             NSLog(@"Error: unable to fetch user profile.");
             // TODO: Handle the error in this case.
         }
     }];
}
@end
