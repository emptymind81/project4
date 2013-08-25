//
//  RoomViewController.m
//  Dulux
//
//  Created by Emptymind on 8/8/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import "RoomViewController.h"
#import "UIRoundRectView.h"
#import "AutoLayoutHelper.h"
#import "AppDelegate.h"

#import "ShareSDK_v2.3.1/ShareSDK.framework/Headers/ShareSDK.h"
#import "WXApi.h"
#import "WBApi.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "QuartzCore/QuartzCore.h"
#import "UIImage+ColorAtPixel.h"
#import "UIImage+Tint.h"
#import "UIImage+Alpha.h"
#import "AGCustomShareViewController.h"

#import "WeiboSDK.h"
#import "Weibo.h"

@interface RoomViewController ()

@end

typedef enum
{
    InitReason_GoLeft=0,
    InitReason_GoRight=1,
    InitReason_ViewAppear=2
} InitReason;

@implementation RoomViewController
{
    UIImageView* m_back_image_view;
    UIImageView* m_floating_image_view;
    
    UIImageView* m_image_view_room;
    NSString* m_room_picture_name;
    
    NSMutableArray* m_button_views;
    NSMutableArray* m_colors;
    NSMutableArray* m_colored_room_picture_names;
    
    AppDelegate* m_app_delegate;
    
    NSMutableArray* m_wall_views;
    NSMutableArray* m_wall_color_button_indexs;
    
    NSMutableArray* m_color_buttons;
    
    bool m_is_dragging_color_button;
    int m_previous_wall_index;
   
   UIImageView* m_paint_tool_view;
   NSMutableArray* m_paint_tool_view_opaque_pts;
    
    UIAlertView* m_alert_view;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        if (self.roomIndex == 0)
        {
            m_colors = [NSMutableArray arrayWithObjects:
                        [UIColor colorWithRed:1 green:1 blue:0 alpha:1],
                        [UIColor colorWithRed:1 green:0 blue:0 alpha:1],
                        [UIColor colorWithRed:1 green:0 blue:1 alpha:1],
                        [UIColor colorWithRed:0 green:1 blue:0 alpha:1],
                        nil];
            m_colored_room_picture_names = [NSMutableArray arrayWithObjects:
                                    @"room1colored",
                                    @"room1colored",
                                    @"room1colored",
                                    @"room1colored",
                                    nil];
            m_room_picture_name = @"room1";
        }
        else if(self.roomIndex == 1)
        {
            m_colors = [NSMutableArray arrayWithObjects:
                        [UIColor colorWithRed:1 green:1 blue:0 alpha:1],
                        [UIColor colorWithRed:1 green:0 blue:0 alpha:1],
                        [UIColor colorWithRed:1 green:0 blue:1 alpha:1],
                        [UIColor colorWithRed:0 green:1 blue:0 alpha:1],
                        nil];
            m_colored_room_picture_names = [NSMutableArray arrayWithObjects:
                                    @"room1colored",
                                    @"room1colored",
                                    @"room1colored",
                                    @"room1colored",
                                    nil];
            m_room_picture_name = @"room1";
        }
        else if(self.roomIndex == 2)
        {
            m_colors = [NSMutableArray arrayWithObjects:
                        [UIColor colorWithRed:1 green:1 blue:0 alpha:1],
                        [UIColor colorWithRed:1 green:0 blue:0 alpha:1],
                        [UIColor colorWithRed:1 green:0 blue:1 alpha:1],
                        [UIColor colorWithRed:0 green:1 blue:0 alpha:1],
                        nil];
            m_colored_room_picture_names = [NSMutableArray arrayWithObjects:
                                    @"room1colored",
                                    @"room1colored",
                                    @"room1colored",
                                    @"room1colored",
                                    nil];
            m_room_picture_name = @"room1";
        }
        
        m_app_delegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
        
        
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
    
    NSString* back_pic = [NSString stringWithFormat:@"seri%d-room%d-paint.jpg", self.seriIndex+1, self.roomIndex+1];
    m_back_image_view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:back_pic]];
    [self.view addSubview:m_back_image_view];
    
    int nMaxWall = 5;
    
    for(int i=0; i<nMaxWall; i++)
    {
        NSString* wall_pic = [NSString stringWithFormat:@"seri%d-room%d-wall%d.png", self.seriIndex+1, self.roomIndex+1, i+1];
        UIImage* image = [UIImage imageNamed:wall_pic];
        if (image)
        {
            UIImageView* wall_image_view = [[UIImageView alloc] initWithImage:image];
            [self.view addSubview:wall_image_view];
            [m_wall_views addObject:wall_image_view];
            [m_wall_color_button_indexs addObject:[NSNumber numberWithInt:-1]];
        }
    }
    
    NSString* flating_pic = [NSString stringWithFormat:@"seri%d-room%d-floating.png", self.seriIndex+1, self.roomIndex+1];
    UIImage* floating_image = [UIImage imageNamed:flating_pic];
    m_floating_image_view = nil;
    if (floating_image)
    {
        m_floating_image_view = [[UIImageView alloc] initWithImage:floating_image];
        [self.view addSubview:m_floating_image_view];
    }
    
    
    
    
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
    
    UIView* color_band_view = [[UIView alloc] init];
    color_band_view.backgroundColor = [UIColor colorWithRed:0.827 green:0.827 blue:0.827 alpha:1];
    [self.view addSubview:color_band_view];
    
    NSString* color_band_hint_pic = @"pushcolorbuttonhinttext.png";
    UIImageView* color_band_hint_button = [[UIImageView alloc] initWithImage:[UIImage imageNamed:color_band_hint_pic]];
    [self.view addSubview:color_band_hint_button];
    
    m_color_buttons = [[NSMutableArray alloc] init];
    int color_button_num = 5;
    for (int i=0; i<color_button_num; i++)
    {
        NSString* color_button_pic = [NSString stringWithFormat:@"seri%d-room%d-colorbutton%d.png", self.seriIndex+1, self.roomIndex+1, i+1];
        UIImage* color_button_image = [UIImage imageNamed:color_button_pic];
        /*UIButton* color_button = [[UIButton alloc] init];
        [color_button setImage:color_button_image forState:UIControlStateNormal];
        [color_button addTarget:self action:@selector(colorButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:color_button];*/
        
        UIDraggableView* color_button_view = [[UIDraggableView alloc] initWithImage:color_button_image];
        color_button_view.userInteractionEnabled = true;
        color_button_view.delegate = self;
        [self.view addSubview:color_button_view];
        
        [m_color_buttons addObject:color_button_view];
    }
    
    NSString* share_button_pic = @"shareweibo.png";
    UIImage* share_button_image = [UIImage imageNamed:share_button_pic];
    UIButton* share_button = [[UIButton alloc] init];
    [share_button setImage:share_button_image forState:UIControlStateNormal];
    [share_button addTarget:self action:@selector(shareToSinaWeiboWithCustomUI:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:share_button];
    
    NSString* dulux_icon_pic = @"newduluxicon.png";
    UIImageView* dulux_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:dulux_icon_pic]];
    [self.view addSubview:dulux_icon];
    
    
    NSArray* sub_views = self.view.subviews;
    for (int i=0; i<sub_views.count; i++)
    {
        UIView* view = sub_views[i];
        view.translatesAutoresizingMaskIntoConstraints = false;
    }
    
    //constraints for icon:
    [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:m_back_image_view another:self.view attr:NSLayoutAttributeCenterX anotherAttr:NSLayoutAttributeCenterX]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:m_back_image_view another:self.view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:0]];
    
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:color_band_view another:self.view attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeLeft offset:0]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:color_band_view another:self.view attr:NSLayoutAttributeBottom anotherAttr:NSLayoutAttributeBottom offset:-78]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:color_band_view another:self.view attr:NSLayoutAttributeWidth anotherAttr:NSLayoutAttributeWidth offset:0]];
    [self.view addConstraint:[AutoLayoutHelper viewEqualsToNumber:color_band_view number:158 attr:NSLayoutAttributeHeight]];
    
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:color_band_hint_button another:self.view attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeLeft offset:100]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:color_band_hint_button another:color_band_view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:10]];
    
    for (int i=0; i<color_button_num-1; i++)
    {
        UIButton* buttoni = (UIButton*)m_color_buttons[i];
        UIButton* buttonj = (UIButton*)m_color_buttons[i+1];
        [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:buttonj another:buttoni attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeRight offset:11]];
        [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:buttonj another:buttoni attr:NSLayoutAttributeBottom anotherAttr:NSLayoutAttributeBottom offset:0]];
    }
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:(UIButton*)m_color_buttons[0] another:self.view attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeLeft offset:100]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:(UIButton*)m_color_buttons[0] another:color_band_view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:48]];
    
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:share_button another:(UIButton*)m_color_buttons[color_button_num-1] attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeRight offset:90]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:dulux_icon another:share_button attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeRight offset:50]];
    
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:(UIButton*)share_button another:color_band_view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:44]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:dulux_icon another:color_band_view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:28]];
    
    
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:left_button another:self.view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:263]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:left_button another:self.view attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeLeft offset:0]];
    
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:right_button another:self.view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:263]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:right_button another:self.view attr:NSLayoutAttributeRight anotherAttr:NSLayoutAttributeRight offset:0]];
    
    
    [self initNavigateButtons];
    
    [self initSwipeRecognizers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIColor*) getColorByButtonIndex:(int)index
{
    UIImageView* color_button = m_color_buttons[index];
    UIColor* color = [color_button.image colorAtPixel:CGPointMake(10, 10)];
    return color;
}

