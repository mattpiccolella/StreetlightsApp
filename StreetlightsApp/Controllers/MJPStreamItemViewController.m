//  MJPStreamItemViewController.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPStreamItemViewController.h"
#import "MJPStreamItem.h"
#import "MJPUser.h"
#import <GoogleMaps/GoogleMaps.h>
#import "MJPAppDelegate.h"
#import "MJPPhotoUtils.h"
#import <CoreLocation/CoreLocation.h>
#import "MJPAssortedUtils.h"

@interface MJPStreamItemViewController ()
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *postDescription;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *timePosted;
@property (strong, nonatomic) IBOutlet UILabel *timeRemaining;

@property (strong, nonatomic) PFObject *streamItem;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *favorites;
@property (strong, nonatomic) IBOutlet UILabel *shares;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UIButton *trashButton;
- (IBAction)deleteStreamItem:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *favoriteButton;
- (IBAction)favoritePost:(id)sender;
- (IBAction)sharePost:(id)sender;



@end

@implementation MJPStreamItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithStreamItem:(PFObject *)streamItem location:(CLLocation*)location {
    self = [super init];
    if (self) {
        self.streamItem = streamItem;
        self.currentLocation = location;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Set the fields for the current stream item.
    self.userName.text = self.streamItem[@"user"][@"name"];
    self.postDescription.text = self.streamItem[@"description"];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *profilePicture = [UIImage imageWithData:[self.streamItem[@"user"][@"profilePicture"] getData]];
        if (self.streamItem[@"user"][@"profilePicture"]) {
            dispatch_async( dispatch_get_main_queue(), ^{
                [self.profilePicture setImage:profilePicture];
                [MJPPhotoUtils circularCrop:self.profilePicture];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.profilePicture setImage:[UIImage imageNamed:@"images.jpeg"]];
                [MJPPhotoUtils circularCrop:self.profilePicture];
            });
        }
        if (self.streamItem[@"postPicture"]) {
            UIImage *postPicture = [UIImage imageWithData:[self.streamItem[@"postPicture"] getData]];
            dispatch_async( dispatch_get_main_queue(), ^{
                CGRect screenBounds = [[UIScreen mainScreen] bounds];
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, screenBounds.size.width, 256)];
                [imageView setContentMode:UIViewContentModeScaleAspectFit];
                [imageView setImage:postPicture];
                [self.view addSubview:imageView];
                [self.mapView setHidden:TRUE];
            });
        }
    });
    
    // Get the dates
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[self.streamItem[@"postedTimestamp"] doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    self.timePosted.text = [dateFormatter stringFromDate:date];
    
    double pointLatitude = [self.streamItem[@"latitude"] floatValue];
    double pointLongitude = [self.streamItem[@"longitude"] floatValue];
    
    // Add a marker for the location of the point.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(pointLatitude, pointLongitude);
    marker.map = self.mapView;
    
    // Move the map to the location of the marker
    GMSCameraUpdate *update = [GMSCameraUpdate setTarget:marker.position zoom:14.0];
    [self.mapView moveCamera:update];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back.png"] landscapeImagePhone:[UIImage imageNamed:@"Back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPushed)];
    
    self.shares.text = [NSString stringWithFormat:@"%ld", (long)[[self.streamItem objectForKey:@"shareCount"] integerValue]];
    
    // Set the date of amount of time remaining.
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[self.streamItem[@"expiredTimestamp"] doubleValue]];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [expirationDate timeIntervalSinceDate:currentDate];
    self.timeRemaining.text = [MJPAssortedUtils stringForRemainingTime:(timeInterval / 60)];
    
    self.distanceLabel.text = [NSString stringWithFormat:@"%.02f mi", [self distanceFromLatitude:pointLatitude longitude:pointLongitude]];
    
    [self handleDeletion];
    [self setFavoriteUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonPushed {
    [self.navigationController popViewControllerAnimated:YES];
}

// Find the distance between our current location and the point in question.
- (double)distanceFromLatitude:(double)latitude longitude:(double)longitude {
    double currentLatitude = self.currentLocation.coordinate.latitude;
    double currentLongitude = self.currentLocation.coordinate.longitude;
    
    CLLocation *postLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:currentLatitude longitude:currentLongitude];
    
    double METERS_TO_MILES = 0.000621371;

    // Find the distance between the two points.
    return [postLocation distanceFromLocation:currentLocation] * METERS_TO_MILES;
}

- (void)handleDeletion {
    if (![self.appDelegate.currentUser.objectId isEqualToString:[self.streamItem[@"user"] objectId]]) {
        [self.trashButton setHidden:YES];
    }
}
- (IBAction)deleteStreamItem:(id)sender {
    [self.streamItem deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            self.appDelegate.shouldRefreshStreamItems = TRUE;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            // TODO: Handle this error.
        }
    }];
}
- (IBAction)favoritePost:(id)sender {
    if (!self.streamItem[@"favoriteIds"]) {
        [self.streamItem setObject:[[NSMutableArray alloc] init] forKey:@"favoriteIds"];
    }
    if (![self.streamItem[@"favoriteIds"] containsObject:self.appDelegate.currentUser.objectId]) {
        // This user hasn't favorited the post, favorite it.
        [self.streamItem[@"favoriteIds"] addObject:[self.appDelegate.currentUser objectId]];
    } else {
        // This user has favorited the post, un-favorite it.
        [self.streamItem[@"favoriteIds"] removeObject:[self.appDelegate.currentUser objectId]];
    }
    [self setFavoriteUI];
    [self.streamItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            // TODO: Handle this error.
        }
    }];
}

