//
//  MJPViewUtils.m
//  Around
//
//  Created by Matt on 1/13/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPViewUtils.h"
#import "MJPMapViewController.h"
#import "MJPAppDelegate.h"

@implementation MJPViewUtils

+ (void)setNavigationUI:(UIViewController*)viewController withTitle:(NSString*)title backButtonName:(NSString*)name {
    [viewController.navigationController setNavigationBarHidden:NO];
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:name] landscapeImagePhone:[UIImage imageNamed:name] style:UIBarButtonItemStyleDone target:viewController action:nil];
    
    NSDictionary *settings = @{
                               NSFontAttributeName                :  [UIFont fontWithName:@"PathwayGothicOne-Book" size:30.0],
                               NSForegroundColorAttributeName          :  [UIColor whiteColor]};
    
    [viewController.navigationController.navigationBar setTitleTextAttributes:settings];
    [viewController.navigationItem setTitle:title];
}

+ (UIColor*)appColor {
    return [UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:0.2];
}

+ (void)presentMapView:(MJPAppDelegate*)appDelegate {
    MJPMapViewController *mapViewController = [[MJPMapViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    navController.navigationBar.barTintColor = [MJPViewUtils appColor];
    appDelegate.window.rootViewController = navController;
}
@end