-(UIColor*) getColorByColorButton:(UIImageView*)colorButton
{
   UIImage* image = colorButton.image;
   UIColor* color = [image colorAtPixel:CGPointMake(10, 10)];
   float r,g,b,a;
   [color getRed:&r green:&g blue:&b alpha:&a];
   return color;
}

-(UIImage*) getFinalImage
{
    UIImage* back_image = m_back_image_view.image;
    
    UIImage* final_image = back_image;
    for (int i=0; i<m_wall_views.count; i++)
    {
        UIImageView* wall_view = m_wall_views[i];
        final_image = [final_image imageWithAnotherImageOn:wall_view.image blendMode:kCGBlendModeNormal];
    }
    
    final_image = [final_image imageWithAnotherImageOn:m_floating_image_view.image blendMode:kCGBlendModeNormal];
    
    return final_image;
}



-(void) dragView:(UIDraggableView*)dragView startDragAtParentViewPoint:(CGPoint)pt
{
    m_previous_wall_index = -1;
   
   if (m_paint_tool_view)
   {
      [m_paint_tool_view removeFromSuperview];
   }
   
   UIColor* color = [self getColorByColorButton:dragView];
   
    UIImage* body_image = [UIImage imageNamed:@"paint-tool-small-body.png"];
    UIImage* head_image = [UIImage imageNamed:@"paint-tool-small-head.png"];
    UIImage* head_color_image = [head_image imageWithGradientTintColor:color];
    UIImage* image = [body_image imageWithAnotherImageOn:head_color_image blendMode:kCGBlendModeNormal];
    
    m_paint_tool_view = [[UIImageView alloc] initWithImage:image];
    
   m_paint_tool_view.frame = dragView.frame;
   //m_paint_tool_view.frame = CGRectMake(dragView.frame.origin.x, dragView.frame.origin.y-40, dragView.frame.size.width/2, dragView.frame.size.height/2);
   //m_paint_tool_view.layer.borderColor = [UIColor blackColor].CGColor;
   //m_paint_tool_view.layer.borderWidth = 1;
    [self.view addSubview:m_paint_tool_view];
   
   [self disableRecognizers];
   
   /*bool isTransparent1 = [m_paint_tool_view.image isPointTransparent:CGPointMake(20, 20)];
   isTransparent1 = [m_paint_tool_view.image isPointTransparent:CGPointMake(140, 20)];
   isTransparent1 = [m_paint_tool_view.image isPointTransparent:CGPointMake(140, 140)];
   isTransparent1 = [m_paint_tool_view.image isPointTransparent:CGPointMake(20, 140)];
   
   UIImage* wall_image = [UIImage imageNamed:@"seri1-room3-wall1.png"];
   bool isTransparent2 = [wall_image isPointTransparent:CGPointMake(150, 150)];
   isTransparent2 = [wall_image isPointTransparent:CGPointMake(500, 500)];
   
   bool intersect = [self isViewIntersects:m_paint_tool_view withAnother:m_wall_views[0] ];
   int mm=0;*/
}

