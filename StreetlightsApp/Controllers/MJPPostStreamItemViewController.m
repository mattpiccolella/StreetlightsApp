//
//  MJPPostStreamItemViewController.m
//  StreetlightsApp
//
//  Created by Matt on 8/20/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

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
    
    [self.activityIndicator setHidden:true];
    
    self.appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
    
    if ([self.appDelegate currentUser] == nil) {
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
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }];
        [getUserTask resume];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.activityIndicator startAnimating];
    CLLocation *currentLocation = [self.mapView myLocation];
    float latitude = (float) currentLocation.coordinate.latitude;
    float longitude = (float) currentLocation.coordinate.longitude;
    
    // TODO: Fix the search radius to a non-fixed value.
    NSString *postString = [NSString stringWithFormat:@"userid=%@&description=%@&latitude=%f&longitude=%f&expiration=%d",
                            [self.appDelegate currentUserId], self.postDescription.text,
                            latitude, longitude, 50];
    
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];

    [self.activityIndicator startAnimating];
    NSURL *url = [NSURL URLWithString:@"http://107.170.105.12/create_new_post"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = data;
    // Create a task.
    NSURLSessionDataTask *newPostTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                                                                                      NSURLResponse *response,
                                                                                                                      NSError *error) {
        if (!error) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if ([[response objectForKey:@"status"]  isEqual:@"success"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.postDescription.text = @"";
                    [self.activityIndicator setHidden:YES];
                });
            } else {
                // TODO: Do something if we don't succeed.
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    [newPostTask resume];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
