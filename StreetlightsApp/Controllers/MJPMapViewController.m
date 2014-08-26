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

@interface MJPMapViewController ()
@property (strong, nonatomic) IBOutlet UISegmentedControl *scopeSelector;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UISearchBar *locationSearch;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)distanceChanged:(id)sender;
- (IBAction)sliderChangeEnded:(id)sender;
- (IBAction)scopeChanged:(id)sender;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@end


@implementation MJPMapViewController {
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
    
    self.appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.8075
                                                            longitude:-73.9619
                                                                 zoom:12];
    
    self.mapView.camera = camera;
    
    [self.mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    if ([self.appDelegate.everyoneArray count] == 0) {
        [self.activityIndicator startAnimating];
        NSLog(@"We are trying to do stuff here.");
        // TODO: Add stuff here.
    } else {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator setHidden:YES];
        [self addMarkers];
    }
    
    
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
    
    [self.mapView clear];
    [self addMarkers];
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
    
    // TODO: Query for items based on the new radius.
}

- (IBAction)scopeChanged:(id)sender {
    [self.appDelegate setSearchEveryone:self.scopeSelector.selectedSegmentIndex];

    [self.mapView clear];
    
    [self addMarkers];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self.locationSearch resignFirstResponder];
    
    // TODO: Search for the location we have and interface with the Places autocomplete.
}

- (void) addMarkers {
    // TODO: Add custom markers.
    if (self.scopeSelector.selectedSegmentIndex) {
        for (MJPStreamItem *streamItem in self.appDelegate.friendArray) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.title = streamItem.user.name;
            marker.position = CLLocationCoordinate2DMake([streamItem latitude], [streamItem longitude]);
            marker.map = self.mapView;
        }
    } else {
        for (MJPStreamItem *streamItem in self.appDelegate.everyoneArray) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.title = streamItem.user.name;
            marker.position = CLLocationCoordinate2DMake([streamItem latitude], [streamItem longitude]);
            marker.map = self.mapView;
        }
    }
}

@end
