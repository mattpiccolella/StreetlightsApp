//
//  MJPTutorialViewController.m
//  Around
//
//  Created by Matt on 1/3/15.
//  Copyright (c) 2015 Matthew Piccolella. All rights reserved.
//

#import "MJPTutorialViewController.h"
#import "MJPHomeScreenViewController.h"
#import "MJPRegisterViewController.h"
#import "MJPAppDelegate.h"
#import "MJPLoginViewController.h"

@interface MJPTutorialViewController ()

@property (strong, nonatomic) NSMutableArray *textArray;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)registerButtonPressed:(id)sender;
- (IBAction)loginButtonPressed:(id)sender;
@property (strong, nonatomic) MJPAppDelegate *appDelegate;


@end

@implementation MJPTutorialViewController

const int NUMBER_OF_TUTORIAL_SCREENS = 3;

- (id)init {
    self = [super init];
    
    if (self) {
        self.textArray = [self tutorialText];
        self.imageArray = [self tutorialImages];
    }
    
    return self;
}

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0 green:204/255.0 blue:102/255.0 alpha:0.2]];
    
    self.appDelegate = (MJPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    NSArray *viewControllers = [NSArray arrayWithObject:[self viewControllerAtIndex:0]];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60);
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    
    self.registerButton.layer.cornerRadius = 5;
    self.loginButton.layer.cornerRadius = 5;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(MJPHomeScreenViewController*)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(MJPHomeScreenViewController*)viewController index];
    
    
    index++;
    
    if (index == NUMBER_OF_TUTORIAL_SCREENS) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (MJPHomeScreenViewController*)viewControllerAtIndex:(NSUInteger)index {
    
    MJPHomeScreenViewController *homeScreenController = [[MJPHomeScreenViewController alloc] initWithScreenText:[self.textArray objectAtIndex:index] screenImage:[self.imageArray objectAtIndex:index] index:index];
    
    return homeScreenController;
    
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    int currentPage = [[pageViewController.viewControllers objectAtIndex:0] index];
    return currentPage;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return NUMBER_OF_TUTORIAL_SCREENS;
}

- (NSMutableArray*) tutorialText {
    NSString *firstString = @"Welcome to Around! This is just some sample text to get us started!.";
    NSString *secondString = @"This is another sample string just to see how the text looks.";
    NSString *thirdString = @"This is another thing that we are hoping will look good.";
    return [NSMutableArray arrayWithObjects:firstString, secondString, thirdString, nil];
    
}

- (NSMutableArray*) tutorialImages {
    UIImage *firstImage = [UIImage imageNamed:@"TutorialImage1.jpg"];
    UIImage *secondImage = [UIImage imageNamed:@"TutorialImage2.jpg"];
    UIImage *thirdImage = [UIImage imageNamed:@"TutorialImage3.jpg"];
    return [NSMutableArray arrayWithObjects:firstImage, secondImage, thirdImage, nil];
}
- (IBAction)registerButtonPressed:(id)sender {
    MJPRegisterViewController *registerViewController = [[MJPRegisterViewController alloc] init];
    
    [self.navigationController pushViewController:registerViewController animated:YES];
}

- (IBAction)loginButtonPressed:(id)sender {
    MJPLoginViewController *loginViewController = [[MJPLoginViewController alloc] init];
    
    [self.navigationController pushViewController:loginViewController animated:YES];
}
@end