-(bool) isViewIntersects:(UIImageView*)view1 withAnother:(UIImageView*)view2
{
   CGSize iSize1 = view1.image.size;
   CGSize bSize1 = view1.frame.size;

   double width_scale1 = iSize1.width / bSize1.width;
   double height_scale1 = iSize1.height / bSize1.height;
   
   CGPoint point1;
   if (m_paint_tool_view_opaque_pts == nil)
   {
      m_paint_tool_view_opaque_pts = [[NSMutableArray alloc] init];
      
      for (int i=0; i<view1.frame.size.width; i++)
      {
         for (int j=0; j<view1.frame.size.height; j++)
         {
            point1.x = i;
            point1.y = j;
            point1.x *= ((bSize1.width != 0) ? width_scale1 : 1);
            point1.y *= ((bSize1.height != 0) ? height_scale1 : 1);
            
            bool isTransparent1 = [view1.image isPointTransparent:point1];
            if (!isTransparent1)
            {
               [m_paint_tool_view_opaque_pts addObject:[NSValue valueWithCGPoint:CGPointMake(i, j)]];
            }
         }
      }
   }
   
    /*int color_button_index = 0;
    for (int i=0; i<m_wall_views.count; i++)
    {
        if (view2 == m_wall_views[i])
        {
            color_button_index = i;
            break;
        }
    }
   NSString* wall_pic = [NSString stringWithFormat:@"seri%d-room%d-wall%d.png", self.seriIndex+1, self.roomIndex+1, color_button_index+1];
   UIImage* wall_white_image = [UIImage imageNamed:wall_pic];*/
   
   UIImage* image2 = view2.image;//
   
   //CGSize iSize2 = image2.size;
   //CGSize bSize2 = view2.frame.size;
   
   //double width_scale2 = iSize2.width / bSize2.width;
   //double height_scale2 = iSize2.height / bSize2.height;
   
   CGPoint point2;
   for (int i=0; i<m_paint_tool_view_opaque_pts.count; i++)
   {
      point1 = [m_paint_tool_view_opaque_pts[i] CGPointValue];
      point2 = point1;
      
      point2.x = (point1.x + view1.frame.origin.x - view2.frame.origin.x);
      point2.y = (point1.y + view1.frame.origin.y - view2.frame.origin.y);
      /*point2.x *= ((bSize2.width != 0) ? width_scale2 : 1);
      point2.y *= ((bSize2.height != 0) ? height_scale2 : 1);
      
      if (point2.x < 0 || point2.y < 0 || point2.x > image2.size.width || point2.y > image2.size.height)
      {
         continue;
      }*/
       
       bool isTransparent2 = [image2 isPointTransparent:point2];
       if (!isTransparent2)
       {
           return true;
       }
       
      /*if (trunc(point2.x) == 134 && trunc(point2.y) == 170 && trunc(point1.x) == 50 && trunc(point1.y) == 50)
      {
         int mm=0;
      }
      isTransparent2 = [image2 isPointTransparent:point2];
      
      point1.x *= ((bSize1.width != 0) ? width_scale1 : 1);
      point1.y *= ((bSize1.height != 0) ? height_scale1 : 1);
      
      bool isTransparent1 = [view1.image isPointTransparent:point1];
      
      UIImage* image = [UIImage imageNamed:@"button-normal"];
      bool isTransparent1_temp = [image isPointTransparent:point1];
      
      if (isTransparent1 != isTransparent1_temp || isTransparent1 == true) {
         NSLog(@"wrong ........");
      }*/
   }
   return false;
}

