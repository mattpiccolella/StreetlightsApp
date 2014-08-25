//
//  MJPUserProfileViewController.m
//  StreetlightsApp
//
//  Created by Matt on 8/20/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPAppDelegate.h"
#import "MJPUserProfileViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface MJPUserProfileViewController ()
- (IBAction)logoutButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UINavigationItem *userFirstName;

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
    
    MJPAppDelegate* appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.currentUser != NULL) {
        [self setProfileUI:appDelegate.currentUser];
    } else {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            if (!error) {
                MJPUser *newUser = [[MJPUser alloc] initWithName:user.name email:[user objectForKey:@"email"] password:@""];
                [appDelegate setCurrentUser:newUser];
                [self setProfileUI:newUser];
            } else {
                NSLog(@"ERROR");
            }
        }];
    }
}

- (void)setProfileUI:(MJPUser*) user {
    [self.userName setText:user.name];
    [self.userFirstName setTitle:user.name];
}

- (NSString*)profilePictureString:(NSString*) objectID {
    return [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small", objectID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutButton:(id)sender {
    [FBSession.activeSession closeAndClearTokenInformation];
}
@end
