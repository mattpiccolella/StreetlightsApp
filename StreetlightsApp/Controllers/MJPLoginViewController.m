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
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:1.0]];
    
    // Create our views
    MJPMapViewController *mapViewController = [[MJPMapViewController alloc] init];
    mapViewController.tabBarItem.title = @"Map";
    mapViewController.tabBarItem.image = [UIImage imageNamed:@"MapIcon.png"];
    
    MJPStreamViewController *streamViewController = [[MJPStreamViewController alloc] init];
    streamViewController.tabBarItem.title = @"Stream";
    streamViewController.tabBarItem.image = [UIImage imageNamed:@"StreamIcon.png"];
    
    tabBarController.viewControllers = @[streamViewController, mapViewController];
    
    [UIApplication sharedApplication].delegate.window.rootViewController = tabBarController;
}

- (NSArray *)getTabBarViewControllers {
    MJPMapViewController *mapViewController = [[MJPMapViewController alloc] init];
    mapViewController.tabBarItem.title = @"Map";
    mapViewController.tabBarItem.image = [UIImage imageNamed:@"MapIcon.png"];
    
    MJPStreamViewController *streamViewController = [[MJPStreamViewController alloc] init];
    streamViewController.tabBarItem.title = @"Stream";
    streamViewController.tabBarItem.image = [UIImage imageNamed:@"StreamIcon.png"];
    
    MJPUserProfileViewController *userProfileController = [[MJPUserProfileViewController alloc] init];
    userProfileController.tabBarItem.title = @"Profile";
    
    
    return @[mapViewController, streamViewController];
}
@end
