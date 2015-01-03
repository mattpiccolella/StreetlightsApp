//
//  MJPHomeScreenViewController.m
//  Around
//
//  Created by Matt on 1/3/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPHomeScreenViewController.h"

@interface MJPHomeScreenViewController ()
@property (strong, nonatomic) IBOutlet UILabel *screenText;
@property (strong, nonatomic) IBOutlet UIImageView *screenImage;

@property (strong, nonatomic) NSString* screenRawText;
@property (strong, nonatomic) UIImage* screenRawImage;

@end

@implementation MJPHomeScreenViewController

- (id)initWithScreenText:(NSString*)screenText screenImage:(UIImage*)image index:(NSUInteger)index {
    self = [super init];
    
    if (self) {
        [self setScreenRawText:screenText];
        [self setScreenRawImage:image];
        self.index = index;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Round corners of the buttons.
    
    [self.screenText setText:self.screenRawText];
    [self.screenImage setImage:self.screenRawImage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
