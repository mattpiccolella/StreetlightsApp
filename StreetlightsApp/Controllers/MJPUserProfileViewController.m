//  MJPUserProfileViewController.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPAppDelegate.h"
#import "MJPUserProfileViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MJPLoginViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MJPConstants.h"
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
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MJPUserProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back.png"] landscapeImagePhone:[UIImage imageNamed:@"Back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPushed)];
    
    if ([self.appDelegate hasUserCredentials]) {
        if ([self.appDelegate currentUser] != nil) {
            [self setProfileUI:[self.appDelegate currentUser]];
        } else {
            // TODO: Parse should retrieve this otherwise. But, we should have it.
        }
    } else {
        [self loginRedirect];
    }
}

- (void)setProfileUI:(PFObject*) user {
    [self.navigationItem setTitle:[NSString stringWithFormat:@"User Profile"]];
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    [self.userName setText:user[@"name"]];
    [self.userFirstName setTitle:user[@"name"]];
    // TODO: Do stuff with number of friends, etc.
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *profilePicture = [UIImage imageWithData:[self.appDelegate.currentUser[@"profilePicture"] getData]];
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.userImage.imageView setImage:profilePicture];
            self.userImage.imageView.layer.cornerRadius = self.userImage.imageView.frame.size.width / 2;
            self.userImage.imageView.clipsToBounds = YES;
            [self.activityIndicator setHidden:YES];
        });
    });
}

- (void)didReceiveMemoryWarning {
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
        PFFile *userPhoto = [PFFile fileWithData:imageData];
        PFObject *userPhotoObject = [self.appDelegate currentUser];
        userPhotoObject[@"profilePicture"] = userPhoto;
        [userPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.appDelegate setCurrentUser:userPhotoObject];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator setHidden:YES];
                    [self.userImage.imageView setImage:[UIImage imageWithData:[[userPhotoObject objectForKey:@"profilePicture"] getData]]];
                    self.userImage.imageView.layer.cornerRadius = self.userImage.imageView.frame.size.width / 2;
                    self.userImage.imageView.clipsToBounds = YES;
                });
            } else {
                // TODO: Display better errors.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator setHidden:YES];
                });
            }
        }];
        
    } else {
        // TODO: Display an error in the case the user entered something other than an image.
        NSLog(@"ERROR");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
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

-(void)backButtonPushed {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
