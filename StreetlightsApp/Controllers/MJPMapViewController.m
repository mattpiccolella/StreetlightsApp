//  MJPMapViewController.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPMapViewController.h"
#import "MJPAppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import "MJPQueryUtils.h"
#import "MJPStreamViewController.h"
#import "MJPPostStreamItemViewController.h"
#import "MJPStreamItemWindow.h"
#import "MJPStreamItemViewController.h"
#import "MJPUserSettingsTableViewController.h"
#import "MJPPhotoUtils.h"
#import "MJPViewUtils.h"
#import "MJPAssortedUtils.h"

@interface MJPMapViewController ()
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@end


@implementation MJPMapViewController {
    BOOL hasSetLocation_;
    BOOL hasLoadedInitialMarkers_;
    BOOL postSelected_;
    BOOL hasTappedMarker_;
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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"StreamIcon.png"] landscapeImagePhone:[UIImage imageNamed:@"StreamIcon.png"] style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonPushed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Profile.png"] landscapeImagePhone:[UIImage imageNamed:@"Profile.png"] style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonPushed)];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[MJPViewUtils fontSettings]];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[MJPViewUtils imageNavBarBackground] forBarMetrics:UIBarMetricsDefault];
    [self.navigationItem setTitle:@"AROUND"];
    
    self.navigationController.navigationBar.barTintColor = [MJPViewUtils appColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.8075
                                                            longitude:-73.9619
                                                                 zoom:12];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView setMyLocationEnabled:YES];
    });
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    self.mapView.camera = camera;
    
    self.mapView.delegate = self;
    
    [self updateLocation:self.mapView];
    
    [self.view addSubview:[self addPostButton]];
    [self.view addSubview:[self addCurrentLocationButton]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    if (self.appDelegate.shouldRefreshStreamItems) {
        [self fetchNewStreamItems];
        self.appDelegate.shouldRefreshStreamItems = FALSE;
    }
    
    if (!postSelected_) {
        [self addMarkers];
    } else {
        postSelected_ = FALSE;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.mapView removeObserver:self forKeyPath:@"myLocation" context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"myLocation"] && !hasSetLocation_ && [object isKindOfClass:[GMSMapView class]]) {
        hasSetLocation_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:14];
    }
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
        marker.userData = streamItem;
        marker.icon = [UIImage imageNamed:@"Marker.png"];
    }
}

- (void)fetchNewStreamItems {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    PFQuery *streamItemQuery = [MJPQueryUtils getStreamItemsForMinPoint:self.appDelegate.minPoint maxPoint:self.appDelegate.maxPoint];
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
        [self.activityIndicator setHidden:YES];
    } else {
        [self.activityIndicator setHidden:YES];
        [self addMarkers];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [MJPViewUtils locationServicesErrorView:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // TODO: Fix this hack. We get location, load the items for that location, then stop updating it.
    if (hasLoadedInitialMarkers_ == NO) {
        self.currentLocation = newLocation;
        hasLoadedInitialMarkers_ = YES;
        [self loadInitialMarkers];
    }
    self.currentLocation = newLocation;
}

- (UIImageView*)addPostButton {
    // TODO: Work on making this less hard-coded. Think of proportions.
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100.0, 475.0, 120.0, 120.0)];
    [imageView setImage:[UIImage imageNamed:@"Add.png"]];
    [imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *postTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postButtonPushed)];
    [postTap setNumberOfTapsRequired:1];
    [imageView addGestureRecognizer:postTap];
    return imageView;
}

- (UIImageView*)addCurrentLocationButton {
    // TODO: Work on making this less hard-coded. Think of proportions.
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(220.0, 510.0, 120.0, 120.0)];
    [imageView setImage:[UIImage imageNamed:@"CurrentLocation.png"]];
    [imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *postTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(currentLocationButtonPushed)];
    [postTap setNumberOfTapsRequired:1];
    [imageView addGestureRecognizer:postTap];
    return imageView;
}

- (void)leftButtonPushed {
    MJPStreamViewController *streamViewController = [[MJPStreamViewController alloc] init];
    
    postSelected_ = TRUE;
    
    UINavigationController *navController = (UINavigationController*) self.appDelegate.window.rootViewController;
    
    [navController pushViewController:streamViewController animated:FALSE];
}

- (void)rightButtonPushed {
    UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"MJPSettings" bundle:nil];
    MJPUserSettingsTableViewController *settingsViewController = [settingsStoryboard instantiateInitialViewController];
    
    UINavigationController *navController = (UINavigationController*) [self.appDelegate.window rootViewController];
    
    [navController pushViewController:settingsViewController animated:YES];
}

- (void)postButtonPushed {
    MJPPostStreamItemViewController *newPost = [[MJPPostStreamItemViewController alloc] init];
    [[self navigationController] pushViewController:newPost animated:YES];
}

- (void)currentLocationButtonPushed {
    [self.mapView animateToLocation:self.currentLocation.coordinate];
}

- (UIView*)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    MJPStreamItemWindow *customWindow = [[[NSBundle mainBundle] loadNibNamed:@"MJPStreamItemWindow" owner:self options:nil] objectAtIndex:0];
    customWindow.layer.cornerRadius = 5.0;
    customWindow.layer.masksToBounds = YES;
    customWindow.streamItemDescription.text = marker.snippet;
    customWindow.posterName.text = marker.title;
    PFObject *streamItem = marker.userData;
    double pointLatitude = [streamItem[@"latitude"] floatValue];
    double pointLongitude = [streamItem[@"longitude"] floatValue];
    double distance = [MJPAssortedUtils distanceFromLatitude:pointLatitude longitude:pointLongitude currentLocation:mapView.myLocation.coordinate];
    customWindow.distanceAway.text = [NSString stringWithFormat:@"%.02f mi", distance];
    
    NSDate *postedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[streamItem[@"postedTimestamp"] doubleValue]];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:postedDate];
    customWindow.timePosted.text = [MJPAssortedUtils stringForRemainingTime:(int) timeInterval / 60];
    
    // TODO: Work on setting user images.
    
    return customWindow;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    postSelected_ = TRUE;
    PFObject *selectedStreamItem = marker.userData;
    MJPStreamItemViewController *dummyItem = [[MJPStreamItemViewController alloc] initWithStreamItem:selectedStreamItem location:self.currentLocation];
    [self.navigationController pushViewController:dummyItem animated:YES];
}

- (CLLocationCoordinate2D)minLocation {
    return self.mapView.projection.visibleRegion.farLeft;
}

- (CLLocationCoordinate2D)maxLocation {
    return self.mapView.projection.visibleRegion.nearRight;
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    if (!hasTappedMarker_) {
        [self updateLocation:mapView];
        [self fetchNewStreamItems];
    } else {
        hasTappedMarker_ = FALSE;
    }
}

- (void)updateLocation:(GMSMapView*)mapView {
    self.appDelegate.minPoint = mapView.projection.visibleRegion.farLeft;
    self.appDelegate.maxPoint = mapView.projection.visibleRegion.nearRight;
    [self fetchNewStreamItems];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    hasTappedMarker_ = TRUE;
    return NO;
}
@end
