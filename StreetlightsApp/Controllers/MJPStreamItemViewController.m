//  MJPStreamItemViewController.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

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

@property (strong, nonatomic) PFObject *streamItem;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *favorites;
@property (strong, nonatomic) IBOutlet UILabel *shares;



@end

@implementation MJPStreamItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithStreamItem:(PFObject *)streamItem location:(CLLocation*)location {
    self = [super init];
    if (self) {
        self.streamItem = streamItem;
        self.currentLocation = location;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the fields for the current stream item.
    self.userName.text = self.streamItem[@"user"][@"name"];
    self.postDescription.text = self.streamItem[@"description"];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *profilePicture = [UIImage imageWithData:[self.streamItem[@"user"][@"profilePicture"] getData]];
        NSLog(@"Are we doing this?");
        dispatch_async( dispatch_get_main_queue(), ^{
            NSLog(@"Setting this.");
            [self.profilePicture setImage:profilePicture];
            self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
            self.profilePicture.clipsToBounds = YES;
        });
    });
    
    // Get the dates
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[self.streamItem[@"postedTimestamp"] doubleValue]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    self.timePosted.text = [dateFormatter stringFromDate:date];
    
    double pointLatitude = [self.streamItem[@"latitude"] floatValue];
    double pointLongitude = [self.streamItem[@"longitude"] floatValue];
    
    // Add a marker for the location of the point.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(pointLatitude, pointLongitude);
    marker.map = self.mapView;
    
    // Move the map to the location of the marker
    GMSCameraUpdate *update = [GMSCameraUpdate setTarget:marker.position zoom:14.0];
    [self.mapView moveCamera:update];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back.png"] landscapeImagePhone:[UIImage imageNamed:@"Back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPushed)];
    
    // TODO: Change this once we get favorites and shares done.
    self.favorites.text = [NSString stringWithFormat:@"%u", arc4random() % 8];
    self.shares.text = [NSString stringWithFormat:@"%u", arc4random() % 8];
    
    // Set the date of amount of time remaining.
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[self.streamItem[@"expiredTimestamp"] doubleValue]];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [expirationDate timeIntervalSinceDate:currentDate];
    self.timeRemaining.text = [NSString stringWithFormat:@"%dm", (int) timeInterval / 60];
    
    self.distanceLabel.text = [NSString stringWithFormat:@"%.02f mi", [self distanceFromLatitude:pointLatitude longitude:pointLongitude]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonPushed {
    [self.navigationController popViewControllerAnimated:YES];
}

// Find the distance between our current location and the point in question.
- (double)distanceFromLatitude:(double)latitude longitude:(double)longitude {
    double currentLatitude = self.currentLocation.coordinate.latitude;
    double currentLongitude = self.currentLocation.coordinate.longitude;
    
    float MILES_PER_LONG = 53.0;
    float MILES_PER_LAT = 69.0;
    
    double dLatitudeMiles = (currentLatitude - latitude) / MILES_PER_LAT;
    double dLongitudeMiles = (currentLongitude - longitude) / MILES_PER_LONG;

    // Find the distance between the two points.
    return sqrt((dLatitudeMiles * dLatitudeMiles) + (dLongitudeMiles * dLongitudeMiles));
}

@end
