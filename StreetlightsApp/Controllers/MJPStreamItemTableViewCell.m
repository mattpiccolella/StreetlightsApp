//  MJPStreamItemTableViewCell.m
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import "MJPStreamItemTableViewCell.h"
#import "MJPPhotoUtils.h"

@implementation MJPStreamItemTableViewCell

- (void)awakeFromNib {
    [MJPPhotoUtils circularCrop:self.userImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