-(bool) isViewIntersects:(UIImageView*)view withPt:(CGPoint)pt
{
   bool isTransparent = [view.image isPointTransparent:pt];
   if (!isTransparent)
   {
      return true;
   }
   return false;
}

-(void) dragView:(UIDraggableView*)dragView draggingAtParentViewPoint:(CGPoint)pt previousPoint:(CGPoint)previousPt
{
    m_is_dragging_color_button = true;
   
   //drag the tool itself
   m_paint_tool_view.frame = CGRectOffset(m_paint_tool_view.frame, pt.x-previousPt.x, pt.y- previousPt.y);
    
   UIColor* color = [self getColorByColorButton:dragView];
    
    int mode = 0;
    if (mode == 0)//mouse center touches the wall
    {
        int wall_index = -1;
        for (int i=0; i<m_wall_views.count; i++)
        {
            UIImageView* wall_view = m_wall_views[i];
            if ([self isViewIntersects:wall_view withPt:pt ])
            {
                wall_index = i;
                break;
            }
        }
        
        NSLog(@"pt=(%.1f,%.1f), wall_index=%d", pt.x, pt.y, wall_index);
        
        if(m_previous_wall_index != wall_index)
        {
            /*if (m_previous_wall_index >= 0)
             {
             NSString* previous_wall_pic = [NSString stringWithFormat:@"seri%d-room%d-wall%d.png", self.seriIndex+1, self.roomIndex+1, m_previous_wall_index+1];
             UIImage* previous_wall_white_image = [UIImage imageNamed:previous_wall_pic];
             UIImageView* previous_wall = m_wall_views[m_previous_wall_index];
             previous_wall.image = previous_wall_white_image;
             }*/
            if (wall_index >= 0)
            {
                NSString* wall_pic = [NSString stringWithFormat:@"seri%d-room%d-wall%d.png", self.seriIndex+1, self.roomIndex+1, wall_index+1];
                UIImage* wall_white_image = [UIImage imageNamed:wall_pic];
                UIImageView* wall = m_wall_views[wall_index];
                wall.image = [wall_white_image imageWithGradientTintColor:color];
            }
            else
            {
                //NSString* wall_pic = [NSString stringWithFormat:@"seri%d-room%d-wall%d.png", self.seriIndex+1, self.roomIndex+1, wall_index+1];
                //UIImage* wall_white_image = [UIImage imageNamed:wall_pic];
                //UIImageView* wall = m_wall_views[wall_index];
            }
        }
        m_previous_wall_index = wall_index;
    }
    else//the paint head touches the wall
    {
        int wall_index = -1;
        for (int i=0; i<m_wall_views.count; i++)
        {
            UIImageView* wall_view = m_wall_views[i];
            
            if ([self isViewIntersects:m_paint_tool_view withAnother:wall_view ])
            {
               wall_index = i;
                NSLog(@"pt=(%.1f,%.1f), wall_index=%d", pt.x, pt.y, wall_index);
                
                NSString* wall_pic = [NSString stringWithFormat:@"seri%d-room%d-wall%d.png", self.seriIndex+1, self.roomIndex+1, wall_index+1];
                UIImage* wall_white_image = [UIImage imageNamed:wall_pic];
                UIImageView* wall = m_wall_views[wall_index];
                wall.image = [wall_white_image imageWithGradientTintColor:color];
                break;
            }
        }
    }
 }

