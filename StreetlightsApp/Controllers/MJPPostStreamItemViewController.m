//  MJPPostStreamItemViewController.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPPostStreamItemViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "MJPAppDelegate.h"
#import "MJPStreamItem.h"

@interface MJPPostStreamItemViewController ()

@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@property (strong, nonatomic) IBOutlet UITextView *postDescription;
@property (strong, nonatomic) IBOutlet UIDatePicker *expirationTime;
- (IBAction)post:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MJPPostStreamItemViewController {
    BOOL hasSetLocation_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    // Why did I need this?
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
    
    if ([self.appDelegate currentUser] == nil) {
        // TODO: Look into this. I don't even think this is necessary.
    }
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
    
    PFObject *parseStreamItem = [PFObject objectWithClassName:@"StreamItem"];
    [parseStreamItem setObject:[self.appDelegate currentUser] forKey:@"user"];
    [parseStreamItem setObject:self.postDescription.text forKey:@"description"];
    [parseStreamItem setObject:[NSNumber numberWithLong:[NSDate timeIntervalSinceReferenceDate]] forKey:@"postedTimestamp"];
    [parseStreamItem setObject:[NSNumber numberWithLong:([NSDate timeIntervalSinceReferenceDate] + expirationOffset)] forKey:@"expiredTimestamp"];
    [parseStreamItem setObject:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    [parseStreamItem setObject:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
    
    [parseStreamItem saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.postDescription.text = @"";
                [self.activityIndicator setHidden:YES];
            });
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
            // TODO: Notify somebody of something. We can't save stream items.
        }
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
