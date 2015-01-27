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
#import "MJPStreamItemTableViewCell.h"
#import "MJPAssortedUtils.h"

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
    appDelegate.window.rootViewController = navController;
}

+ (void)genericErrorMessage:(UIViewController*)viewController {
    [[[UIAlertView alloc] initWithTitle:@"Passwords don't match"
                                message:@"Sorry, but those passwords don't match. Please make sure they match."
                               delegate:viewController
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

+ (UIView*)blankViewWithMessage:(NSString*)message andBounds:(CGRect)bounds {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, bounds.size.width, bounds.size.height)];
    messageLabel.text = message;
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont fontWithName:@"Avenir" size:20];
    [messageLabel sizeToFit];
    return messageLabel;
}

+ (void)setUIForStreamItem:(PFObject*)streamItem user:(PFObject*)user tableCell:(MJPStreamItemTableViewCell*)cell {
    cell.userName.text = user[@"name"];
    cell.postInfo.text = streamItem[@"description"];
    
    cell.favorites.text = [NSString stringWithFormat:@"%lu", (unsigned long)(streamItem[@"favoriteIds"] ? [streamItem[@"favoriteIds"] count] : 0)];
    // TODO: Fix once we actually share.
    cell.shares.text = [NSString stringWithFormat:@"0"];
    
    // Set the date of amount of time remaining.
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[streamItem[@"expiredTimestamp"] doubleValue]];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [expirationDate timeIntervalSinceDate:currentDate];
    cell.timeRemaining.text = [MJPAssortedUtils stringForRemainingTime:(int) timeInterval / 60];

    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *profilePicture = [UIImage imageWithData:[user[@"profilePicture"] getData]];
        dispatch_async( dispatch_get_main_queue(), ^{
            [cell.userImage setImage:profilePicture];
        });
    });
}

+ (void)facebookShareError:(UIViewController*)viewController {
    [[[UIAlertView alloc] initWithTitle:@"Facebook event not posted"
                                message:@"Sorry, but your event could not be posted on Facebook. Please try again."
                               delegate:viewController
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

+ (void)incorrectPermissionsErrorView:(UIViewController*)viewController {
    [[[UIAlertView alloc] initWithTitle:@"Incorrect Permissions"
                                message:@"We were unable to fetch the necessary permissions. Please try again."
                               delegate:viewController
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

+ (void)locationServicesErrorView:(UIViewController*)viewController {
    [[[UIAlertView alloc] initWithTitle:@"Unable to access location"
                                message:@"We were unable to get your current location. Please make sure your permissions are set correctly."
                               delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

+ (UIImage *)imageNavBarBackground {
    UIColor *color = [UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:0.8];
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}
@end
