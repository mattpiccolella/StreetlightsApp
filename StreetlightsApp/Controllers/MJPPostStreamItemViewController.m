//  MJPPostStreamItemViewController.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPPostStreamItemViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "MJPAppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MJPPhotoUtils.h"
#import "MJPViewUtils.h"
#import "MJPAssortedUtils.h"

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
@property (strong, nonatomic) PFFile *postPicture;
@property (strong, nonatomic) UIImageView *postImageView;

@property BOOL facebookSelected;
@property BOOL twitterSelected;

@end

@implementation MJPPostStreamItemViewController {
    BOOL hasSetLocation_;
    BOOL hasPickedPhoto;
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });

    [MJPViewUtils setNavigationUI:self withTitle:@"POST" backButtonName:@"Back.png"];
    [self.navigationItem.leftBarButtonItem setAction:@selector(backButtonPushed)];
    
    self.postDescription.text = @"What's up?";
    self.postDescription.textColor = [UIColor lightGrayColor];
    
    [self handleTwitterPress];
    [self handleFacebookPress];
    
    hasPickedPhoto = FALSE;
}

- (void)dealloc {
    [self.mapView removeObserver:self forKeyPath:@"myLocation" context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
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

    [self setParseStreamItem:[self newStreamItem]];
    NSLog(@"%@", self.parseStreamItem[@"postPicture"]);
    [self.parseStreamItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            self.appDelegate.shouldRefreshStreamItems = TRUE;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.postDescription.text = @"";
                [self.activityIndicator setHidden:YES];
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
            [MJPViewUtils genericErrorMessage:self];
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"What's up?"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
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
        [self handleFacebookPress];
    } else if (session.state == FBSessionStateCreatedTokenLoaded) {
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (session.state == FBSessionStateOpen) {
                [self handleFacebookPress];
            }
        }];
    }
}

- (IBAction)twitterPressed:(id)sender {
    // TODO: Get an active session before we do this.
    [self handleTwitterPress];
}

- (IBAction)addPhoto:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take a Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takePhotoSelected];
    }];
    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"Choose from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self photoLibrarySelected];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Dismiss view controller.
    }];
    [alertController addAction:takePhotoAction];
    [alertController addAction:photoLibraryAction];
    if (hasPickedPhoto) {
        UIAlertAction *removePhotoAction = [UIAlertAction actionWithTitle:@"Remove Photo" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self removePhoto];
        }];
        [alertController addAction:removePhotoAction];
    }
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)takePhotoSelected {
    UIImagePickerController *imagePicker = [MJPAssortedUtils getCameraImagePicker];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)photoLibrarySelected {
    UIImagePickerController *imagePicker = [MJPAssortedUtils getLibraryImagePicker];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)removePhoto {
    self.postPicture = nil;
    [self.postImageView setHidden:YES];
    [self.mapView setHidden:NO];
    hasPickedPhoto = FALSE;
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *croppedImage = [MJPPhotoUtils croppedImageWithInfo:info];
        NSData *imageData = UIImageJPEGRepresentation(croppedImage, 0.7);
        PFFile *postPhoto = [PFFile fileWithData:imageData];
        self.postPicture = postPhoto;
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, screenBounds.size.width, 154)];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setImage:croppedImage];
        [self setPostImageView:imageView];
        [self.view addSubview:imageView];
        [self.mapView setHidden:TRUE];
        hasPickedPhoto = TRUE;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleFacebookPress {
    if (self.facebookSelected) {
        [self.shareFacebook setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.facebookSelected = FALSE;
    } else {
        [self.shareFacebook setTitleColor:[MJPViewUtils appColor] forState:UIControlStateNormal];
        self.facebookSelected = TRUE;
    }
}

- (void)handleTwitterPress {
    if (self.twitterSelected) {
        [self.shareTwitter setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.twitterSelected = FALSE;
    } else {
        [self.shareTwitter setTitleColor:[MJPViewUtils appColor] forState:UIControlStateNormal];
        self.twitterSelected = TRUE;
    }
}

- (void)getFacebookPermissionsAndPost {
    [FBRequestConnection startWithGraphPath:@"/me/permissions" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
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
                [self requestPermissionsAndPost];
            } else {
                [self postEvent];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MJPViewUtils incorrectPermissionsErrorView:self];
            });
        }
    }];
}

- (void)postEvent {
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
        } else {
            NSLog(@"Error posting the Open Graph object to the Object API: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MJPViewUtils facebookShareError:self];
            });
        }
    }];
}

- (PFObject*)newStreamItem {
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
    
    PFObject *parseStreamItem = [PFObject objectWithClassName:@"StreamItem"];
    [parseStreamItem setObject:[self.appDelegate currentUser] forKey:@"user"];
    [parseStreamItem setObject:[[self.appDelegate currentUser] objectId] forKey:@"userId"];
    [parseStreamItem setObject:self.postDescription.text forKey:@"description"];
    [parseStreamItem setObject:[NSNumber numberWithLong:[NSDate timeIntervalSinceReferenceDate]] forKey:@"postedTimestamp"];
    [parseStreamItem setObject:[NSNumber numberWithLong:([NSDate timeIntervalSinceReferenceDate] + expirationOffset)] forKey:@"expiredTimestamp"];
    [parseStreamItem setObject:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    [parseStreamItem setObject:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
    [parseStreamItem setObject:[[NSMutableArray alloc] init] forKey:@"favoriteIds"];
    [parseStreamItem setObject:[NSNumber numberWithInteger:shareCount] forKey:@"shareCount"];
    if (self.postPicture) {
        [parseStreamItem setObject:self.postPicture forKey:@"postPicture"];
    }
    return parseStreamItem;
}

- (void)requestPermissionsAndPost {
    // Permission hasn't been granted, so ask for publish_actions
    [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
        if (!error) {
            if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
                NSLog(@"No permission.");
                // TODO: Think of what to do here. Just let it go I think.
            } else {
                [self postEvent];
            }
        } else {
            NSLog(@"Error requesting permission");
            dispatch_async(dispatch_get_main_queue(), ^{
                [MJPViewUtils incorrectPermissionsErrorView:self];
            });
        }
    }];
}
@end
