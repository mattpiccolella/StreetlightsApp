//
//  MJPMapViewController.m
//  StreetlightsApp
//
//  Created by Matt on 8/19/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MJPMapViewController ()

@end

@implementation MJPMapViewController {
    GMSMapView *locationMapView_;
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
    
    self.view.tintColor = [UIColor orangeColor];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.8075
                                                            longitude:-73.9619
                                                                 zoom:12];
    
    locationMapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    locationMapView_.settings.compassButton = YES;
    locationMapView_.settings.myLocationButton = YES;
    
    [locationMapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    self.view = locationMapView_;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        locationMapView_.myLocationEnabled = YES;
    });
}

- (void)dealloc {
    [locationMapView_ removeObserver:self forKeyPath:@"myLocation" context:NULL];
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
        locationMapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    }
}

@end
