//  MJPStreamViewController.h
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"

@interface MJPStreamViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate> {
    
    IBOutlet UITableView *streamItemView;

}

@end