-(void) dragView:(UIDraggableView*)dragView dropAtParentViewPoint:(CGPoint)pt
{
    m_is_dragging_color_button = false;
   
   if (m_paint_tool_view)
   {
      [m_paint_tool_view removeFromSuperview];
   }
    
    [self enableRecognizers];
}

- (void) colorButtonClicked:(id)sender
{
    UIButton* button = sender;
    UIImage* image = [button imageForState:UIControlStateNormal];
    UIColor* color = [image colorAtPixel:CGPointMake(10, 10)];
    float r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    int wall_index = 2;
    NSString* wall_pic = [NSString stringWithFormat:@"seri%d-room%d-wall%d.png", self.seriIndex+1, self.roomIndex+1, wall_index+1];
    UIImage* wall_white_image = [UIImage imageNamed:wall_pic];
    
    UIImageView* wall = m_wall_views[wall_index];
    wall.image = [wall_white_image imageWithGradientTintColor:color];
}

- (void)handleTap:(UITapGestureRecognizer *)tapRecognizer
{
    for (int i=0; i<m_button_views.count; i++)
    {
        UIView* button = m_button_views[i];
        if (button == tapRecognizer.view)
        {
            NSString* pic_name = m_colored_room_picture_names[i];
            m_image_view_room.image = [UIImage imageNamed:pic_name];
            break;
        }
    }
}

