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
}

- (void)loggedInView {
    
    MJPMapViewController *mapViewController = [[MJPMapViewController alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mapViewController];

    navController.navigationBar.barTintColor = [UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:0.2];
    
    UISearchBar* searchBar = [self searchBar];
    searchBar.delegate = mapViewController;
    
    UIView *searchBarView = [self viewWithSearchBar:searchBar];
    
    navController.navigationBar.topItem.titleView = searchBarView;

    navController.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Prof" style:UIBarButtonItemStyleDone target:nil action:nil];
    
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

// Format the search bar that will be added for the initial screen.
- (UISearchBar*)searchBar {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float searchBarWidth = 0.6 * screenWidth;
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, searchBarWidth, 44.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [searchBar setBackgroundImage:[UIImage new]];
    [searchBar setTranslucent:YES];
    [searchBar setPlaceholder:@"Search & Filter"];
    return searchBar;
}

// Add a centered view that will
- (UIView*) viewWithSearchBar:(UISearchBar*)searchBar {
    float searchBarWidth = searchBar.bounds.size.width;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake((0.5 * screenWidth - (0.5 * searchBarWidth)), 0.0, searchBarWidth, 44.0)];
    searchBarView.autoresizingMask = 0;
    [searchBarView addSubview:searchBar];
    return searchBarView;
}

@end
