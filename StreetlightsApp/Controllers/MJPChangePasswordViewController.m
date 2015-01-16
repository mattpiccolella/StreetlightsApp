//
//  MJPChangePasswordViewController.m
//  Around
//
//  Created by Matt on 1/2/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPChangePasswordViewController.h"
#import "MJPAppDelegate.h"
#import "MJPViewUtils.h"

@interface MJPChangePasswordViewController ()
@property (strong, nonatomic) IBOutlet UITextField *oldPassword;
@property (strong, nonatomic) IBOutlet UITextField *pickedPassword;
@property (strong, nonatomic) IBOutlet UITextField *pickedPasswordConfirm;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)changePassword:(id)sender;

@end

@implementation MJPChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator hidesWhenStopped];

    [MJPViewUtils setNavigationUI:self withTitle:@"Change Password" backButtonName:@"Back.png"];
    [self.navigationItem.leftBarButtonItem setAction:@selector(backButtonPushed)];
    
    self.appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)changePassword:(id)sender {
    if ([self.oldPassword.text isEqualToString:self.appDelegate.currentUser[@"password"]]) {
        if ([self.pickedPassword.text isEqualToString:self.pickedPasswordConfirm.text]) {
            [self.appDelegate.currentUser setObject:self.pickedPassword.text forKey:@"password"];
            [self.activityIndicator startAnimating];
            [self.appDelegate.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicator stopAnimating];
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                } else {
                    [MJPViewUtils genericErrorMessage:self];
                }
            }];
        } else {
            [self passwordsDontMatchView];
        }
    } else {
        [self unableToRegisterView];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)backButtonPushed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)passwordsDontMatchView {
    [[[UIAlertView alloc] initWithTitle:@"Passwords don't match"
                                message:@"Sorry, but those passwords don't match. Please make sure they match."
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    
}

- (void)unableToRegisterView {
    [[[UIAlertView alloc] initWithTitle:@"Incorrect password"
                                message:@"Sorry, but the password you entered is incorrect. Please try again."
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}
@end