- (IBAction)sharePost:(id)sender {
    NSLog(@"HELLO");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *facebookAction = [UIAlertAction actionWithTitle:@"Facebook" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self shareToFacebook];
    }];
    UIAlertAction *twitterAction = [UIAlertAction actionWithTitle:@"Twitter" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // TODO: Implement this.
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Dismiss view controller.
    }];
    [alertController addAction:facebookAction];
    [alertController addAction:twitterAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"The %@ button was tapped.", [actionSheet buttonTitleAtIndex:buttonIndex]);
}


- (void)setFavoriteUI {
    if (self.streamItem[@"favoriteIds"]) {
        if ([self.streamItem[@"favoriteIds"] containsObject:self.appDelegate.currentUser.objectId]) {
            [self.favoriteButton setImage:[UIImage imageNamed:@"GoldStar.png"] forState:UIControlStateNormal];
        } else {
            [self.favoriteButton setImage:[UIImage imageNamed:@"Star.png"] forState:UIControlStateNormal];
        }
        self.favorites.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.streamItem[@"favoriteIds"] count]];
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"Star.png"] forState:UIControlStateNormal];
        self.favorites.text = [NSString stringWithFormat:@"0"];
    }
}

- (void) shareToFacebook {
    // Create activity indicator.
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.activityIndicator.center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    // Check for publish permissions
    if ([FBSession activeSession].state == FBSessionStateOpen) {
        [self getFacebookPermissionsAndPost];
    } else if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (session.state == FBSessionStateOpen) {
                [self getFacebookPermissionsAndPost];
            }
        }];
    }
}

- (void)getFacebookPermissionsAndPost {
    [FBRequestConnection startWithGraphPath:@"/me/permissions" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Walk the list of permissions looking to see if publish_actions has been granted
            NSArray *permissions = (NSArray *)[result data];
            BOOL publishActionsSet = FALSE;
            for (NSDictionary *perm in permissions) {
                if ([[perm objectForKey:@"permission"] isEqualToString:@"publish_actions"] &&
                    [[perm objectForKey:@"status"] isEqualToString:@"granted"]) {
                    publishActionsSet = TRUE;
                    break;
                }
            }
            if (!publishActionsSet) {
                // Permission hasn't been granted, so ask for publish_actions
                [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                      defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
                                                          if (!error) {
                                                              if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
                                                                  NSLog(@"No permission.");
                                                                  // TODO: Think of what to do here. Just let it go I think.
                                                              } else {
                                                                  // Permission granted.
                                                                  [self postFacebookEvent];
                                                              }
                                                          } else {
                                                              NSLog(@"Error requesting permission");
                                                              // TODO: Handle this better.
                                                          }
                                                      }];
            } else {
                // Already have the permissions we need.
                [self postFacebookEvent];
            }
        } else {
            // TODO: Handle the error in fetching permissions.
            NSLog(@"Error fetching permissions");
        }
    }];
}

- (void)postFacebookEvent {
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
    object.provisionedForPost = YES;
    object[@"type"] = @"streetlightsapp:event";
    
    object[@"title"] = @"Around";
    object[@"description"] = [self.streamItem objectForKey:@"description"];
    
    // Post custom object
    [FBRequestConnection startForPostOpenGraphObject:object completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // get the object ID for the Open Graph object that is now stored in the Object API
            NSString *objectId = [result objectForKey:@"id"];
            // create an Open Graph action
            id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
            [action setObject:objectId forKey:@"event"];
            // create action referencing user owned object
            [FBRequestConnection startForPostWithGraphPath:@"/me/streetlightsapp:share" graphObject:action completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(!error) {
                    NSLog(@"Story share: %@", [result objectForKey:@"id"]);
                    [[[UIAlertView alloc] initWithTitle:@"Your event has been shared!"
                                                message:@"Check your Facebook profile or activity log to see it."
                                               delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                    [self incrementStreamItemShares];
                } else {
                    // TODO: Post a message about the error.
                    NSLog(@"Encountered an error posting to Open Graph: %@", error);
                    [self.activityIndicator stopAnimating];
                }
            }];
        } else {
            // TODO: Post a message about the error.
            NSLog(@"Error posting the Open Graph object to the Object API: %@", error);
            [self.activityIndicator stopAnimating];
        }
    }];
}

- (void)incrementStreamItemShares {
    NSInteger shareCount = [[self.streamItem objectForKey:@"shareCount"] integerValue];
    shareCount++;
    [self.streamItem setObject:[NSNumber numberWithInteger:shareCount] forKey:@"shareCount"];
    [self.streamItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.shares.text = [NSString stringWithFormat:@"%ld", (long)[[self.streamItem objectForKey:@"shareCount"] integerValue]];
                [self.activityIndicator stopAnimating];
            });
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
            // TODO: Notify somebody of something. We can't save stream items.
        }
    }];
}
@end
