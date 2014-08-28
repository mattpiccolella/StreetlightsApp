//
//  MJPMapViewController.h
//  StreetlightsApp
//
//  Created by Matt on 8/19/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"

@interface MJPMapViewController : UIViewController<UISearchBarDelegate, CLLocationManagerDelegate>

- (void) addMarkers;

@end
