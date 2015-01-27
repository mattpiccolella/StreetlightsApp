//
//  MJPViewUtils.h
//  Around
//
//  Created by Matt on 1/13/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPAppDelegate.h"
#import "MJPStreamItemTableViewCell.h"

@interface MJPViewUtils : NSObject

+ (void)setNavigationUI:(UIViewController*)viewController withTitle:(NSString*)title backButtonName:(NSString*)name;
+ (UIColor*)appColor;
+ (void)presentMapView:(MJPAppDelegate*)appDelegate;
+ (void)genericErrorMessage:(UIViewController*)viewController;
+ (UIView*)blankViewWithMessage:(NSString*)message andBounds:(CGRect)bounds;
+ (void)setUIForStreamItem:(PFObject*)streamItem user:(PFObject*)user tableCell:(MJPStreamItemTableViewCell*)cell;
+ (void)facebookShareError:(UIViewController*)viewController;
+ (void)incorrectPermissionsErrorView:(UIViewController*)viewController;
+ (void)locationServicesErrorView:(UIViewController*)viewController;
+ (UIImage *)imageNavBarBackground;
+ (NSDictionary *)fontSettings;

@end
