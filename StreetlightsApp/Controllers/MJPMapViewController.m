//
//  MJPMapViewController.m
//  StreetlightsApp
//
//  Created by Matt on 8/19/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPMapViewController.h"
#import "MJPAppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MJPMapViewController ()
@property (strong, nonatomic) IBOutlet UISegmentedControl *scopeSelector;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
- (IBAction)distanceChanged:(id)sender;
- (IBAction)sliderChangeEnded:(id)sender;
- (IBAction)scopeChanged:(id)sender;

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

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.8075
                                                            longitude:-73.9619
                                                                 zoom:12];
    
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
    [self.scopeSelector setSelectedSegmentIndex:[((MJPAppDelegate *)[UIApplication sharedApplication].delegate) searchEveryone]];

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
    [((MJPAppDelegate *)[UIApplication sharedApplication].delegate) setSearchRadius:self.distanceSlider.value];
    
    // TODO: Query for items based on the new radius.
}

- (IBAction)scopeChanged:(id)sender {
    [((MJPAppDelegate *)[UIApplication sharedApplication].delegate) setSearchEveryone:self.scopeSelector.selectedSegmentIndex];

    // TODO: query for new items based on friends or not friends.
}
@end
