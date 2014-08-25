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
    
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {

        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            if (!error) {
                MJPUser *newUser = [[MJPUser alloc] initWithFirstName:user.name fullName:user.first_name email:[user objectForKey:@"email"]];
                self.currentUser = newUser;
                NSLog(@"%@", user);
            } else {
                NSLog(@"ERROR");
            }
        }];
        return YES;
    } else {
        MJPLoginViewController *loginViewController = [[MJPLoginViewController alloc] init];
        self.window.rootViewController = loginViewController;
        [self.window makeKeyAndVisible];
        return YES;
    }
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        [self loggedInView];
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
        NSLog(@"Session closed.");
        [self loggedOutView];
    }
    if (error) {
        NSLog(@"Error");
        // TODO: Make this more meaningful. Actually display error messages.
        NSString *alertText;
        NSString *alertTitle;
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            //[self showMessage:alertText withTitle:alertTitle];
        } else {
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
            } else {
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
            }
        }
        [FBSession.activeSession closeAndClearTokenInformation];
        [self loggedOutView];
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
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
