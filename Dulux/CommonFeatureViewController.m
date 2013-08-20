//
//  CommonFeatureViewController.m
//  Dulux
//
//  Created by Emptymind on 8/20/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import "CommonFeatureViewController.h"

@interface CommonFeatureViewController ()

@end

@implementation CommonFeatureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initSwipeRecognizers
{
    UISwipeGestureRecognizer* swipe_left_recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    swipe_left_recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer* swipe_right_recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    swipe_right_recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:swipe_left_recognizer];
    [self.view addGestureRecognizer:swipe_right_recognizer];
}

- (void) initNavigateButtons
{
    CGRect bounds = self.view.bounds;
    int button_width  = 50;
    int button_height = 50;
    int x = 20;
    int y = bounds.size.height - 15 - button_height;
    
    NSString* home_pic = @"homebutton.png";
    UIImage* home_image = [UIImage imageNamed:home_pic];
    UIButton* home_button = [[UIButton alloc] init];
    home_button.frame = CGRectMake(x, y, button_width, button_height);
    [home_button setImage:home_image forState:UIControlStateNormal];
    [home_button addTarget:self action:@selector(navigateHome:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:home_button];
    
    NSString* back_pic = @"backbutton.png";
    UIImage* back_image = [UIImage imageNamed:back_pic];
    UIButton* back_button = [[UIButton alloc] init];
    back_button.frame = CGRectMake(x+button_width+20, y, button_width, button_height);
    [back_button setImage:back_image forState:UIControlStateNormal];
    [back_button addTarget:self action:@selector(navigateBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back_button];
}

- (void) navigateHome:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

- (void) navigateBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
