//
//  MJPHomeScreenViewController.h
//  Around
//
//  Created by Matt on 1/3/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJPHomeScreenViewController : UIViewController

- (id)initWithScreenText:(NSString*)screenText screenImage:(UIImage*)image index:(NSUInteger)index;

@property (assign, nonatomic) NSUInteger index;

@end
