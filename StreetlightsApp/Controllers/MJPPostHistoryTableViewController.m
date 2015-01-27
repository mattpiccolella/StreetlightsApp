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
    
    [MJPViewUtils setNavigationUI:self withTitle:@"POST HISTORY" backButtonName:@"Back.png"];
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
    [MJPViewUtils setUIForStreamItem:streamItem user:self.appDelegate.currentUser tableCell:cell];
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
    NSString *placeHolder = @"You haven't posted anything yet. Post something to get started!";
    return [MJPViewUtils blankViewWithMessage:placeHolder andBounds:self.view.bounds];
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
