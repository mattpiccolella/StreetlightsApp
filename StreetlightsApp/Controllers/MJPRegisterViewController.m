//  MJPLoginViewController.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPRegisterViewController.h"
#import "MJPAppDelegate.h"
#import "MJPStreamViewController.h"
#import "MJPMapViewController.h"
#import "MJPPostStreamItemViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "MJPPhotoUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MJPAssortedUtils.h"
#import "MJPViewUtils.h"

@interface MJPRegisterViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
- (IBAction)registerButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *profilePictureSelector;

@end

@implementation MJPRegisterViewController

BOOL hasSelectedPhoto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicator setHidden:TRUE];
    
    [MJPViewUtils setNavigationUI:self withTitle:@"Register" backButtonName:@"X.png"];
    [self.navigationItem.leftBarButtonItem setAction:@selector(backButtonPushed)];
    
    hasSelectedPhoto = false;
    
    [MJPPhotoUtils circularCrop:self.profilePictureSelector.imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)registerButtonPressed:(id)sender {
    if (![self.passwordField.text isEqualToString:self.confirmPasswordField.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Passwords don't match"
                                        message:@"Sorry, but those passwords don't match. Please make sure they match."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        
    } else {
        PFQuery *query = [PFQuery queryWithClassName:@"User"];
        [query whereKey:@"email" equalTo:self.emailField.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count] != 0) {
                NSLog(@"Email already taken");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Email Already Taken"
                                                message:@"Sorry, but this email is in use. Please login."
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                });
            } else {
                PFObject *parseUser = [MJPAssortedUtils getPFObjectWithName:self.nameField.text email:self.emailField.text password:self.passwordField.text];
                if (hasSelectedPhoto) {
                    NSData *imageData = UIImageJPEGRepresentation([self.profilePictureSelector.imageView image], 0.7);
                    PFFile *userPhoto = [PFFile fileWithData:imageData];
                    parseUser[@"profilePicture"] = userPhoto;
                }
                [self.activityIndicator setHidden:NO];
                [self.activityIndicator startAnimating];
                [parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [self.activityIndicator setHidden:YES];
                        MJPAppDelegate *appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activityIndicator setHidden:YES];
                            [MJPViewUtils presentMapView:appDelegate];
                        });
                        PFQuery *query = [PFQuery queryWithClassName:@"User"];
                        [query whereKey:@"email" equalTo:self.emailField.text];
                        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                            [userDefaults setObject:object.objectId forKey:@"userId"];
                            MJPAppDelegate *appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
                            [appDelegate setCurrentUser:object];
                        }];
                    } else {
                        NSLog(@"ERROR! We couldn't register the user! Present a confirmation.");
                    }
                }];
            }
        }];
    }
}

- (void)backButtonPushed {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)nameChanged:(id)sender {
    [self enableRegisterButton];
}
- (IBAction)passwordChanged:(id)sender {
    [self enableRegisterButton];
}

- (IBAction)emailChanged:(id)sender {
    [self enableRegisterButton];
}

- (void)enableRegisterButton {
    BOOL enabled = ([self isValidEmail:[self.emailField text]] && ([[self.nameField text] length] != 0) && ([[self.passwordField text] length] != 0));
    [self.registerButton setEnabled:enabled];
}

-(BOOL) isValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
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
    if (hasSelectedPhoto) {
        UIAlertAction *removePhotoAction = [UIAlertAction actionWithTitle:@"Remove Photo" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self removePhoto];
        }];
        [alertController addAction:removePhotoAction];
    }
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *croppedImage = [MJPPhotoUtils croppedImageWithInfo:info];
        [self.profilePictureSelector setImage:croppedImage forState:UIControlStateNormal];
        [self.profilePictureSelector setImage:croppedImage forState:UIControlStateSelected];
        [MJPPhotoUtils circularCrop:self.profilePictureSelector.imageView];
        hasSelectedPhoto = TRUE;
    } else {
        // TODO: Display an error in the case the user entered something other than an image.
        NSLog(@"ERROR");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)takePhotoSelected {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)photoLibrarySelected {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)removePhoto {
    [self.profilePictureSelector setImage:[UIImage imageNamed:@"images.jpeg"] forState:UIControlStateNormal];
    [self.profilePictureSelector setImage:[UIImage imageNamed:@"images.jpeg"] forState:UIControlStateSelected];
    hasSelectedPhoto = FALSE;
}
@end
