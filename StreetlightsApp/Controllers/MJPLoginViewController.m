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
- (IBAction)loginButton:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButton:(id)sender {
    MJPAppDelegate* appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
    if (FBSession.activeSession.state != FBSessionStateOpen
         && FBSession.activeSession.state != FBSessionStateOpenTokenExtended) {
        
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {

             [appDelegate sessionStateChanged:session state:state error:error];
             
             [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                    if (!error) {
                        MJPUser *newUser = [[MJPUser alloc] initWithFirstName:user.name fullName:user.first_name email:[user objectForKey:@"email"]];
                        [appDelegate setCurrentUser:newUser];
                        NSLog(@"%@", newUser);
                    } else {
                        NSLog(@"ERROR");
                    }
             }];
         }];
    }
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
        if (!error) {
            MJPUser *newUser = [[MJPUser alloc] initWithFirstName:user.name fullName:user.first_name email:[user objectForKey:@"email"]];
            [appDelegate setCurrentUser:newUser];
        } else {
            NSLog(@"ERROR");
        }
    }];
    
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:1.0]];

    tabBarController.viewControllers = [MJPLoginViewController getTabBarViewControllers];
    
    [UIApplication sharedApplication].delegate.window.rootViewController = tabBarController;
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
@end
