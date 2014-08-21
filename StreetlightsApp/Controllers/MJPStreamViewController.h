//
//  MJPStreamViewController.h
//  StreetlightsApp
//
//  Created by Matt on 8/19/14.
//  Copyright (c) 2014 Matthew Piccolella. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJPStreamViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    
    IBOutlet UITableView *streamItemView;
    
    NSMutableArray *streamItemEveryoneArray;
    NSMutableArray *streamItemFriendArray;
}

@end