- (void) clearView
{
    NSArray* sub_views = self.view.subviews;
    for (int i=0; i<sub_views.count; i++)
    {
        UIView* view = sub_views[i];
        [view removeFromSuperview];
    }
    [self clearRecognizers];
    
    m_wall_views = [[NSMutableArray alloc] init];
    m_wall_color_button_indexs = [[NSMutableArray alloc] init];
    m_is_dragging_color_button = false;
    m_previous_wall_index = -1;
    
    m_color_buttons = [[NSMutableArray alloc] init];
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

- (void) clearRecognizers
{
    for (int i=0; i<self.view.gestureRecognizers.count; i++)
    {
        UIGestureRecognizer* recognizer = self.view.gestureRecognizers[i];
        [self.view removeGestureRecognizer:recognizer];
    }
}

- (void) disableRecognizers
{
    for (int i=0; i<self.view.gestureRecognizers.count; i++)
    {
        UIGestureRecognizer* recognizer = self.view.gestureRecognizers[i];
        recognizer.enabled = false;
    }
}


- (void) enableRecognizers
{
    for (int i=0; i<self.view.gestureRecognizers.count; i++)
    {
        UIGestureRecognizer* recognizer = self.view.gestureRecognizers[i];
        recognizer.enabled = true;
    }
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)swipeRecognizer
{
    if (m_is_dragging_color_button)
    {
        return;
    }
    self.roomIndex = (self.roomIndex-1+3) % 3;
    [self reInitSubViews:InitReason_GoLeft];
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)swipeRecognizer
{
    if (m_is_dragging_color_button)
    {
        return;
    }
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




- (void) shareButtonClicked:(id)sender
{
    UIActionSheet *action_sheet = [[UIActionSheet alloc] init];
                                  /*initWithTitle:@"选择分享平台"
                                  delegate:self
                                  cancelButtonTitle:@"新浪微博"
                                  destructiveButtonTitle:@"腾讯微博"
                                  otherButtonTitles:@"微信朋友圈", nil];*/
    action_sheet.delegate = self;
    action_sheet.title = @"选择分享平台";
    [action_sheet addButtonWithTitle:@"新浪微博"];
    [action_sheet addButtonWithTitle:@"腾讯微博"];
    [action_sheet addButtonWithTitle:@"微信朋友圈"];
    action_sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [action_sheet showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self shareToSinaWeibo:self.view];
    }
    else if(buttonIndex == 1) {
        [self shareToTencentWeibo:self.view];
    }
    else if(buttonIndex == 2) {
        [self shareToWeixinTimeline:self.view];
    }
}
- (void) actionSheetCancel:(UIActionSheet *)actionSheet{
    
}

-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
}

