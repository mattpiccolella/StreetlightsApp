//  MJPMapViewController.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPMapViewController.h"
#import "MJPAppDelegate.h"
#import "MJPStreamItem.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import "MJPQueryUtils.h"
#import "MJPStreamViewController.h"
#import "MJPUserProfileViewController.h"

@interface MJPMapViewController ()
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)distanceChanged:(id)sender;
- (IBAction)sliderChangeEnded:(id)sender;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@end


@implementation MJPMapViewController {
    BOOL hasSetLocation_;
    BOOL hasLoadedInitialMarkers_;
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
    
    self.appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonPushed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Prof" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonPushed)];

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
    
    [self.view addSubview:[self addPostButton]];
}

- (void)viewWillAppear:(BOOL)animated {
    self.distanceSlider.value = [((MJPAppDelegate *)[UIApplication sharedApplication].delegate) searchRadius];
    NSString *newLabel = [NSString stringWithFormat:@"%1.1f mi away", self.distanceSlider.value];
    [self.distanceLabel setText:newLabel];
}

- (void)dealloc {
    [self.mapView removeObserver:self forKeyPath:@"myLocation" context:NULL];
}

- (void)didReceiveMemoryWarning {
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

- (void) addMarkers {
    [self.mapView clear];
    // TODO: Add custom markers.
    for (PFObject *streamItem in self.appDelegate.streamItemArray) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.title = streamItem[@"user"][@"name"];
        marker.snippet = streamItem[@"description"];
        marker.position = CLLocationCoordinate2DMake([streamItem[@"latitude"] floatValue], [streamItem[@"longitude"] floatValue]);
        marker.map = self.mapView;
    }
}

- (void)fetchNewStreamItems {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    float longitude = self.currentLocation.coordinate.longitude;
    float latitude = self.currentLocation.coordinate.latitude;
    float radius = self.distanceSlider.value;
    PFQuery *streamItemQuery = [MJPQueryUtils getStreamItemsForLatitude:latitude longitude:longitude radius:radius];
    [streamItemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.appDelegate setStreamItemArray:objects];
        [self addMarkers];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator setHidden:YES];
        });
    }];
}

- (void)loadInitialMarkers {
    // Bad hack. We try to load only based off of whether there are any objects available.
    if ([self.appDelegate.streamItemArray count] == 0) {
        [self fetchNewStreamItems];
        [self.activityIndicator setHidden:YES];
    } else {
        [self.activityIndicator setHidden:YES];
        [self addMarkers];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // TODO: Try to fail gracefully.
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // TODO: Fix this hack. We get location, load the items for that location, then stop updating it.
    if (hasLoadedInitialMarkers_ == NO) {
        self.currentLocation = newLocation;
        hasLoadedInitialMarkers_ = YES;
        [self loadInitialMarkers];
        [self.locationManager stopUpdatingLocation];
    }
}

- (UIButton*)addPostButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(postButtonPushed)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Post" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    return button;
}



- (void)leftButtonPushed {
    MJPStreamViewController *streamViewController = [[MJPStreamViewController alloc] init];
    
    UINavigationController *navController = (UINavigationController*) self.appDelegate.window.rootViewController;
    
    [navController pushViewController:streamViewController animated:FALSE];
}

- (void)rightButtonPushed {
    MJPUserProfileViewController *profileView = [[MJPUserProfileViewController alloc] init];
    
    UINavigationController *navController = (UINavigationController*) [self.appDelegate.window rootViewController];
    
    [navController pushViewController:profileView animated:YES];
}

- (void)postButtonPushed {
    // TODO: Navigation controller. Show post view. Pop up from bottom with X on post screen.
}


@end
