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
    // Do any additional setup after loading the view from its nib.
    
    [self.emailField setDelegate:self];
    [self.passwordField setDelegate:self];
    
    [self.loginButton setEnabled:FALSE];
    
    [self.activityIndicator setHidden:TRUE];
    
    [MJPViewUtils setNavigationUI:self withTitle:@"Login" backButtonName:@"X.png"];
    [self.navigationItem.leftBarButtonItem setAction:@selector(backButtonPushed)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonPressed:(id)sender {
    PFQuery *checkUser = [MJPQueryUtils getUserQueryForEmail:[self.emailField text] password:[self.passwordField text]];
    [checkUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            // Valid! Sign in!
            MJPAppDelegate *appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:object.objectId forKey:@"userId"];
            [appDelegate setCurrentUser:object];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator setHidden:YES];
                MJPMapViewController *mapViewController = [[MJPMapViewController alloc] init];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
                navController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:0.2];
                appDelegate.window.rootViewController = navController;
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Invalid Login"
                                            message:@"Sorry, but this is not a valid login."
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
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
@end
