//
//  MJPStreamItemWindow.h
//  StreetlightsApp
//
//  Created by Matt on 12/21/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJPStreamItemWindow : UIView

@property (strong, nonatomic) IBOutlet UILabel *streamItemDescription;
@property (strong, nonatomic) IBOutlet UILabel *posterName;
@property (strong, nonatomic) IBOutlet UIImageView *posterImage;
@property (strong, nonatomic) IBOutlet UILabel *timePosted;
@property (strong, nonatomic) IBOutlet UILabel *distanceAway;

@end
