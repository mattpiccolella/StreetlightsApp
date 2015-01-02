//
//  MJPChangePasswordViewController.m
//  Around
//
//  Created by Matt on 1/2/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPChangePasswordViewController.h"
#import "MJPAppDelegate.h"

@interface MJPChangePasswordViewController ()
@property (strong, nonatomic) IBOutlet UITextField *oldPassword;
@property (strong, nonatomic) IBOutlet UITextField *pickedPassword;
@property (strong, nonatomic) IBOutlet UITextField *pickedPasswordConfirm;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;

- (IBAction)changePassword:(id)sender;

@end

@implementation MJPChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back.png"] landscapeImagePhone:[UIImage imageNamed:@"Back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPushed)];
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Change Password"]];
    
    self.appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changePassword:(id)sender {
    if ([self.oldPassword.text isEqualToString:self.appDelegate.currentUser[@"password"]]) {
        if ([self.pickedPassword.text isEqualToString:self.pickedPasswordConfirm.text]) {
            [self.appDelegate.currentUser setObject:self.pickedPassword.text forKey:@"password"];
            // TODO: Show progress indicator.
            [self.appDelegate.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                } else {
                    // TODO: Display better errors.
                }
            }];
        } else {
            // TODO: Present that new passwords don't match.
        }
    } else {
        // TODO: Present that old password is wrong.
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)backButtonPushed {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
