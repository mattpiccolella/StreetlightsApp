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
#import "MJPRegisterViewController.h"
#import "MJPChangePasswordViewController.h"
#import "MJPQueryUtils.h"
#import "MJPPostHistoryTableViewController.h"
#import "MJPViewUtils.h"
#import "MJPAssortedUtils.h"

@interface MJPUserSettingsTableViewController ()
@property (strong, nonatomic) IBOutlet UIButton *profilePicture;
- (IBAction)changeProfilePicture:(id)sender;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UILabel *userEmail;
- (IBAction)logout:(id)sender;
- (IBAction)changePassword:(id)sender;
- (IBAction)viewPostHistory:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *facebookSharing;
- (IBAction)shareWithFacebook:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *userName;
- (IBAction)editName:(id)sender;
@end

@implementation MJPUserSettingsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MJPViewUtils setNavigationUI:self withTitle:@"PROFILE" backButtonName:@"X.png"];
    [self.navigationItem.leftBarButtonItem setAction:@selector(backButtonPushed)];
    
    self.appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [self setProfileUI:self.appDelegate.currentUser];
    
    [self.userName setEnabled:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setProfileUI:(PFObject*) user {
    [self setName];
    [self.userEmail setText:user[@"email"]];
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
}

- (IBAction)changeProfilePicture:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take a Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takePhotoSelected];
    }];
    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"Choose from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self photoLibrarySelected];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Dismiss view controller.
    }];
    [alertController addAction:takePhotoAction];
    [alertController addAction:photoLibraryAction];
    if (self.appDelegate.currentUser[@"profilePicture"]) {
        UIAlertAction *removePhotoAction = [UIAlertAction actionWithTitle:@"Remove Photo" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self removePhoto];
        }];
        [alertController addAction:removePhotoAction];
    }
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)takePhotoSelected {
    UIImagePickerController *imagePicker = [MJPAssortedUtils getCameraImagePicker];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)photoLibrarySelected {
    UIImagePickerController *imagePicker = [MJPAssortedUtils getLibraryImagePicker];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)removePhoto {
    [self.appDelegate.currentUser removeObjectForKey:@"profilePicture"];
    [self.appDelegate.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.profilePicture setImage:[MJPAssortedUtils getDefaultUserImage] forState:UIControlStateNormal];
                [self.profilePicture setImage:[MJPAssortedUtils getDefaultUserImage] forState:UIControlStateSelected];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MJPViewUtils genericErrorMessage:self];
            });
        }
    }];
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
                    [self.profilePicture setImage:[UIImage imageWithData:[[userPhotoObject objectForKey:@"profilePicture"] getData]] forState:UIControlStateNormal];
                    [self.profilePicture setImage:[UIImage imageWithData:[[userPhotoObject objectForKey:@"profilePicture"] getData]] forState:UIControlStateSelected];
                    [MJPPhotoUtils circularCrop:self.profilePicture.imageView];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MJPViewUtils genericErrorMessage:self];
                });
            }
        }];
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
    [self.appDelegate setCurrentUser:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"userId"];
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
    [self.appDelegate loggedOutView];
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

- (IBAction)editName:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Edit Name"
                                          message:@"Change the way your name is displayed."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
         textField.text = self.userName.titleLabel.text;
     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    UIAlertAction *doneAction = [UIAlertAction
                               actionWithTitle:@"Done"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [self changeName:[alertController.textFields.firstObject text]];
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:doneAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setName {
    [self.userName setTitle:self.appDelegate.currentUser[@"name"] forState:UIControlStateNormal];
    [self.userName setTitle:self.appDelegate.currentUser[@"name"] forState:UIControlStateSelected];
}

- (void)changeName:(NSString*)name {
    [self.appDelegate.currentUser setObject:name forKey:@"name"];
    [self.appDelegate.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setName];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MJPViewUtils genericErrorMessage:self];
            });
        }
    }];
}
@end
