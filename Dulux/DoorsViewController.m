//
//  DoorsViewController.m
//  Dulux
//
//  Created by You Alun on 8/7/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import "DoorsViewController.h"
#import "AutoLayoutHelper.h"
#import "RoomViewController.h"
#import "DoorsBigViewController.h"

@interface DoorsViewController ()

@end

@implementation DoorsViewController
{
   NSMutableArray* m_image_views;
   UIImageView* m_image_view1;
   UIImageView* m_image_view2;
   UIImageView* m_image_view3;
   
   UIImageView* m_icon_image_view;
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
   
    NSString* back_pic = [NSString stringWithFormat:@"seri%d-back.jpg", self.seriIndex+1];
   m_icon_image_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:back_pic]];
   
    NSString* room1_pic = [NSString stringWithFormat:@"seri%d-room%d.jpg", self.seriIndex+1, 1];
    NSString* room2_pic = [NSString stringWithFormat:@"seri%d-room%d.jpg", self.seriIndex+1, 2];
    NSString* room3_pic = [NSString stringWithFormat:@"seri%d-room%d.jpg", self.seriIndex+1, 3];
   m_image_view1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:room1_pic]];
   m_image_view2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:room2_pic]];
   m_image_view3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:room3_pic]];
    
   // m_image_view2.highlightedImage = [UIImage imageNamed:@"door102open.png"];
   
   m_image_views = [[NSMutableArray alloc] initWithObjects:m_icon_image_view, m_image_view1, m_image_view2, m_image_view3, nil];
   for (int i=0; i<m_image_views.count; i++)
   {
      UIImageView* view = m_image_views[i];
      [self.view addSubview:view];
      view.translatesAutoresizingMaskIntoConstraints = false;
      view.contentMode = UIViewContentModeScaleToFill;
      view.userInteractionEnabled = true;
       
       UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
       [view addGestureRecognizer:singleTap];
   }
    
   //constraints for icon:
   [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:m_icon_image_view another:self.view attr:NSLayoutAttributeCenterX anotherAttr:NSLayoutAttributeCenterX]];
   [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:m_icon_image_view another:self.view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:0]];
   
   //constraints for doors:
   [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:m_image_view1 another:m_image_view2 attr:NSLayoutAttributeWidth]];
   [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:m_image_view1 another:m_image_view2 attr:NSLayoutAttributeHeight]];
   [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:m_image_view1 another:m_image_view3 attr:NSLayoutAttributeWidth]];
   [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:m_image_view1 another:m_image_view3 attr:NSLayoutAttributeHeight]];
   [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:m_image_view1 another:m_image_view2 attr:NSLayoutAttributeBottom]];
   [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:m_image_view1 another:m_image_view3 attr:NSLayoutAttributeBottom]];
   [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:m_image_view2 another:m_image_view1 attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeRight offset:0]];
   [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:m_image_view3 another:m_image_view2 attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeRight offset:0]];
   
   [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:m_image_view1 another:m_icon_image_view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:300]];
   [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:m_image_view2 another:self.view attr:NSLayoutAttributeCenterX anotherAttr:NSLayoutAttributeCenterX]];
   //[self.view addConstraint:[AutoLayoutHelper viewEqualsToNumber:m_image_view1 number:100 attr:NSLayoutAttributeWidth]];
   //[self.view addConstraint:[AutoLayoutHelper viewEqualsToNumber:m_image_view2 number:100 attr:NSLayoutAttributeHeight]];

   
   for (int i=0; i<m_image_views.count; i++)
   {
      NSLayoutConstraint* constraint = [[NSLayoutConstraint alloc] init];
   }

   [self initNavigateButtons];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) switchToRoom:(int)roomIndex
{
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.view.alpha = 1;
                     }
                     completion:^(BOOL finished){
                         
                         DoorsBigViewController* view_controller = [[DoorsBigViewController alloc] initWithNibName:@"DoorsBigViewController" bundle:nil];
                         view_controller.seriIndex = self.seriIndex;
                         view_controller.roomIndex = roomIndex;
                         [self.navigationController pushViewController:view_controller animated:false];
                     }];

}

- (void)handleTap:(UITapGestureRecognizer *)tapRecognizer {
    
    for (int i=1; i<m_image_views.count; i++)
    {
        UIImageView* view = m_image_views[i];
        if (view == tapRecognizer.view)
        {
            [UIView animateWithDuration:0.1
                             animations:^{
                                 //m_image_view2.alpha = 0.2;
                                 //view.image = [UIImage imageNamed:@"door102open.png"];
                             }
                             completion:^(BOOL finished){
                                 //sleep(1);
                                 
                                 [self switchToRoom:i-1];
                             }];
        }
    }

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
