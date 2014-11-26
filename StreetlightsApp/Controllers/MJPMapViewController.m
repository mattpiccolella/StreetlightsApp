//
//  MJPMapViewController.m
//  StreetlightsApp
//
//  Created by Matt on 8/19/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPMapViewController.h"
#import "MJPAppDelegate.h"
#import "MJPStreamItem.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>

@interface MJPMapViewController ()
@property (strong, nonatomic) IBOutlet UISegmentedControl *scopeSelector;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)distanceChanged:(id)sender;
- (IBAction)sliderChangeEnded:(id)sender;
- (IBAction)scopeChanged:(id)sender;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@end


@implementation MJPMapViewController {
    BOOL hasSetLocation_;
    BOOL hasLoadedInitialMarkers_;
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
    
    self.appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.8075
                                                            longitude:-73.9619
                                                                 zoom:12];
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    self.mapView.camera = camera;
    
    [self.mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.scopeSelector setSelectedSegmentIndex:[self.appDelegate searchEveryone]];

    self.distanceSlider.value = [((MJPAppDelegate *)[UIApplication sharedApplication].delegate) searchRadius];
    NSString *newLabel = [NSString stringWithFormat:@"%1.1f mi away", self.distanceSlider.value];
    [self.distanceLabel setText:newLabel];

}

- (void)dealloc {
    [self.mapView removeObserver:self forKeyPath:@"myLocation" context:NULL];
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

- (IBAction)distanceChanged:(id)sender {
    // Set the label to reflect the change
    NSString *newLabel = [NSString stringWithFormat:@"%1.1f mi away", self.distanceSlider.value];
    [self.distanceLabel setText:newLabel];
}

- (IBAction)sliderChangeEnded:(id)sender {
    [self.appDelegate setSearchRadius:self.distanceSlider.value];
    [self.activityIndicator startAnimating];
    [self fetchNewStreamItems];
}

- (IBAction)scopeChanged:(id)sender {
    [self.appDelegate setSearchEveryone:self.scopeSelector.selectedSegmentIndex];
    
    [self addMarkers];
}

- (void) addMarkers {
    [self.mapView clear];
    // TODO: Add custom markers.
    if (self.scopeSelector.selectedSegmentIndex) {
        for (MJPStreamItem *streamItem in self.appDelegate.friendArray) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.title = streamItem.user.name;
            marker.snippet = streamItem.postDescription;
            marker.position = CLLocationCoordinate2DMake([streamItem latitude], [streamItem longitude]);
            marker.map = self.mapView;
        }
    } else {
        for (MJPStreamItem *streamItem in self.appDelegate.everyoneArray) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.title = streamItem.user.name;
            marker.snippet = streamItem.description;
            marker.position = CLLocationCoordinate2DMake([streamItem latitude], [streamItem longitude]);
            marker.map = self.mapView;
        }
    }
}

- (void)fetchNewStreamItems {
    NSString *formattedString = [NSString stringWithFormat:@"http://107.170.105.12/get_posts/%f/%f/%f",
                                 self.currentLocation.coordinate.longitude, self.currentLocation.coordinate.latitude,
                                 self.distanceSlider.value];
    NSURL *url = [NSURL URLWithString:formattedString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // Create a task.
    NSURLSessionDataTask *newPostTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            [self.appDelegate.everyoneArray removeAllObjects];
            [self.appDelegate.friendArray removeAllObjects];
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if ([[response objectForKey:@"status"]  isEqual:@"success"]) {
                for (NSDictionary *streamItem in [response objectForKey:@"results"]) {
                    NSString *userName = [[streamItem objectForKey:@"user"] objectForKey:@"name"];
                    MJPUser *user = [[MJPUser alloc] initWithName:userName email:nil password:nil];
                    NSString *description = [streamItem objectForKey:@"description"];
                    MJPStreamItem *newStreamItem = [[MJPStreamItem alloc] initWithUser:user description:description postedTimestamp:0 expiredTimestamp:0 friend:NO latitude:[[streamItem objectForKey:@"latitude"] floatValue] longitude:[[streamItem objectForKey:@"longitude"] floatValue]];
                    [self.appDelegate.everyoneArray addObject:newStreamItem];
                    if ([newStreamItem isFriend]) {
                        [self.appDelegate.friendArray addObject:newStreamItem];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator setHidden:YES];
                    [self addMarkers];
                });
            } else {
                NSLog(@"%@", [response objectForKey:@"status"]);
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    [newPostTask resume];
}

- (void)loadInitialMarkers {
    // Bad hack. We try to load only based off of whether there are any objects available.
    if ([self.appDelegate.everyoneArray count] == 0) {
        [self fetchNewStreamItems];
    } else {
        [self.activityIndicator setHidden:YES];
        [self addMarkers];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // TODO: Try to fail gracefully.
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // TODO: Fix this hack. We get location, load the items for that location, then stop updating it.
    if (hasLoadedInitialMarkers_ == NO) {
        self.currentLocation = newLocation;
        hasLoadedInitialMarkers_ = YES;
        [self loadInitialMarkers];
        [self.locationManager stopUpdatingLocation];
    }
}

@end
