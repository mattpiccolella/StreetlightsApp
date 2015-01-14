//
//  MJPPostHistoryTableViewController.m
//  Around
//
//  Created by Matt on 1/2/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPPostHistoryTableViewController.h"
#import "MJPStreamItemTableViewCell.h"
#import "MJPAppDelegate.h"
#import "MJPViewUtils.h"

@interface MJPPostHistoryTableViewController ()

@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *postHistoryArray;
@property (strong, nonatomic) UIView* blankView;

@end

static NSString *cellIdentifier = @"streamViewCell";
static NSInteger cellHeight = 96;

@implementation MJPPostHistoryTableViewController

- (id)initWithPosts:(NSArray*)posts {
    self = [super init];
    
    self.postHistoryArray = posts;
    
    [MJPViewUtils setNavigationUI:self withTitle:@"Post History" backButtonName:@"Back.png"];
    [self.navigationItem.leftBarButtonItem setAction:@selector(backButtonPushed)];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [self setBlankView:[self createBlankView]];
    [self.blankView setHidden:YES];
    [self.tableView setBackgroundView:self.blankView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MJPStreamItemTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        [self.tableView registerNib:[UINib nibWithNibName:@"MJPStreamItemTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    PFObject *streamItem = [self.postHistoryArray objectAtIndex:indexPath.row];
    cell.userName.text = self.appDelegate.currentUser[@"name"];
    cell.postInfo.text = streamItem[@"description"];
    
    cell.favorites.text = [NSString stringWithFormat:@"%lu", (unsigned long)(streamItem[@"favoriteIds"] ? [streamItem[@"favoriteIds"] count] : 0)];
    // TODO: Fix once we actually share.
    cell.shares.text = [NSString stringWithFormat:@"0"];
    
    // Set the date of amount of time remaining.
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[streamItem[@"expiredTimestamp"] doubleValue]];
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [expirationDate timeIntervalSinceDate:currentDate];
    cell.timeRemaining.text = [NSString stringWithFormat:@"%dm", timeInterval > 0 ? (int) timeInterval / 60 : 0];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *profilePicture = [UIImage imageWithData:[self.appDelegate.currentUser[@"profilePicture"] getData]];
        dispatch_async( dispatch_get_main_queue(), ^{
            [cell.userImage setImage:profilePicture];
        });
    });
    cell.userImage.contentMode = UIViewContentModeScaleAspectFill;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.appDelegate.streamItemArray count] == 0) {
        [self showBlankView:YES];
    } else {
        [self showBlankView:NO];
    }
    return [self.appDelegate.streamItemArray count];
}

-(void)backButtonPushed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView*)createBlankView {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    messageLabel.text = @"You haven't posted anything yet. Post something to get started!";
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont fontWithName:@"Avenir" size:20];
    [messageLabel sizeToFit];
    
    return messageLabel;
}

- (void)showBlankView:(BOOL)show {
    if (show) {
        [self.blankView setHidden:NO];
        self.tableView.backgroundView = self.blankView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        [self.blankView setHidden:YES];
    }
}
@end