-(void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex{
    
}


-(id) getOneKeyShareList
{
    NSMutableArray* array = [[NSMutableArray alloc] initWithObjects:
                             /*SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                             SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                             SHARE_TYPE_NUMBER(ShareTypeRenren),*/
                             nil];
    return array;
                              
    /*NSMutableArray* array = [[NSMutableArray alloc] initWithObjects:
                             
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                              @"type",
                              [NSNumber numberWithBool:NO],
                              @"selected",
                              nil],
                             
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                              @"type",
                              [NSNumber numberWithBool:NO],
                              @"selected",
                              nil],
                             
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:
                              SHARE_TYPE_NUMBER(ShareTypeRenren),
                              @"type",
                              [NSNumber numberWithBool:NO],
                              @"selected",
                              nil],
                             
                             nil];
    
    
    
    return array;*/
}

-(void) showShareStatus:(NSString*)status
{
    //对话框的创建和定时器的初始化
    m_alert_view = [[UIAlertView alloc] initWithTitle:@"" message:status delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [m_alert_view show];
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

//timer的执行事件
- (void)onTimer
{
    [m_alert_view dismissWithClickedButtonIndex:0 animated:NO];  //退出对话框
}

- (void) ShareToSinaWeiboWithOther:(id)sender
{
    Weibo *weibo = [[Weibo alloc] initWithAppKey:@"568898243" withAppSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"];
    
    [Weibo setWeibo:weibo];
    // Override point for customization after application launch.
    
    if (weibo.isAuthenticated) {
        [weibo signOut];
    }
    
    if (![Weibo.weibo isAuthenticated]) {
        
        [Weibo.weibo authorizeWithCompleted:^(WeiboAccount *account, NSError *error) {
            if (!error) {
                NSLog(@"Sign in successful: %@", account.user.screenName);
                
                NSData *img = UIImagePNGRepresentation([UIImage imageNamed:@"final-seri1.jpg"]);
                [weibo newStatus:@"test weibo with image" pic:img completed:^(Status *status, NSError *error) {
                    if (error) {
                        NSLog(@"failed to upload:%@", error);
                    }
                    else {
                        StatusImage *statusImage = [status.images objectAtIndex:0];
                        NSLog(@"success: %lld.%@.%@", status.statusId, status.text, statusImage.originalImageUrl);
                    }
                }];
            }
            else {
                NSLog(@"Failed to sign in: %@", error);
            }
        }];
    }
    
    if (weibo.isAuthenticated) {
        NSLog(@"current user: %@", weibo.currentAccount.user.name);
        /*
         [weibo newStatus:@"test weibo" pic:nil completed:^(Status *status, NSError *error) {
         if (error) {
         NSLog(@"failed to post:%@", error);
         }
         else {
         NSLog(@"success: %lld.%@", status.statusId, status.text);
         }
         }];
         
         NSData *img = UIImagePNGRepresentation([UIImage imageNamed:@"Icon"]);
         [weibo newStatus:@"test weibo with image" pic:img completed:^(Status *status, NSError *error) {
         if (error) {
         NSLog(@"failed to upload:%@", error);
         }
         else {
         StatusImage *statusImage = [status.images objectAtIndex:0];
         NSLog(@"success: %lld.%@.%@", status.statusId, status.text, statusImage.originalImageUrl);
         }
         }];
         */
    }
}


- (void)shareToSinaWeiboWithCustomUI:(id)sender
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"final-seri1" ofType:@"jpg"];
    id<ISSCAttachment> share_image_attachment = [ShareSDK imageWithPath:imagePath];
    UIImage* share_image = [self getFinalImage];

    
    AGCustomShareViewController *vc = [[AGCustomShareViewController alloc] initWithImage:share_image content:@"多乐士臻彩时尚旅程"];
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:vc];
    
    naVC.modalPresentationStyle = UIModalPresentationFormSheet;
    //[self presentModalViewController:naVC animated:YES];
    
    [self presentViewController:naVC animated:true completion:nil];
}

- (void) shareToSinaWeibo:(id)sender
{
    //[self showShareStatus:@"分享微博成功"];
    //return;
    
   //创建分享内容
   NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"final-seri1" ofType:@"jpg"];
    id<ISSCAttachment> share_image_attachment = [ShareSDK imageWithPath:imagePath];
    UIImage* share_image = [self getFinalImage];
    share_image_attachment = [ShareSDK jpegImageWithImage:share_image quality:1.0];
   id<ISSContent> publishContent = [ShareSDK content:@"多乐士臻彩时尚旅程"
                                      defaultContent:@""
                                               image:share_image_attachment
                                               title:nil
                                                 url:nil
                                         description:nil
                                           mediaType:SSPublishContentMediaTypeText];
   
   //创建弹出菜单容器
   id<ISSContainer> container = [ShareSDK container];
   [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
   
   id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                        allowCallback:YES
                                                        authViewStyle:SSAuthViewStyleFullScreenPopup
                                                         viewDelegate:nil
                                              authManagerViewDelegate:m_app_delegate.viewDelegate];
   //在授权页面中添加关注官方微博
   /*[authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
    nil]];*/
   
   //显示分享菜单
   [ShareSDK showShareViewWithType:ShareTypeSinaWeibo
                         container:container
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                          oneKeyShareList:[self getOneKeyShareList]//nil//[NSArray defaultOneKeyShareList]
                                                           qqButtonHidden:YES
                                                    wxSessionButtonHidden:YES
                                                   wxTimelineButtonHidden:YES
                                                     showKeyboardOnAppear:NO
                                                        shareViewDelegate:m_app_delegate.viewDelegate
                                                      friendsViewDelegate:m_app_delegate.viewDelegate
                                                    picViewerViewDelegate:nil]
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                
                               if (state == SSPublishContentStateSuccess)
                               {
                                  NSLog(@"分享微博成功");
                                   //[ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
                                   [self showShareStatus:@"分享微博成功"];
                               }
                               else if (state == SSPublishContentStateFail)
                               {
                                  NSLog(@"分享微博失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                   //[ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
                                   [self showShareStatus:@"分享微博失败"];
                               }
                            }];
}

