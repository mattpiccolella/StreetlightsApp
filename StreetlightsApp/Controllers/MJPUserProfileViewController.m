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
                [self setProfileUI:user];
            } else {
                NSLog(@"ERROR");
            }
        }];
    }
}

- (void)setProfileUI:(NSDictionary<FBGraphUser>*) user {
    [self.userName setText:user.name];
    [self.userFirstName setTitle:user.first_name];
    NSString *userImageURL = [self profilePictureString:[user objectID]];
    UIImage *userImage = [UIImage imageWithData:
                          [NSData dataWithContentsOfURL:
                           [NSURL URLWithString: userImageURL]]];
    [self.profilePicture setImage:userImage];
    
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
