//
//  MJPUserProfileViewController.m
//  StreetlightsApp
//
//  Created by Matt on 8/20/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPUserProfileViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface MJPUserProfileViewController ()
- (IBAction)logoutButton:(id)sender;

@end

@implementation MJPUserProfileViewController

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

- (IBAction)logoutButton:(id)sender {
    [FBSession.activeSession close];
}
@end