- (void) shareToTencentWeibo:(id)sender
{
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"room1colored" ofType:@"png"];
    id<ISSContent> publishContent = [ShareSDK content:@"test1"
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:nil
                                                  url:nil
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeText];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:m_app_delegate.viewDelegate];
    //在授权页面中添加关注官方微博
    /*[authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
     [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
     SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
     [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
     SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
     nil]];*/
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeTencentWeibo
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[self getOneKeyShareList]//nil//[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:YES
                                                     wxSessionButtonHidden:YES
                                                    wxTimelineButtonHidden:YES
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:m_app_delegate.viewDelegate
                                                       friendsViewDelegate:m_app_delegate.viewDelegate
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(@"发表成功");
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                 }
                             }];
}

- (void) shareToRenRenWeibo:(id)sender
{
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"room1colored" ofType:@"png"];
    id<ISSContent> publishContent = [ShareSDK content:@"test1"
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"ShareSDK"
                                                  url:@"http://www.sharesdk.cn"
                                          description:@"Hello 人人网"
                                            mediaType:SSPublishContentMediaTypeText];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:m_app_delegate.viewDelegate];
    //在授权页面中添加关注官方微博
    /*[authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
     [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
     SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
     [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
     SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
     nil]];*/
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeRenren
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[self getOneKeyShareList]//[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:YES
                                                     wxSessionButtonHidden:YES
                                                    wxTimelineButtonHidden:YES
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:m_app_delegate.viewDelegate
                                                       friendsViewDelegate:m_app_delegate.viewDelegate
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(@"发表成功");
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                 }
                             }];
    
    
}

- (void)shareToWeixinTimeline:(id)sender
{
    //创建分享内容
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"room1colored" ofType:@"png"];
    id<ISSContent> publishContent = [ShareSDK content:@"test1"
                                       defaultContent:@"test1"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"ShareSDK"
                                                  url:@"http://www.sharesdk.cn"
                                          description:@"Hello 人人网"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:m_app_delegate.viewDelegate];
    
    //在授权页面中添加关注官方微博
    /*[authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];*/
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeWeixiTimeline
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[self getOneKeyShareList]//[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:YES
                                                     wxSessionButtonHidden:YES
                                                    wxTimelineButtonHidden:YES
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:m_app_delegate.viewDelegate
                                                       friendsViewDelegate:m_app_delegate.viewDelegate
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(@"发表成功");
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                 }
                             }];
}

@end
