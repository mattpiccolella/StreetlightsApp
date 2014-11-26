//
//  MJPAppDelegate.h
//  StreetlightsApp
//
//  Created by Matt on 8/19/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MJPUser.h"
#import <Parse/Parse.h>

@interface MJPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readwrite) BOOL searchEveryone;

@property (nonatomic, readwrite) float searchRadius;

@property (strong, nonatomic) NSMutableArray *everyoneArray;

@property (strong, nonatomic) NSMutableArray *friendArray;

@property (strong, nonatomic) PFObject *currentUser;

@property (strong, nonatomic) CLLocation *locationManager;

- (BOOL)hasUserCredentials;
- (id)currentUserId;

@end
