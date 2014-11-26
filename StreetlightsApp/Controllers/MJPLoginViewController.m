//
//  MJPLoginViewController.m
//  StreetlightsApp
//
//  Created by Matt on 8/19/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPLoginViewController.h"
#import "MJPAppDelegate.h"
#import "MJPStreamViewController.h"
#import "MJPMapViewController.h"
#import "MJPUserProfileViewController.h"
#import "MJPNotificationsViewController.h"
#import "MJPPostStreamItemViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MJPUser.h"
#import <Parse/Parse.h>

@interface MJPLoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
- (IBAction)registerButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MJPLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.activityIndicator setHidden:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (NSArray *)getTabBarViewControllers {
    MJPMapViewController *mapViewController = [[MJPMapViewController alloc] init];
    mapViewController.tabBarItem.title = @"Map";
    mapViewController.tabBarItem.image = [UIImage imageNamed:@"MapIcon.png"];
    UINavigationController *mapNavController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    [mapNavController setNavigationBarHidden:YES];
    
    MJPStreamViewController *streamViewController = [[MJPStreamViewController alloc] init];
    streamViewController.tabBarItem.title = @"Stream";
    streamViewController.tabBarItem.image = [UIImage imageNamed:@"StreamIcon.png"];
    UINavigationController *streamNavController = [[UINavigationController alloc] initWithRootViewController:streamViewController];
    [streamNavController setNavigationBarHidden:YES];
    
    MJPPostStreamItemViewController *postStreamItemViewController = [[MJPPostStreamItemViewController alloc] init];
    postStreamItemViewController.tabBarItem.title = @"Post";
    postStreamItemViewController.tabBarItem.image = [UIImage imageNamed:@"Pinpoint.png"];
    
    MJPNotificationsViewController *notificationsController = [[MJPNotificationsViewController alloc] init];
    notificationsController.tabBarItem.title = @"Noti's";
    notificationsController.tabBarItem.image = [UIImage imageNamed:@"NotificationIcon.png"];
    
    MJPUserProfileViewController *userProfileController = [[MJPUserProfileViewController alloc] init];
    userProfileController.tabBarItem.title = @"Profile";
    userProfileController.tabBarItem.image = [UIImage imageNamed:@"ProfileIcon.png"];
    
    
    return @[mapViewController, streamNavController, postStreamItemViewController, notificationsController, userProfileController];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)registerButtonPressed:(id)sender {
    MJPUser *newUser = [[MJPUser alloc] initWithName:self.nameField.text email:self.emailField.text password:self.passwordField.text];
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"email" equalTo:newUser.email];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] != 0) {
            NSLog(@"Email already taken");
            // TODO: Do better error handling.
        } else {
            PFObject *parseUser = [MJPUser getPFObjectFromUser:newUser];
            [parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self.activityIndicator setHidden:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UITabBarController *tabBarController = [[UITabBarController alloc] init];
                        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:1.0]];
                        
                        tabBarController.viewControllers = [MJPLoginViewController getTabBarViewControllers];
                        
                        [UIApplication sharedApplication].delegate.window.rootViewController = tabBarController;
                    });
                    MJPUser *newUser = [[MJPUser alloc] initWithName:self.nameField.text email:self.emailField.text password:self.passwordField.text];
                    PFQuery *query = [PFQuery queryWithClassName:@"User"];
                    [query whereKey:@"email" equalTo:newUser.email];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:object.objectId forKey:@"userId"];
                        MJPAppDelegate *appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
                        [appDelegate setCurrentUser:object];
                    }];
                    NSLog(@"We created our object.");
                }
            }];
        }
    }];
}
@end
