//  MJPStreamItemViewController.h
//  AroundApp
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MJPStreamItemViewController : UIViewController<UIActionSheetDelegate>

- (id)initWithStreamItem:(PFObject *)streamItem location:(CLLocation *)location;

@end
