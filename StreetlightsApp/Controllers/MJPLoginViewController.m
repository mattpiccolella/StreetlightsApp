//
//  MJPLoginViewController.m
//  Around
//
//  Created by Matt on 1/3/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPLoginViewController.h"
#import "MJPQueryUtils.h"
#import "MJPMapViewController.h"
#import "MJPAppDelegate.h"
#import "MJPViewUtils.h"

@interface MJPLoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)loginButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)emailFieldChanged:(id)sender;
- (IBAction)passwordFieldChanged:(id)sender;

@end

@implementation MJPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.emailField setDelegate:self];
    [self.passwordField setDelegate:self];
    
    [self.loginButton setEnabled:FALSE];
    
    [self.activityIndicator setHidden:TRUE];
    
    [MJPViewUtils setNavigationUI:self withTitle:@"Login" backButtonName:@"X.png"];
    [self.navigationItem.leftBarButtonItem setAction:@selector(backButtonPushed)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)loginButtonPressed:(id)sender {
    PFQuery *checkUser = [MJPQueryUtils getUserQueryForEmail:[self.emailField text] password:[self.passwordField text]];
    [checkUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            MJPAppDelegate *appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:object.objectId forKey:@"userId"];
            [appDelegate setCurrentUser:object];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator setHidden:YES];
                [MJPViewUtils presentMapView:appDelegate];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self incorrectLoginView];
            });
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)enableLoginButton {
    BOOL enabled = (([[self.emailField text] length] != 0) && ([[self.passwordField text] length] != 0));
    [self.loginButton setEnabled:enabled];
}

- (void)backButtonPushed {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)emailFieldChanged:(id)sender {
    [self enableLoginButton];
}

- (IBAction)passwordFieldChanged:(id)sender {
    [self enableLoginButton];
}

- (void)incorrectLoginView {
    [[[UIAlertView alloc] initWithTitle:@"Invalid Login"
                                message:@"Sorry, but this is not a valid login."
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}
@end
