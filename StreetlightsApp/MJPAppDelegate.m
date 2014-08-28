//
//  MJPAppDelegate.m
//  StreetlightsApp
//
//  Created by Matt on 8/19/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPAppDelegate.h"
#import "Controllers/MJPLoginViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FacebookSDK/FacebookSDK.h>

static NSString *const kAPIKey = @"AIzaSyA0kdLnccEvocgHk8pYiegU4l0EhDyZBI0";

@implementation MJPAppDelegate {
    id services_;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.searchEveryone = FALSE;
    self.searchRadius = 4.0;
    
    self.everyoneArray = [[NSMutableArray alloc] init];
    self.friendArray = [[NSMutableArray alloc] init];
    
    if ([kAPIKey length] == 0) {
        // Blow up if APIKey has not yet been set.
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        NSString *format = @"Configure APIKey inside SDKDemoAPIKey.h for your "
        @"bundle `%@`, see README.GoogleMapsSDKDemos for more information";
        @throw [NSException exceptionWithName:@"SDKDemoAppDelegate"
                                       reason:[NSString stringWithFormat:format, bundleId]
                                     userInfo:nil];
    }
    [GMSServices provideAPIKey:kAPIKey];
    services_ = [GMSServices sharedServices];
    
    // Whenever a person opens the app, check for user credentials.
    if ([self hasUserCredentials]) {
        [self loggedInView];
        return YES;
    } else {
        [self loggedOutView];
        return YES;
    }
}

- (void)loggedInView {
    // Open a default tab bar controller
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:1.0]];
    tabBarController.viewControllers = [MJPLoginViewController getTabBarViewControllers];
    
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    return;
}

- (void)loggedOutView {
    MJPLoginViewController *loginViewController = [[MJPLoginViewController alloc] init];
    self.window.rootViewController = loginViewController;
    [self.window makeKeyAndVisible];
}

- (BOOL)hasUserCredentials {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"email"] != nil && [userDefaults objectForKey:@"password"] != nil && [userDefaults objectForKey:@"user_id"] != nil;
}
         
- (id)currentUserId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"user_id"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
