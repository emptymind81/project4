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
        m_wall_views = [[NSMutableArray alloc] init];
        m_wall_color_button_indexs = [[NSMutableArray alloc] init];
        m_is_dragging_color_button = false;
        m_previous_wall_index = -1;
        
        m_color_buttons = [[NSMutableArray alloc] init];
        
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
    if (floating_image)
    {
        UIImageView* floating_image_view = [[UIImageView alloc] initWithImage:floating_image];
        //[self.view addSubview:floating_image_view];
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
    color_band_view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:color_band_view];
    
    NSString* color_band_hint_pic = @"pushcolorbuttonhinttext.png";
    UIImageView* color_band_hint_button = [[UIImageView alloc] initWithImage:[UIImage imageNamed:color_band_hint_pic]];
    [self.view addSubview:color_band_hint_button];
    
    m_color_buttons = [[NSMutableArray alloc] init];
    int color_button_num = 5;
    for (int i=0; i<color_button_num; i++)
    {
        NSString* color_button_pic = [NSString stringWithFormat:@"seri%d-colorbutton%d.png", self.seriIndex+1, i+1];
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
    [share_button addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:share_button];
    
    NSString* dulux_icon_pic = @"duluxicon.png";
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
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:color_band_view another:self.view attr:NSLayoutAttributeBottom anotherAttr:NSLayoutAttributeBottom offset:-75]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:color_band_view another:self.view attr:NSLayoutAttributeWidth anotherAttr:NSLayoutAttributeWidth offset:0]];
    [self.view addConstraint:[AutoLayoutHelper viewEqualsToNumber:color_band_view number:130 attr:NSLayoutAttributeHeight]];
    
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:color_band_hint_button another:self.view attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeLeft offset:100]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:color_band_hint_button another:color_band_view attr:NSLayoutAttributeTop anotherAttr:NSLayoutAttributeTop offset:5]];
    
    for (int i=0; i<color_button_num-1; i++)
    {
        UIButton* buttoni = (UIButton*)m_color_buttons[i];
        UIButton* buttonj = (UIButton*)m_color_buttons[i+1];
        [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:buttonj another:buttoni attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeRight offset:15]];
        [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:buttonj another:buttoni attr:NSLayoutAttributeBottom anotherAttr:NSLayoutAttributeBottom offset:0]];
    }
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:(UIButton*)m_color_buttons[0] another:self.view attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeLeft offset:100]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:(UIButton*)m_color_buttons[0] another:self.view attr:NSLayoutAttributeBottom anotherAttr:NSLayoutAttributeBottom offset:-85]];
    
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:share_button another:(UIButton*)m_color_buttons[color_button_num-1] attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeRight offset:25]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:dulux_icon another:share_button attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeRight offset:25]];
    
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:(UIButton*)m_color_buttons[0] another:share_button attr:NSLayoutAttributeBottom anotherAttr:NSLayoutAttributeBottom offset:-10]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:dulux_icon another:share_button attr:NSLayoutAttributeBottom anotherAttr:NSLayoutAttributeBottom offset:0]];
    
    
    [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:left_button another:self.view attr:NSLayoutAttributeCenterY anotherAttr:NSLayoutAttributeCenterY]];
    [self.view addConstraint:[AutoLayoutHelper viewOffsetsToAnother:left_button another:self.view attr:NSLayoutAttributeLeft anotherAttr:NSLayoutAttributeLeft offset:0]];
    
    [self.view addConstraint:[AutoLayoutHelper viewEqualsToAnother:right_button another:self.view attr:NSLayoutAttributeCenterY anotherAttr:NSLayoutAttributeCenterY]];
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
    UIDraggableView* color_button = m_color_buttons[index];
    UIColor* color = [color_button.image colorAtPixel:CGPointMake(10, 10)];
    return color;
}

-(void) dragView:(UIDraggableView*)dragView startDragAtParentViewPoint:(CGPoint)pt
{
    m_previous_wall_index = -1;
}

-(void) dragView:(UIDraggableView*)dragView draggingAtParentViewPoint:(CGPoint)pt
{
    /*int color_button_index = 0;
    for (int i=0; i<m_wall_views.count; i++)
    {
        if (dragView == m_wall_views[i])
        {
            color_button_index = i;
            break;
        }
    }*/
    
    m_is_dragging_color_button = true;
    
    UIImage* image = dragView.image;
    UIColor* color = [image colorAtPixel:CGPointMake(10, 10)];
    float r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    int wall_index = -1;
    for (int i=0; i<m_wall_views.count; i++)
    {
        UIImageView* wall_view = m_wall_views[i];
        UIImage* image = wall_view.image;
        
        NSString* wall_pic = [NSString stringWithFormat:@"seri%d-room%d-wall%d.png", self.seriIndex+1, self.roomIndex+1, i+1];
        UIImage* wall_white_image = [UIImage imageNamed:wall_pic];
        
        bool isTransparent = [wall_white_image isPointTransparent:pt];
        if (!isTransparent)
        {
            wall_index = i;
            break;
        }
        else
        {
            int mm=0;
        }
        /*UIColor* color = [image colorAtPixel:pt];
        float r,g,b,a;
        [color getRed:&r green:&g blue:&b alpha:&a];
        if (a >= 0.001f)
        {
            wall_index = i;
            break;
        }*/
    }
    
    NSLog(@"pt=(%.1f,%.1f), wall_index=%d", pt.x, pt.y, wall_index);
    
    if(m_previous_wall_index != wall_index)
    {
        if (m_previous_wall_index >= 0)
        {
            NSString* previous_wall_pic = [NSString stringWithFormat:@"seri%d-room%d-wall%d.png", self.seriIndex+1, self.roomIndex+1, m_previous_wall_index+1];
            UIImage* previous_wall_white_image = [UIImage imageNamed:previous_wall_pic];
            UIImageView* previous_wall = m_wall_views[m_previous_wall_index];
            previous_wall.image = previous_wall_white_image;
        }
        if (wall_index >= 0)
        {
            NSString* wall_pic = [NSString stringWithFormat:@"seri%d-room%d-wall%d.png", self.seriIndex+1, self.roomIndex+1, wall_index+1];
            UIImage* wall_white_image = [UIImage imageNamed:wall_pic];
            UIImageView* wall = m_wall_views[wall_index];
            wall.image = [wall_white_image imageWithGradientTintColor:color];
        }
        else
        {
            NSString* wall_pic = [NSString stringWithFormat:@"seri%d-room%d-wall%d.png", self.seriIndex+1, self.roomIndex+1, wall_index+1];
            UIImage* wall_white_image = [UIImage imageNamed:wall_pic];
            UIImageView* wall = m_wall_views[wall_index];
        }
    }
    
    
    m_previous_wall_index = wall_index;
}

-(void) dragView:(UIDraggableView*)dragView dropAtParentViewPoint:(CGPoint)pt
{
    m_is_dragging_color_button = false;
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

- (void) shareToSinaWeibo:(id)sender
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
                                  NSLog(@"发表成功");
                               }
                               else if (state == SSPublishContentStateFail)
                               {
                                  NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
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
