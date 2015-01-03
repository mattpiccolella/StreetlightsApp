//  MJPPostStreamItemViewController.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPPostStreamItemViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "MJPAppDelegate.h"
#import "MJPStreamItem.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MJPPhotoUtils.h"

@interface MJPPostStreamItemViewController ()

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITextView *postDescription;
@property (strong, nonatomic) IBOutlet UIDatePicker *expirationTime;
- (IBAction)post:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *shareFacebook;
@property (strong, nonatomic) IBOutlet UIButton *shareTwitter;
- (IBAction)facebookPressed:(id)sender;
- (IBAction)twitterPressed:(id)sender;

- (IBAction)addPhoto:(id)sender;
@property (strong, nonatomic) PFObject *parseStreamItem;


@property BOOL facebookSelected;
@property BOOL twitterSelected;


@end

@implementation MJPPostStreamItemViewController {
    BOOL hasSetLocation_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // These get flipped to false when we set the UI.
        self.facebookSelected = TRUE;
        self.twitterSelected = TRUE;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicator setHidden:true];
    
    self.appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    self.parseStreamItem = [PFObject objectWithClassName:@"StreamItem"];
    
    // Why did I need this?
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
    
    if ([self.appDelegate currentUser] == nil) {
        // TODO: Look into this. I don't even think this is necessary.
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"X.png"] landscapeImagePhone:[UIImage imageNamed:@"X.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPushed)];
    
    self.postDescription.text = @"What's up?";
    self.postDescription.textColor = [UIColor lightGrayColor];
    
    [self handleTwitterPress];
    [self handleFacebookPress];
    
    [self.navigationItem setTitle:@"Post"];
}

- (void)dealloc {
    [self.mapView removeObserver:self forKeyPath:@"myLocation" context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"myLocation"] && !hasSetLocation_ &&
        [object isKindOfClass:[GMSMapView class]]) {
        hasSetLocation_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                             zoom:14];
    }
}

- (IBAction)post:(id)sender {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    CLLocation *currentLocation = [self.mapView myLocation];
    float latitude = (float) currentLocation.coordinate.latitude;
    float longitude = (float) currentLocation.coordinate.longitude;
    
    long expirationOffset = [self.expirationTime countDownDuration];
    
    NSInteger shareCount = 0;
    if (self.facebookSelected) {
        shareCount++;
    }
    if (self.twitterSelected) {
        shareCount++;
    }
    
    [self.parseStreamItem setObject:[self.appDelegate currentUser] forKey:@"user"];
    [self.parseStreamItem setObject:[[self.appDelegate currentUser] objectId] forKey:@"userId"];
    [self.parseStreamItem setObject:self.postDescription.text forKey:@"description"];
    [self.parseStreamItem setObject:[NSNumber numberWithLong:[NSDate timeIntervalSinceReferenceDate]] forKey:@"postedTimestamp"];
    [self.parseStreamItem setObject:[NSNumber numberWithLong:([NSDate timeIntervalSinceReferenceDate] + expirationOffset)] forKey:@"expiredTimestamp"];
    [self.parseStreamItem setObject:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    [self.parseStreamItem setObject:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
    [self.parseStreamItem setObject:[[NSMutableArray alloc] init] forKey:@"favoriteIds"];
    [self.parseStreamItem setObject:[NSNumber numberWithInteger:shareCount] forKey:@"shareCount"];
    [self.parseStreamItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            self.appDelegate.shouldRefreshStreamItems = TRUE;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.postDescription.text = @"";
                [self.activityIndicator setHidden:YES];
                // TODO: Work on making this transition more sensible.
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
            // TODO: Notify somebody of something. We can't save stream items.
        }
    }];
    
    if (self.facebookSelected) {
        [self getFacebookPermissionsAndPost];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)backButtonPushed {
    // TODO: Make this pop from the bottom.
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"What's up?"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"What's up?";
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}

- (IBAction)facebookPressed:(id)sender {
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      [self facebookSharingUI:session];
    }];
}

- (void) facebookSharingUI:(FBSession*)session {
    if (session.state == FBSessionStateOpen) {
        NSLog(@"Open connection.");
        [self handleFacebookPress];
    } else if (session.state == FBSessionStateCreatedTokenLoaded) {
        // This is the state on app launch with cached access token.
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (session.state == FBSessionStateOpen) {
                NSLog(@"Open connection.");
                [self handleFacebookPress];
            }
        }];
    } else {
        // Doesn't seem to be logged in. Do nothing.
    }
}

- (IBAction)twitterPressed:(id)sender {
    // TODO: Get an active session before we do this.
    [self handleTwitterPress];
}

- (IBAction)addPhoto:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    
    imagePicker.allowsEditing = YES;
    
    // TODO: Make the panning on a cropped image possible.
    
    [self presentViewController:imagePicker animated:YES completion:nil];

}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *croppedImage = [MJPPhotoUtils croppedImageWithInfo:info];
        NSData *imageData = UIImageJPEGRepresentation(croppedImage, 0.7);
        PFFile *postPhoto = [PFFile fileWithData:imageData];
        self.parseStreamItem[@"postPicture"] = postPhoto;
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, screenBounds.size.width, 154)];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setImage:croppedImage];
        [self.view addSubview:imageView];
        [self.mapView setHidden:TRUE];
    } else {
        // TODO: Display an error in the case the user entered something other than an image.
        NSLog(@"ERROR");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleFacebookPress {
    if (self.facebookSelected) {
        [self.shareFacebook setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.facebookSelected = FALSE;
    } else {
        [self.shareFacebook setTitleColor:[UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.facebookSelected = TRUE;
    }
}

- (void)handleTwitterPress {
    if (self.twitterSelected) {
        [self.shareTwitter setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.twitterSelected = FALSE;
    } else {
        [self.shareTwitter setTitleColor:[UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.twitterSelected = TRUE;
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
                                                                  [self postEvent];
                                                              }
                                                          } else {
                                                              NSLog(@"Error requesting permission");
                                                              // TODO: Handle this better.
                                                          }
                                                      }];
                
            } else {
                // Already have the permissions we need.
                [self postEvent];
            }
        } else {
            // TODO: Handle the error in fetching permissions.
            NSLog(@"Error fetching permissions");
        }
    }];
}

- (void) postEvent {
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
    object.provisionedForPost = YES;
    object[@"type"] = @"streetlightsapp:event";
    
    object[@"title"] = @"Around";
    object[@"description"] = self.postDescription.text;
    
    // Post custom object
    [FBRequestConnection startForPostOpenGraphObject:object completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // get the object ID for the Open Graph object that is now stored in the Object API
            NSString *objectId = [result objectForKey:@"id"];
            NSLog(@"Story posted: %@", objectId);
            // create an Open Graph action
            id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
            [action setObject:objectId forKey:@"event"];
            /*
            // create action referencing user owned object
            [FBRequestConnection startForPostWithGraphPath:@"/me/streetlightsapp:post" graphObject:action completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(!error) {
                    NSLog(@"Story posted: %@", [result objectForKey:@"id"]);
                } else {
                    // An error occurred
                    NSLog(@"Encountered an error posting to Open Graph: %@", error);
                }
            }];
             */
        } else {
            // An error occurred
            NSLog(@"Error posting the Open Graph object to the Object API: %@", error);
        }
    }];
}
@end
