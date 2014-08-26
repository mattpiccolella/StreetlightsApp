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
#import "MJPLoginViewController.h"

@interface MJPUserProfileViewController ()
- (IBAction)logoutButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UINavigationItem *userFirstName;
@property (strong, nonatomic) IBOutlet UILabel *numberOfFriends;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPosts;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
- (IBAction)editProfile:(id)sender;

@end

@implementation MJPUserProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.appDelegate hasUserCredentials]) {
        if ([self.appDelegate currentUser] != nil) {
            [self setProfileUI:[self.appDelegate currentUser]];
        } else {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://107.170.105.12/get_user/%@", [self.appDelegate currentUserId]]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            NSURLSessionDataTask *getUserTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                                                              NSURLResponse *response,
                                                                                                                              NSError *error) {
                if (!error) {
                    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                    if ([[response objectForKey:@"status"]  isEqual:@"success"]) {
                        MJPUser *user = [MJPUser getUserFromJSON:response];
                        //[user setUserId:[self.appDelegate currentUserId]];
                        [self.appDelegate setCurrentUser:user];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self setProfileUI:user];
                        });
                    }
                } else {
                    NSLog(@"Error: %@", error.localizedDescription);
                }
            }];
            [getUserTask resume];
        }
    } else {
        [self loginRedirect];
    }
}

- (void)setProfileUI:(MJPUser*) user {
    [self.userName setText:user.name];
    [self.userFirstName setTitle:user.name];
    // TODO: Do stuff with number of friends, etc.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loginRedirect {
    MJPLoginViewController *loginViewController = [[MJPLoginViewController alloc] init];
    self.appDelegate.window.rootViewController = loginViewController;
}

- (IBAction)logoutButton:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"email"];
    [userDefaults removeObjectForKey:@"password"];
    [userDefaults removeObjectForKey:@"user_id"];
    [userDefaults synchronize];
    NSLog(@"deleting!");
    [self loginRedirect];
}

- (IBAction)editProfile:(id)sender {
    // TODO: Present the edit view. Allow users to edit their profile.
}
@end
