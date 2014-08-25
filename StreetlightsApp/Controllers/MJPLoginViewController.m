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

@interface MJPLoginViewController ()
- (IBAction)loginButton:(id)sender;

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
    if (FBSession.activeSession.state != FBSessionStateOpen
         && FBSession.activeSession.state != FBSessionStateOpenTokenExtended) {
        
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             MJPAppDelegate* appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
         }];
    }
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
@end
