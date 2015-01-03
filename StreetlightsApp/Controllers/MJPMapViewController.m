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
#import "MJPPostStreamItemViewController.h"
#import "MJPStreamItemWindow.h"
#import "MJPStreamItemViewController.h"
#import "MJPUserSettingsTableViewController.h"
#import "MJPPhotoUtils.h"

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

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"StreamIcon.png"] landscapeImagePhone:[UIImage imageNamed:@"StreamIcon.png"] style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonPushed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Profile.png"] landscapeImagePhone:[UIImage imageNamed:@"Profile.png"] style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonPushed)];
    
    NSDictionary *settings = @{
                               NSFontAttributeName                :  [UIFont fontWithName:@"PathwayGothicOne-Book" size:30.0],
                               NSForegroundColorAttributeName          :  [UIColor whiteColor]};
    
    [self.navigationController.navigationBar setTitleTextAttributes:settings];
    [self.navigationItem setTitle:@"Around"];

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
    
    
    [self.view addSubview:[self addPostButton]];
    [self.view addSubview:[self addCurrentLocationButton]];
}

- (void)viewWillAppear:(BOOL)animated {
    self.distanceSlider.value = [((MJPAppDelegate *)[UIApplication sharedApplication].delegate) searchRadius];
    NSString *newLabel = [NSString stringWithFormat:@"%1.1f mi away", self.distanceSlider.value];
    [self.distanceLabel setText:newLabel];
    
    [self.mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated {
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
        marker.userData = streamItem;
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
    }
}

- (UIImageView*)addPostButton {
    // TODO: Work on making this less hard-coded. Think of proportions.
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(120.0, 425.0, 80.0, 92.0)];
    [imageView setImage:[UIImage imageNamed:@"Post.png"]];
    [imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *postTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postButtonPushed)];
    [postTap setNumberOfTapsRequired:1];
    [imageView addGestureRecognizer:postTap];
    return imageView;
}

- (UIImageView*)addCurrentLocationButton {
    // TODO: Work on making this less hard-coded. Think of proportions.
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(220.0, 450.0, 120.0, 120.0)];
    [imageView setImage:[UIImage imageNamed:@"CurrentLocation.png"]];
    [imageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *postTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(currentLocationButtonPushed)];
    [postTap setNumberOfTapsRequired:1];
    [imageView addGestureRecognizer:postTap];
    return imageView;
}

- (void)leftButtonPushed {
    MJPStreamViewController *streamViewController = [[MJPStreamViewController alloc] init];
    
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
    // TODO: Make the post transition from the bottom.
    [[self navigationController] pushViewController:newPost animated:YES];
}

- (void)currentLocationButtonPushed {
    [self.mapView animateToLocation:self.currentLocation.coordinate];
}

// Format the search bar that will be added for the initial screen.
- (UISearchBar*)searchBar {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float searchBarWidth = 0.6 * screenWidth;
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, searchBarWidth, 44.0)];
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [searchBar setBackgroundImage:[UIImage new]];
    [searchBar setTranslucent:YES];
    [searchBar setPlaceholder:@"Search & Filter"];
    return searchBar;
}

// Add a centered view that will
- (UIView*) viewWithSearchBar:(UISearchBar*)searchBar {
    float searchBarWidth = searchBar.bounds.size.width;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake((0.5 * screenWidth - (0.5 * searchBarWidth)), 0.0, searchBarWidth, 44.0)];
    searchBarView.autoresizingMask = 0;
    [searchBarView addSubview:searchBar];
    return searchBarView;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // TODO: Make the selectors appear.
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    // TODO: Make the selectors disappear.
}

- (UIView*)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    MJPStreamItemWindow *customWindow = [[[NSBundle mainBundle] loadNibNamed:@"MJPStreamItemWindow" owner:self options:nil] objectAtIndex:0];
    customWindow.layer.cornerRadius = 5.0;
    customWindow.layer.masksToBounds = YES;
    customWindow.streamItemDescription.text = marker.snippet;
    customWindow.posterName.text = marker.title;
    PFObject *streamItem = marker.userData;
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *profilePicture = [UIImage imageWithData:[streamItem[@"user"][@"profilePicture"] getData]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [customWindow.posterImage setImage:profilePicture];
            [MJPPhotoUtils circularCrop:customWindow.posterImage];
        });
    });
    return customWindow;
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    PFObject *selectedStreamItem = marker.userData;
    MJPStreamItemViewController *dummyItem = [[MJPStreamItemViewController alloc] initWithStreamItem:selectedStreamItem location:self.currentLocation];
    [self.navigationController pushViewController:dummyItem animated:YES];
}
@end
