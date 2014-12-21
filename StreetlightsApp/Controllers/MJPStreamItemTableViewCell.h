//  MJPStreamItemTableViewCell.h
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import <UIKit/UIKit.h>

@interface MJPStreamItemTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *postInfo;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;

@end
