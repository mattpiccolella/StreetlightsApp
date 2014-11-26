//
//  MJPStreamItemViewController.m
//  StreetlightsApp
//
//  Created by Matt on 8/28/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPStreamItemViewController.h"
#import "MJPStreamItem.h"
#import "MJPUser.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MJPStreamItemViewController ()
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *postDescription;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *timePosted;
@property (strong, nonatomic) IBOutlet UILabel *timeRemaining;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;

@property (strong, nonatomic) PFObject *streamItem;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

@end

@implementation MJPStreamItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithStreamItem:(PFObject *)streamItem {
    self = [super init];
    if (self) {
        self.streamItem = streamItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the fields for the current stream item.
    self.userName.text = self.streamItem[@"user"][@"name"];
    self.postDescription.text = self.streamItem[@"description"];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *profilePicture = [UIImage imageWithData:[self.streamItem[@"user"][@"profilePicture"] getData]];
        NSLog(@"Are we doing this?");
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.profilePicture setImage:profilePicture];
        });
    });
    
    // Get the dates
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[self.streamItem[@"postedTimestamp"] doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    self.timePosted.text = [dateFormatter stringFromDate:date];
    
    // Add a marker for the location of the point.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([self.streamItem[@"latitude"] floatValue], [self.streamItem[@"longitude"] floatValue]);
    marker.map = self.mapView;
    
    // Move the map to the location of the marker
    GMSCameraUpdate *update = [GMSCameraUpdate setTarget:marker.position zoom:14.0];
    [self.mapView moveCamera:update];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:1.0]];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.topItem.title = @"Pinpoint";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
