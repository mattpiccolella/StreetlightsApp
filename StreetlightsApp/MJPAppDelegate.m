//  MJPAppDelegate.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPAppDelegate.h"
#import "Controllers/MJPLoginViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "MJPMapViewController.h"

static NSString *const kAPIKey = @"AIzaSyA0kdLnccEvocgHk8pYiegU4l0EhDyZBI0";

@implementation MJPAppDelegate {
    id services_;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Parse setApplicationId:@"p5AXszvVReZoSxb9O6I82VGv9yESwzkO9JZ0I2rA"
                  clientKey:@"cKrKEYY3JngYz3ELhmnbyfL59x6BN8iOgi4pyyKo"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.searchRadius = 4.0;
    
    self.streamItemArray = [[NSArray alloc] init];
    
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
        PFQuery *query = [PFQuery queryWithClassName:@"User"];
        [query getObjectInBackgroundWithId:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] block:^(PFObject *object, NSError *error) {
            [self setCurrentUser:object];
        }];
        [self loggedInView];
        return YES;
    } else {
        [self loggedOutView];
        return YES;
    }
    
    // Whenever a person opens the app, check for a cached Facebook session for sharing.
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // TODO: Maybe do something here?
        }];
    }
    
    self.shouldRefreshStreamItems = FALSE;
}

- (void)loggedInView {
    
    MJPMapViewController *mapViewController = [[MJPMapViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mapViewController];

    navController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:0.2];
    
    self.window.rootViewController = navController;
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
    return [userDefaults objectForKey:@"userId"] != nil;
}
         
- (id)currentUserId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"userId"];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
        if([[call appLinkData] targetURL] != nil) {
            // get the object ID string from the deep link URL
            // we use the substringFromIndex so that we can delete the leading '/' from the targetURL
            NSString *objectId = [[[call appLinkData] targetURL].path substringFromIndex:1];
            
            // now handle the deep link
            // write whatever code you need to show a view controller that displays the object, etc.
            [[[UIAlertView alloc] initWithTitle:@"Directed from Facebook"
                                        message:[NSString stringWithFormat:@"Deep link to %@", objectId]
                                       delegate:self
                              cancelButtonTitle:@"OK!"
                              otherButtonTitles:nil] show];
        } else {
            //
            NSLog(@"Unhandled link: %@", [[call appLinkData] targetURL]);
        }
    }];
    
    return wasHandled;
}
@end
