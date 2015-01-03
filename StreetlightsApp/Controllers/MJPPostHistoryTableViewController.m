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

@interface MJPPostHistoryTableViewController ()

@property (strong, nonatomic) MJPAppDelegate *appDelegate;
@property (strong, nonatomic) NSArray *postHistoryArray;

@end

static NSString *cellIdentifier = @"streamViewCell";
static NSInteger cellHeight = 96;

@implementation MJPPostHistoryTableViewController

- (id)initWithPosts:(NSArray*)posts {
    self = [super init];
    
    self.postHistoryArray = posts;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back.png"] landscapeImagePhone:[UIImage imageNamed:@"Back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPushed)];
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Post History"]];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (MJPAppDelegate*)[UIApplication sharedApplication].delegate;
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
    return [self.postHistoryArray count];
}

-(void)backButtonPushed {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
