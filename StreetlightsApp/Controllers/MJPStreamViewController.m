//
//  MJPStreamViewController.m
//  StreetlightsApp
//
//  Created by Matt on 8/19/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import "MJPStreamViewController.h"
#import "MJPAppDelegate.h"
#import "MJPStreamItemTableViewCell.h"
#import "MJPStreamItem.h"

@interface MJPStreamViewController ()
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) IBOutlet UISegmentedControl *scopeSelector;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UISearchBar *locationSearch;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)distanceChanged:(id)sender;
- (IBAction)sliderChangeEnded:(id)sender;
- (IBAction)scopeChanged:(id)sender;

@end

@implementation MJPStreamViewController

static NSString *cellIdentifier = @"streamViewCell";
static NSInteger cellHeight = 80;

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
    // Do any additional setup after loading the view from its nib.
    
    streamItemView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.activityIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       streamItemArray = [[NSMutableArray alloc] initWithArray:[MJPStreamItem getDummyStreamItems]];
                       
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          [self.activityIndicator stopAnimating];
                                          [self.activityIndicator setHidden:YES];
                                          [streamItemView reloadData];
                                      });
                });
}

- (void)viewWillAppear:(BOOL)animated
{
    self.scopeSelector.selectedSegmentIndex = [((MJPAppDelegate *)[UIApplication sharedApplication].delegate) searchEveryone];
    
    self.distanceSlider.value = [((MJPAppDelegate *)[UIApplication sharedApplication].delegate) searchRadius];
    NSString *newLabel = [NSString stringWithFormat:@"%1.1f mi away", self.distanceSlider.value];
    [self.distanceLabel setText:newLabel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [streamItemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MJPStreamItemTableViewCell *cell = [streamItemView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [streamItemView registerNib:[UINib nibWithNibName:@"MJPStreamItemTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [streamItemView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    MJPStreamItem *streamItem = ((MJPStreamItem*)[streamItemArray objectAtIndex:indexPath.row]);
    cell.userName.text = streamItem.userName;
    cell.postInfo.text = streamItem.postInfo;
    cell.userImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.userImage.image = streamItem.userImage;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.locationSearch resignFirstResponder];
    
    // TODO: Actually search something...not sure what.
}
@end
