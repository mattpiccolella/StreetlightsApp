//  MJPMapViewController.h
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MJPMapViewController : UIViewController<UISearchBarDelegate, CLLocationManagerDelegate, GMSMapViewDelegate>

- (void) addMarkers;

@end
