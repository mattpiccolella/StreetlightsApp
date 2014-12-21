//  MJPStreamViewController.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPStreamViewController.h"
#import "MJPAppDelegate.h"
#import "MJPStreamItemTableViewCell.h"
#import "MJPStreamItem.h"
#import "MJPStreamItemViewController.h"
#import <Parse/Parse.h>
#import "MJPQueryUtils.h"
#import "MJPMapViewController.h"
#import "MJPUserProfileViewController.h"

@interface MJPStreamViewController () 
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
- (IBAction)distanceChanged:(id)sender;
- (IBAction)sliderChangeEnded:(id)sender;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@end

@implementation MJPStreamViewController

static NSString *cellIdentifier = @"streamViewCell";
static NSInteger cellHeight = 80;
NSMutableArray *everyoneItems;
NSMutableArray *friendItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Map.png"] landscapeImagePhone:[UIImage imageNamed:@"Map.png"] style:UIBarButtonItemStyleDone target:self action:@selector(leftButtonPushed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Profile.png"] landscapeImagePhone:[UIImage imageNamed:@"Profile.png"] style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonPushed)];

    UISearchBar *searchBar = [self searchBar];
    searchBar.delegate = self;

    self.navigationItem.titleView = [self viewWithSearchBar:searchBar];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    self.appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    streamItemView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    [refresh addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [streamItemView addSubview:refresh];
    
    self.refreshControl = refresh;
    
    [self.activityIndicator startAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.distanceSlider.value = [((MJPAppDelegate *)[UIApplication sharedApplication].delegate) searchRadius];
    NSString *newLabel = [NSString stringWithFormat:@"%1.1f mi away", self.distanceSlider.value];
    [self.distanceLabel setText:newLabel];
    
    [streamItemView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.appDelegate.streamItemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MJPStreamItemTableViewCell *cell = [streamItemView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [streamItemView registerNib:[UINib nibWithNibName:@"MJPStreamItemTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [streamItemView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    PFObject *streamItem = [self.appDelegate.streamItemArray objectAtIndex:indexPath.row];
    PFObject *streamItemUser = streamItem[@"user"];
    cell.userName.text = streamItemUser[@"name"];
    cell.postInfo.text = streamItem[@"description"];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *profilePicture = [UIImage imageWithData:[streamItemUser[@"profilePicture"] getData]];
        NSLog(@"Are we doing this?");
        dispatch_async( dispatch_get_main_queue(), ^{
            [cell.userImage setImage:profilePicture];
        });
    });
    cell.userImage.contentMode = UIViewContentModeScaleAspectFill;
    // TODO: Make actual profile images.
    cell.userImage.image = [UIImage imageNamed:@"images.jpeg"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)distanceChanged:(id)sender {
    // Set the label to reflect the change
    NSString *newLabel = [NSString stringWithFormat:@"%1.1f mi away", self.distanceSlider.value];
    [self.distanceLabel setText:newLabel];
}

- (IBAction)sliderChangeEnded:(id)sender {
    [self.appDelegate setSearchRadius:self.distanceSlider.value];
    
    [self fetchNewStreamItems];
}

- (void)fetchNewStreamItems {
    float longitude = self.currentLocation.coordinate.longitude;
    float latitude = self.currentLocation.coordinate.latitude;
    float radius = self.distanceSlider.value;
    PFQuery *streamItemQuery = [MJPQueryUtils getStreamItemsForLatitude:latitude longitude:longitude radius:radius];
    [streamItemQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.appDelegate setStreamItemArray:objects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator setHidden:YES];
            [streamItemView reloadData];
            [self.refreshControl endRefreshing];
        });
    }];
}

- (void)handleRefresh {
    [self fetchNewStreamItems];
}

- (void)startGettingCurrentLocation {
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
}

- (void)loadInitialStreamItems {
    // Bad hack. We try to load only based off of whether there are any objects available.
    if ([self.appDelegate.streamItemArray count] == 0) {
        [self fetchNewStreamItems];
    } else {
        [self.activityIndicator setHidden:YES];
        [streamItemView reloadData];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // TODO: Try to fail gracefully.
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"We are updating our location.");
    // TODO: Fix this hack. We get location, load the items for that location, then stop updating it.
    self.currentLocation = newLocation;
    [self loadInitialStreamItems];
    [self.locationManager stopUpdatingLocation];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *selectedStreamItem = [self.appDelegate.streamItemArray objectAtIndex:indexPath.row];
    MJPStreamItemViewController *dummyItem = [[MJPStreamItemViewController alloc] initWithStreamItem:selectedStreamItem];
    UITabBarController *tabController = (UITabBarController*) self.appDelegate.window.rootViewController;
    UINavigationController *navController = (UINavigationController*) [[tabController viewControllers] objectAtIndex:1];
    [navController pushViewController:dummyItem animated:YES];
}

- (void)leftButtonPushed {
    // We only push the left button in the case that we want to go back to map. Kinda hack-ish.
    // TODO: Think of a way to make this less shitty later.
    
    UINavigationController *navController = (UINavigationController*) self.appDelegate.window.rootViewController;
    
    [navController popViewControllerAnimated:FALSE];
}

- (void)rightButtonPushed {
    MJPUserProfileViewController *profileView = [[MJPUserProfileViewController alloc] init];
    
    UINavigationController *navController = (UINavigationController*) [self.appDelegate.window rootViewController];
    
    [navController pushViewController:profileView animated:YES];
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
@end
