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
    
    MJPStreamViewController *streamViewController = [[MJPStreamViewController alloc] init];
    streamViewController.tabBarItem.title = @"Stream";
    streamViewController.tabBarItem.image = [UIImage imageNamed:@"StreamIcon.png"];
    
    MJPPostStreamItemViewController *postStreamItemViewController = [[MJPPostStreamItemViewController alloc] init];
    postStreamItemViewController.tabBarItem.title = @"Post";
    postStreamItemViewController.tabBarItem.image = [UIImage imageNamed:@"Pinpoint.png"];
    
    MJPNotificationsViewController *notificationsController = [[MJPNotificationsViewController alloc] init];
    notificationsController.tabBarItem.title = @"Noti's";
    notificationsController.tabBarItem.image = [UIImage imageNamed:@"NotificationIcon.png"];
    
    MJPUserProfileViewController *userProfileController = [[MJPUserProfileViewController alloc] init];
    userProfileController.tabBarItem.title = @"Profile";
    userProfileController.tabBarItem.image = [UIImage imageNamed:@"ProfileIcon.png"];
    
    
    return @[mapViewController, streamViewController, postStreamItemViewController, notificationsController, userProfileController];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)registerButtonPressed:(id)sender {
    MJPUser *newUser = [[MJPUser alloc] initWithName:self.nameField.text email:self.emailField.text password:self.passwordField.text];
    NSData *jsonData = [MJPUser getJSONFromUser:newUser];
    [self.activityIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"http://107.170.105.12/create_new_user"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = jsonData;
    // Create a task.
    NSURLSessionDataTask *newUserTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                                               NSURLResponse *response,
                                                                                                               NSError *error) {
        if (!error) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if ([[response objectForKey:@"status"]  isEqual:@"success"]) {
                [newUser setUserId:[[response objectForKey:@"user_id"] intValue]];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:[newUser email] forKey:@"email"];
                [userDefaults setObject:[newUser password] forKey:@"password"];
                [userDefaults setValue:[NSNumber numberWithInteger:[newUser userId]] forKey:@"user_id"];
                MJPAppDelegate *appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate setCurrentUser:newUser];
                [self.activityIndicator setHidden:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UITabBarController *tabBarController = [[UITabBarController alloc] init];
                    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:1.0]];
                    
                    tabBarController.viewControllers = [MJPLoginViewController getTabBarViewControllers];
                    
                    [UIApplication sharedApplication].delegate.window.rootViewController = tabBarController;
                });
                NSLog(@"User: %@ %@ %@", [userDefaults objectForKey:@"email"], [userDefaults objectForKey:@"password"], [userDefaults objectForKey:@"user_id"]);
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    [newUserTask resume];
    
}
@end
