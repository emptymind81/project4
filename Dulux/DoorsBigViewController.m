//
//  DoorsViewController.m
//  Dulux
//
//  Created by You Alun on 8/7/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import "DoorsBigViewController.h"
#import "AutoLayoutHelper.h"
#import "RoomViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface DoorsBigViewController ()

@end

typedef enum
{
    InitReason_GoLeft=0,
    InitReason_GoRight=1,
    InitReason_ViewAppear=2
} InitReason;

@implementation DoorsBigViewController
{
   
   UIImageView* m_back_image_view;
}

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
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reInitSubViews:InitReason_ViewAppear];
}

- (void) reInitSubViews:(InitReason)initReason
{
    [self clearView];
    
    NSString* back_pic = [NSString stringWithFormat:@"seri%d-room%d-big-back.jpg", self.seriIndex+1, self.roomIndex+1];
    m_back_image_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:back_pic]];
    [self.view addSubview:m_back_image_view];
    
    //add animation
    [self addSwitchViewAnimation:initReason];
    
    NSString* left_button_pic = @"leftbutton.png";
    UIImage* left_button_image = [UIImage imageNamed:left_button_pic];
    UIButton* left_button = [[UIButton alloc] init];
    [left_button setImage:left_button_image forState:UIControlStateNormal];
    [left_button addTarget:self action:@selector(goLeft:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:left_button];
    
    NSString* right_button_pic = @"rightbutton.png";
    UIImage* right_button_image = [UIImage imageNamed:right_button_pic];
    UIButton* right_button = [[UIButton alloc] init];
    [right_button setImage:right_button_image forState:UIControlStateNormal];
    [right_button addTarget:self action:@selector(goRight:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:right_button];
    
    NSString* center_button_pic = @"centerbutton.png";
    UIImage* center_button_image = [UIImage imageNamed:center_button_pic];
    UIButton* center_button = [[UIButton alloc] init];
    [center_button setImage:center_button_image forState:UIControlStateNormal];
    [center_button addTarget:self action:@selector(startDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:center_button];
    
    NSArray* sub_views = self.view.subviews;
    for (int i=0; i<sub_views.count; i++)
    {
        UIView* view = sub_views[i];
        view.translatesAutoresizingMaskIntoConstraints = false;
    }
    
    //constraints for icon:
    [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:m_back_image_view another:self.view attr:NSLayoutAttributeCenterX anotherAttr:NSLayoutAttributeCenterX]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:m_back_image_view another:self.view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:0]];
    
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:left_button another:self.view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:322]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:left_button another:self.view attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeLeft offset:0]];
    
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:right_button another:self.view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:322]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:right_button another:self.view attr:NSLayoutAttributeRight anotherAttr:NSLayoutAttributeRight offset:0]];
    
    [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:center_button another:self.view attr:NSLayoutAttributeCenterX anotherAttr:NSLayoutAttributeCenterX]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:center_button another:self.view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:343]];
    
    [self initNavigateButtons];
    
    [self initSwipeRecognizers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) switchToRoom
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.view.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                         RoomViewController* view_controller = [[RoomViewController alloc] initWithNibName:@"RoomViewController" bundle:nil];
                         view_controller.seriIndex = self.seriIndex;
                         view_controller.roomIndex = self.roomIndex;
                         [self.navigationController pushViewController:view_controller animated:false];
                     }];

}

- (void) startDetail:(id)sender
{
    [self switchToRoom];
}

- (void) clearView
{
    NSArray* sub_views = self.view.subviews;
    for (int i=0; i<sub_views.count; i++)
    {
        UIView* view = sub_views[i];
        [view removeFromSuperview];
    }
    for (int i=0; i<self.view.gestureRecognizers.count; i++)
    {
        UIGestureRecognizer* recognizer = self.view.gestureRecognizers[i];
        [self.view removeGestureRecognizer:recognizer];
    }
}

- (void) addSwitchViewAnimation:(InitReason)initReason
{
    if (initReason == InitReason_GoLeft || initReason == InitReason_GoRight)
    {
        // set up an animation for the transition between the views
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.3];
        [animation setType:kCATransitionPush];
        if (initReason == InitReason_GoLeft)
        {
            [animation setSubtype:kCATransitionFromRight];
        }
        else
        {
            [animation setSubtype:kCATransitionFromLeft];
        }
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[self.view layer] addAnimation:animation forKey:@"SwitchToView"];
    }
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

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)swipeRecognizer
{
    self.roomIndex = (self.roomIndex-1+3) % 3;
    [self reInitSubViews:InitReason_GoLeft];
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)swipeRecognizer
{
    self.roomIndex = (self.roomIndex+1+3) % 3;
    [self reInitSubViews:InitReason_GoRight];
}

- (void) goLeft:(id)sender
{
    self.roomIndex = (self.roomIndex-1+3) % 3;
    [self reInitSubViews:InitReason_GoLeft];
    
}

- (void) goRight:(id)sender
{
    self.roomIndex = (self.roomIndex+1+3) % 3;
    [self reInitSubViews:InitReason_GoRight];
}

- (void) initNavigateButtons
{
    CGRect bounds = self.view.bounds;
    int button_width  = 52;
    int button_height = 48;
    int x = 20;
    int y = bounds.size.height - 14 - button_height;
    
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
