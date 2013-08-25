//
//  AGCustomShareViewController.m
//  AGShareSDKDemo
//
//  Created by 冯 鸿杰 on 13-3-5.
//  Copyright (c) 2013年 vimfung. All rights reserved.
//

#import "AGCustomShareViewController.h"
//#import "AGCustomAtPlatListViewController.h"
#import <AGCommon/UIImage+Common.h>
#import <AGCommon/UIDevice+Common.h>
#import <AGCommon/UINavigationBar+Common.h>
#import <AGCommon/UIColor+Common.h>
#import "AppDelegate.h"
#import "UIView+Common.h"
#import "AGCustomFriendsViewController.h"

#import "WeiboSDK.h"
#import "Weibo.h"

#define IMAGE_WIDTH 80.0
#define IMAGE_HEIGHT 80.0
#define IMAGE_LANDSCAPE_WIDTH 50.0
#define IMAGE_LANDSCAPE_HEIGHT 50.0

#define TOOLBAR_HEIGHT 0

#define PADDING_LEFT 1.0
#define PADDING_TOP 1.0
#define PADDING_RIGHT 1.0
#define PADDING_BOTTOM 2.0
#define HORIZONTAL_GAP 2.0
#define VERTICAL_GAP 5.0

#define IMAGE_PADDING_TOP 19
#define IMAGE_PADDING_RIGHT 10

#define PIN_PADDING_TOP 4

#define AT_BUTTON_PADDING_LEFT 9
#define AT_BUTTON_PADDING_BOTTOM 6
#define AT_BUTTON_WIDTH 34
#define AT_BUTTON_HEIGHT 0
#define AT_BUTTON_HORIZONTAL_GAP 9.0

#define WORD_COUNT_LABEL_PADDING_RIGHT 10
#define WORD_COUNT_LABEL_PADDING_BOTTOM 19

@implementation AGCustomShareViewController
{
    
    UIAlertView* m_alert_view;
}

-(int) width
{
    return self.view.frame.size.width;
}
-(int) height
{
    return self.view.frame.size.height;
}

- (id)initWithImage:(UIImage *)image
            content:(NSString *)content
{
    self = [self init];
    if (self)
    {
        _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _image = image;
        _content = content;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //self.view.backgroundColor = [UIColor whiteColor];
        
        UIButton *leftBtn = [[UIButton alloc] init];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"NavigationButtonBG.png"]
                           forState:UIControlStateNormal];
        [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        leftBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        leftBtn.frame = CGRectMake(0.0, 0.0, 53.0, 30.0);
        [leftBtn addTarget:self action:@selector(cancelButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        
        UIButton *rightBtn = [[UIButton alloc] init];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"NavigationButtonBG.png"]
                            forState:UIControlStateNormal];
        [rightBtn setTitle:@"发布" forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        rightBtn.frame = CGRectMake(0.0, 0.0, 53.0, 30.0);
        [rightBtn addTarget:self action:@selector(publishButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        
        if ([UIDevice currentDevice].isPad)
        {
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.shadowColor = [UIColor grayColor];
            label.font = [UIFont systemFontOfSize:22];
            self.navigationItem.titleView = label;
        }
        
        self.title = @"内容分享";
    }
    return self;
}

- (void)dealloc
{
    _picImageView = nil;
    _textView = nil;
    //_toolbar = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    ((UILabel *)self.navigationItem.titleView).text = title;
    [self.navigationItem.titleView sizeToFit];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowHandler:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideHandler:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _contentBG = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SharePanelBG.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:11]];
    _contentBG.frame = CGRectMake(PADDING_LEFT, PADDING_TOP, self.width - PADDING_LEFT - PADDING_RIGHT, self.height - TOOLBAR_HEIGHT - VERTICAL_GAP - PADDING_BOTTOM);
    _contentBG.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_contentBG];
    CGRect temp = _contentBG.frame;
    
    _toolbarBG = [[UIImageView alloc] initWithImage:nil];
    _toolbarBG.frame = CGRectMake(PADDING_LEFT + 1, _contentBG.bottom + VERTICAL_GAP, self.width - PADDING_LEFT - PADDING_RIGHT - 2, TOOLBAR_HEIGHT);
    _toolbarBG.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_toolbarBG];
	
    //图片
    _picBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ShareImageBG.png"]];
    _picBG.frame = CGRectMake(self.width - IMAGE_PADDING_RIGHT - _picBG.width, IMAGE_PADDING_TOP, _picBG.width, _picBG.height);
    _picBG.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:_picBG];
    
    _picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_picBG.left + 3, _picBG.top + 3, _picBG.width - 6, _picBG.height - 6)];
    _picImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    _picImageView.image = _image;
    [self.view addSubview:_picImageView];
    
    _pinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SharePin.png"]];
    _pinImageView.frame = CGRectMake(self.width - _pinImageView.width, PIN_PADDING_TOP, _pinImageView.width, _pinImageView.height);
    _pinImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:_pinImageView];
    
    //文本框
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(PADDING_LEFT,
                                                             PADDING_TOP + 1,
                                                             _picBG.left - HORIZONTAL_GAP - PADDING_LEFT,
                                                             _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT - VERTICAL_GAP - 1)];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.font = [UIFont systemFontOfSize:18.0];
    _textView.text = _content;
    _textView.delegate = self;
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_textView];
    
    if (!_image)
    {
        _picBG.hidden = YES;
        _picImageView.hidden = YES;
        _pinImageView.hidden = YES;
        _textView.frame = CGRectMake(PADDING_LEFT,
                                     PADDING_TOP + 1,
                                     _contentBG.right - PADDING_RIGHT - PADDING_LEFT,
                                     _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT - VERTICAL_GAP - 1);
    }
    
    //工具栏
    /*_toolbar = [[AGCustomShareViewToolbar alloc] initWithFrame:CGRectMake(_toolbarBG.left + 2, _toolbarBG.top, _toolbarBG.width - 4, _toolbarBG.height)];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:_toolbar];
    */
    
    _atButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_atButton setBackgroundImage:[UIImage imageNamed:@"atButton.png"] forState:UIControlStateNormal];
    _atButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _atButton.frame = CGRectMake(_contentBG.left + AT_BUTTON_PADDING_LEFT, _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT, AT_BUTTON_WIDTH, AT_BUTTON_HEIGHT);
    [_atButton addTarget:self action:@selector(addbuttonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_atButton];
    
    _atTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _atTipsLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _atTipsLabel.backgroundColor = [UIColor clearColor];
    _atTipsLabel.textColor = [UIColor colorWithRGB:0xd2d2d2];
    _atTipsLabel.text = @"提醒微博好友查看";
    _atTipsLabel.font = [UIFont boldSystemFontOfSize:12];
    [_atTipsLabel sizeToFit];
    _atTipsLabel.frame = CGRectMake(_atButton.right + AT_BUTTON_HORIZONTAL_GAP,
                                    _atButton.top + (_atButton.height - _atTipsLabel.height) / 2,
                                    _atTipsLabel.width,
                                    AT_BUTTON_HEIGHT/*_atTipsLabel.height*/);
    [self.view addSubview:_atTipsLabel];
    
    //字数
    _wordCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _wordCountLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _wordCountLabel.backgroundColor = [UIColor clearColor];
    _wordCountLabel.textColor = [UIColor colorWithRGB:0xd2d2d2];
    _wordCountLabel.text = @"140";
    _wordCountLabel.font = [UIFont boldSystemFontOfSize:16];
    [_wordCountLabel sizeToFit];
    _wordCountLabel.frame = CGRectMake(_contentBG.right - WORD_COUNT_LABEL_PADDING_RIGHT - _wordCountLabel.width,
                                       _contentBG.bottom - WORD_COUNT_LABEL_PADDING_BOTTOM - _wordCountLabel.height,
                                       _wordCountLabel.width,
                                       _wordCountLabel.height);
    [self.view addSubview:_wordCountLabel];
    
    [self updateWordCount];
    [_textView becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutView:self.interfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate
{
    //iOS6下旋屏方法
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    //iOS6下旋屏方法
    return SSInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutView:toInterfaceOrientation];
}

- (void)layoutPortrait
{
    UIButton *btn = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
    btn.frame = CGRectMake(btn.left, btn.top, 55.0, 32.0);
    [btn setBackgroundImage:[UIImage imageNamed:@"NavigationButtonBG.png"]
                   forState:UIControlStateNormal];
    
    if (![UIDevice currentDevice].isPad)
    {
        _toolbarBG.hidden = NO;
        _atTipsLabel.hidden = NO;
        _wordCountLabel.hidden = NO;
        
        _contentBG.frame = CGRectMake(PADDING_LEFT,
                                      PADDING_TOP,
                                      self.width - PADDING_LEFT - PADDING_RIGHT,
                                      self.height - TOOLBAR_HEIGHT - VERTICAL_GAP - PADDING_BOTTOM - _keyboardHeight);
        _toolbarBG.frame = CGRectMake(PADDING_LEFT + 1,
                                      _contentBG.bottom + VERTICAL_GAP,
                                      self.width - PADDING_LEFT - PADDING_RIGHT - 2,
                                      TOOLBAR_HEIGHT);
        
        _textView.frame = CGRectMake(PADDING_LEFT,
                                     PADDING_TOP + 1,
                                     _picBG.left - HORIZONTAL_GAP - PADDING_LEFT,
                                     _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT - VERTICAL_GAP - 1);
        
        //_toolbar.frame = CGRectMake(_toolbarBG.left + 2, _toolbarBG.top, _toolbarBG.width - 4, _toolbarBG.height);
        
        _atButton.frame = CGRectMake(_contentBG.left + AT_BUTTON_PADDING_LEFT, _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT, AT_BUTTON_WIDTH, AT_BUTTON_HEIGHT);
        _atTipsLabel.frame = CGRectMake(_atButton.right + AT_BUTTON_HORIZONTAL_GAP,
                                        _atButton.top + (_atButton.height - _atTipsLabel.height) / 2,
                                        _atTipsLabel.width,
                                        _atTipsLabel.height);
        _wordCountLabel.frame = CGRectMake(_contentBG.right - WORD_COUNT_LABEL_PADDING_RIGHT - _wordCountLabel.width,
                                           _contentBG.bottom - WORD_COUNT_LABEL_PADDING_BOTTOM - _wordCountLabel.height,
                                           _wordCountLabel.width,
                                           _wordCountLabel.height);
    }
}

- (void)layoutLandscape
{
    if (![UIDevice currentDevice].isPad)
    {
        //iPhone
        UIButton *btn = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
        btn.frame = CGRectMake(btn.left, btn.top, 48.0, 24.0);
        [btn setBackgroundImage:[UIImage imageNamed:@"NavigationButtonBG_Landscape.png"]
                       forState:UIControlStateNormal];
        
        if (_keyboardHeight > 0)
        {
            _toolbarBG.hidden = YES;
            _atTipsLabel.hidden = YES;
            _wordCountLabel.hidden = YES;
            
            _contentBG.frame = CGRectMake(PADDING_LEFT,
                                          PADDING_TOP,
                                          self.width - PADDING_LEFT - PADDING_RIGHT,
                                          self.height - PADDING_BOTTOM - _keyboardHeight);
            
            if (_image)
            {
                _textView.frame = CGRectMake(PADDING_LEFT,
                                             PADDING_TOP + 1,
                                             _picBG.left - HORIZONTAL_GAP - PADDING_LEFT,
                                             _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT - VERTICAL_GAP - 1);
            }
            else
            {
                _textView.frame = CGRectMake(PADDING_LEFT,
                                             PADDING_TOP + 1,
                                             _contentBG.right - PADDING_RIGHT - PADDING_LEFT,
                                             _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT - VERTICAL_GAP - 1);
            }
            
            _atButton.frame = CGRectMake(_contentBG.left + AT_BUTTON_PADDING_LEFT, _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT, AT_BUTTON_WIDTH, AT_BUTTON_HEIGHT);
            //_toolbar.frame = CGRectMake(_atButton.right + HORIZONTAL_GAP, _contentBG.bottom - TOOLBAR_HEIGHT,_picBG.left - _atButton.right - 2 *HORIZONTAL_GAP, TOOLBAR_HEIGHT);
        }
        else
        {
            _toolbarBG.hidden = NO;
            _atTipsLabel.hidden = NO;
            _wordCountLabel.hidden = NO;
            
            _contentBG.frame = CGRectMake(PADDING_LEFT,
                                          PADDING_TOP,
                                          self.width - PADDING_LEFT - PADDING_RIGHT,
                                          self.height - TOOLBAR_HEIGHT - VERTICAL_GAP - PADDING_BOTTOM - _keyboardHeight);
            _toolbarBG.frame = CGRectMake(PADDING_LEFT + 1,
                                          _contentBG.bottom + VERTICAL_GAP,
                                          self.width - PADDING_LEFT - PADDING_RIGHT - 2,
                                          TOOLBAR_HEIGHT);
            
            if (_image)
            {
                _textView.frame = CGRectMake(PADDING_LEFT,
                                             PADDING_TOP + 1,
                                             _picBG.left - HORIZONTAL_GAP - PADDING_LEFT,
                                             _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT - VERTICAL_GAP - 1);
            }
            else
            {
                _textView.frame = CGRectMake(PADDING_LEFT,
                                             PADDING_TOP + 1,
                                             _contentBG.right - PADDING_RIGHT - PADDING_LEFT,
                                             _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT - VERTICAL_GAP - 1);
            }
            
            //_toolbar.frame = CGRectMake(_toolbarBG.left + 2, _toolbarBG.top, _toolbarBG.width - 4, _toolbarBG.height);
            
            _atButton.frame = CGRectMake(_contentBG.left + AT_BUTTON_PADDING_LEFT, _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT, AT_BUTTON_WIDTH, AT_BUTTON_HEIGHT);
            _atTipsLabel.frame = CGRectMake(_atButton.right + AT_BUTTON_HORIZONTAL_GAP,
                                            _atButton.top + (_atButton.height - _atTipsLabel.height) / 2,
                                            _atTipsLabel.width,
                                            _atTipsLabel.height);
            _wordCountLabel.frame = CGRectMake(_contentBG.right - WORD_COUNT_LABEL_PADDING_RIGHT - _wordCountLabel.width,
                                               _contentBG.bottom - WORD_COUNT_LABEL_PADDING_BOTTOM - _wordCountLabel.height,
                                               _wordCountLabel.width,
                                               _wordCountLabel.height);
        }
    }
    else
    {
        UIButton *btn = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
        btn.frame = CGRectMake(btn.left, btn.top, 55.0, 32.0);
        [btn setBackgroundImage:[UIImage imageNamed:@"NavigationButtonBG.png"]
                       forState:UIControlStateNormal];
    }
}

- (void)layoutView:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        [self layoutLandscape];
    }
    else
    {
        [self layoutPortrait];
    }
}

#pragma mark - Private

- (void)updateWordCount
{
    NSInteger count = 140 - [_textView.text length];
    _wordCountLabel.text = [NSString stringWithFormat:@"%d", count];
    
    if (count < 0)
    {
        _wordCountLabel.textColor = [UIColor redColor];
    }
    else
    {
        _wordCountLabel.textColor = [UIColor colorWithRGB:0xd2d2d2];
    }
    
    [_wordCountLabel sizeToFit];
    _wordCountLabel.frame = CGRectMake(_contentBG.right - WORD_COUNT_LABEL_PADDING_RIGHT - _wordCountLabel.width,
                                       _contentBG.bottom - WORD_COUNT_LABEL_PADDING_BOTTOM - _wordCountLabel.height,
                                       _wordCountLabel.width,
                                       _wordCountLabel.height);
}

- (void)addbuttonClickHandler:(id)sender
{
    AGCustomFriendsViewController *vc = [[AGCustomFriendsViewController alloc] initWithShareType:ShareTypeSinaWeibo changeHandler:^(NSArray *users, ShareType shareType) {
        
        NSMutableString *usersString = [NSMutableString string];
        for (int i = 0; i < [users count]; i++)
        {
            NSDictionary *userInfo = [users objectAtIndex:i];
            switch (shareType)
            {
                case ShareTypeTwitter:
                {
                    [usersString appendFormat:@" @%@ ", [userInfo objectForKey:@"screen_name"]];
                    break;
                }
                case ShareTypeTencentWeibo:
                {
                    [usersString appendFormat:@" @%@ ", [userInfo objectForKey:@"name"]];
                    break;
                }
                default:
                {
                    [usersString appendFormat:@" @%@ ", [userInfo objectForKey:@"screen_name"]];
                    break;
                }
            }
        }
        
        _textView.text = [_textView.text stringByAppendingString:usersString];
        [self updateWordCount];
        
        [_textView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
    }
    ];
                                         
    [self.navigationController pushViewController:vc animated:YES];
    
    /*AGCustomAtPlatListViewController *vc = [[[AGCustomAtPlatListViewController alloc] initWithChangeHandler:^(NSArray *users, ShareType shareType) {
        NSMutableString *usersString = [NSMutableString string];
        for (int i = 0; i < [users count]; i++)
        {
            NSDictionary *userInfo = [users objectAtIndex:i];
            switch (shareType)
            {
                case ShareTypeTwitter:
                {
                    [usersString appendFormat:@" @%@ ", [userInfo objectForKey:@"screen_name"]];
                    break;
                }
                case ShareTypeTencentWeibo:
                {
                    [usersString appendFormat:@" @%@ ", [userInfo objectForKey:@"name"]];
                    break;
                }
                default:
                {
                    [usersString appendFormat:@" @%@ ", [userInfo objectForKey:@"screen_name"]];
                    break;
                }
            }
        }
        
        _textView.text = [_textView.text stringByAppendingString:usersString];
        [self updateWordCount];
        
        [_textView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
    } cancelHandler:^{
        
        [_textView becomeFirstResponder];
        
    }] autorelease];
    UINavigationController *navVC = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    
    if ([UIDevice currentDevice].isPad)
    {
        navVC.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentModalViewController:navVC animated:YES];*/
}

- (void)cancelButtonClickHandler:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
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

-(void) showShareStatusWithIndicator:(NSString*)status
{
    m_alert_view = [[UIAlertView alloc] initWithTitle:nil
                                                    message:status
                                                   delegate:nil
                                          cancelButtonTitle:nil 
                                          otherButtonTitles:nil];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    
    
    [m_alert_view show];
    
    indicator.center = CGPointMake(m_alert_view.bounds.size.width/2,  m_alert_view.bounds.size.height-40);
    [indicator startAnimating];
    [m_alert_view addSubview:indicator];
}

-(void) dismissAlert:(NSTimer *)timer{
    
    NSLog(@"release timer");
    //NSLog([[timer userInfo]  objectForKey:@"key"]);
    
    //UIAlertView *alert = [[timer userInfo]  objectForKey:@"alert"];
    [m_alert_view dismissWithClickedButtonIndex:0 animated:YES];
    
    //定时器停止使用：
    [timer invalidate];
    timer = nil;
}

- (void) publishByWeiboSDKWithText:(NSString*)text andImage:(UIImage*)image
{
    //[self showShareStatusWithIndicator:@"ttt"];
    //return;
    static Weibo* m_weibo = nil;
    if (m_weibo == nil) {
        m_weibo = [[Weibo alloc] initWithAppKey:@"568898243" withAppSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"];
    }
    
    [Weibo setWeibo:m_weibo];
    // Override point for customization after application launch.
    
    
    
    if (![Weibo.weibo isAuthenticated]) {
        
        [Weibo.weibo authorizeWithCompleted:^(WeiboAccount *account, NSError *error) {
            if (!error) {
                NSLog(@"Sign in successful: %@", account.user.screenName);
                
                [self showShareStatusWithIndicator:@"正在发布"];
                
                NSData *img = UIImagePNGRepresentation(image);
                [m_weibo newStatus:text pic:img completed:^(Status *status, NSError *error) {
                    if (error) {
                        NSLog(@"failed to upload:%@", error);
                        
                        m_alert_view.message = @"发布微博失败";
                        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                         target:self
                                                       selector:@selector(dismissAlert:)
                                                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:m_alert_view, @"alert", @"testing ", @"key" ,nil]  //如果不用传递参数，那么可以将此项设置为nil.
                                                        repeats:NO];
                    }
                    else {
                        StatusImage *statusImage = [status.images objectAtIndex:0];
                        NSLog(@"success: %lld.%@.%@", status.statusId, status.text, statusImage.originalImageUrl);
                        
                        m_alert_view.message = @"发布微博成功";
                        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                         target:self
                                                       selector:@selector(dismissAlert:)
                                                       userInfo:[NSDictionary dictionaryWithObjectsAndKeys:m_alert_view, @"alert", @"testing ", @"key" ,nil]  //如果不用传递参数，那么可以将此项设置为nil.
                                                        repeats:NO];
                    }
                    
                    if (m_weibo.isAuthenticated) {
                        [m_weibo signOut];
                    }
                }];
            }
            else {
                NSLog(@"Failed to sign in: %@", error);
            }
        }];
    }
    
    if (m_weibo.isAuthenticated) {
        NSLog(@"current user: %@", m_weibo.currentAccount.user.name);
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

- (void)publishButtonClickHandler:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    [self publishByWeiboSDKWithText:_textView.text andImage:_picImageView.image];
    return;
    
    /*NSArray *selectedClients = [_toolbar selectedClients];
    if ([selectedClients count] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"请选择要发布的平台!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"知道了"
                                                  otherButtonTitles: nil];
        [alertView show];
        return;
    }*/
    
    id<ISSContent> publishContent = [ShareSDK content:_textView.text
                                       defaultContent:nil
                                                image:[ShareSDK jpegImageWithImage:_picImageView.image quality:1]
                                                title:@"ShareSDK"
                                                  url:@"http://www.sharesdk.cn"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeText];
    
    [publishContent addQQSpaceUnitWithTitle:@"Hello QQ空间"
                                        url:INHERIT_VALUE
                                       site:nil
                                    fromUrl:nil
                                    comment:INHERIT_VALUE
                                    summary:INHERIT_VALUE
                                      image:INHERIT_VALUE
                                       type:INHERIT_VALUE
                                    playUrl:nil
                                       nswb:nil];
    [publishContent addInstapaperContentWithUrl:@"http://www.sharesdk.cn"
                                          title:@"Hello Instapaper"
                                    description:INHERIT_VALUE];
    [publishContent addYouDaoNoteUnitWithContent:INHERIT_VALUE
                                           title:@"Hello 有道云笔记"
                                          author:INHERIT_VALUE
                                          source:@"http://www.sharesdk.cn"
                                     attachments:INHERIT_VALUE];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:_appDelegate.viewDelegate];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    BOOL needAuth = NO;
    //if ([selectedClients count] == 1)
    {
        ShareType shareType = ShareTypeSinaWeibo;//[[selectedClients objectAtIndex:0] integerValue];
        if (![ShareSDK hasAuthorizedWithType:shareType])
        {
            needAuth = YES;
            [ShareSDK getUserInfoWithType:shareType
                              authOptions:authOptions
                                   result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
                                       if (result)
                                       {
                                           //分享内容
                                           [ShareSDK oneKeyShareContent:publishContent
                                                              shareList:nil
                                                            authOptions:authOptions
                                                          statusBarTips:YES
                                                                 result:nil];
                                           
                                           [self dismissModalViewControllerAnimated:YES];
                                       }
                                       else
                                       {
                                           UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                               message:[NSString stringWithFormat:@"发送失败!%@", [error errorDescription]]
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:@"知道了"
                                                                                     otherButtonTitles:nil];
                                           [alertView show];
                                       }
                                   }];
        }
    }
    
    if (!needAuth)
    {
        //分享内容
        [ShareSDK oneKeyShareContent:publishContent
                           shareList:nil
                         authOptions:authOptions
                       statusBarTips:YES
                              result:nil];
        
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)keyboardWillShowHandler:(NSNotification *)notif
{
    CGRect keyboardFrame;
    NSValue *value =[[notif userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    [value getValue:&keyboardFrame];
    
    CGFloat fixedHeight = 0;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        _keyboardHeight = keyboardFrame.size.width;
        
        int screen_width = [UIScreen mainScreen].bounds.size.width;
        int screen_height = [UIScreen mainScreen].bounds.size.height;
        
        fixedHeight = (self.height /*+ self.navigationController.navigationBar.height*/) - (screen_width - _keyboardHeight - 35);
    }
    else
    {
        _keyboardHeight = keyboardFrame.size.height;
        
        fixedHeight = _keyboardHeight - ([UIScreen mainScreen].bounds.size.height - self.height - self.navigationController.navigationBar.height - 20) / 2;
    }
    
    [UIView beginAnimations:@"change" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.15];
    
    if ([UIDevice currentDevice].isPad)
    {
        _toolbarBG.hidden = NO;
        _atTipsLabel.hidden = NO;
        _wordCountLabel.hidden = NO;
        //_keyboardHeight = keyboardFrame.size.height;
        
        _contentBG.frame = CGRectMake(PADDING_LEFT,
                                      PADDING_TOP,
                                      self.width - PADDING_LEFT - PADDING_RIGHT,
                                      self.height - TOOLBAR_HEIGHT - VERTICAL_GAP - PADDING_BOTTOM - fixedHeight);
        _toolbarBG.frame = CGRectMake(PADDING_LEFT + 1,
                                      _contentBG.bottom + VERTICAL_GAP,
                                      self.width - PADDING_LEFT - PADDING_RIGHT - 2,
                                      TOOLBAR_HEIGHT);
        
        if (_image)
        {
            _textView.frame = CGRectMake(PADDING_LEFT,
                                         PADDING_TOP + 1,
                                         _picBG.left - HORIZONTAL_GAP - PADDING_LEFT,
                                         _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT - VERTICAL_GAP - 1);
        }
        else
        {
            _textView.frame = CGRectMake(PADDING_LEFT,
                                         PADDING_TOP + 1,
                                         _contentBG.right - PADDING_RIGHT - PADDING_LEFT,
                                         _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT - VERTICAL_GAP - 1);
        }
        
        
        //_toolbar.frame = CGRectMake(_toolbarBG.left + 2, _toolbarBG.top, _toolbarBG.width - 4, _toolbarBG.height);
        
        _atButton.frame = CGRectMake(_contentBG.left + AT_BUTTON_PADDING_LEFT, _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT, AT_BUTTON_WIDTH, AT_BUTTON_HEIGHT);
        _atTipsLabel.frame = CGRectMake(_atButton.right + AT_BUTTON_HORIZONTAL_GAP,
                                        _atButton.top + (_atButton.height - _atTipsLabel.height) / 2,
                                        _atTipsLabel.width,
                                        _atTipsLabel.height);
        _wordCountLabel.frame = CGRectMake(_contentBG.right - WORD_COUNT_LABEL_PADDING_RIGHT - _wordCountLabel.width,
                                           _contentBG.bottom - WORD_COUNT_LABEL_PADDING_BOTTOM - _wordCountLabel.height,
                                           _wordCountLabel.width,
                                           _wordCountLabel.height);
    }
    else
    {
        
    }
    [UIView commitAnimations];
}

- (void)keyboardWillHideHandler:(NSNotification *)notif
{
    _keyboardHeight = 0;
    
    [UIView beginAnimations:@"change" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.15];
    
    _toolbarBG.hidden = NO;
    _atTipsLabel.hidden = NO;
    
    _contentBG.frame = CGRectMake(PADDING_LEFT,
                                  PADDING_TOP,
                                  self.width - PADDING_LEFT - PADDING_RIGHT,
                                  self.height - TOOLBAR_HEIGHT - VERTICAL_GAP - PADDING_BOTTOM - _keyboardHeight);
    _toolbarBG.frame = CGRectMake(PADDING_LEFT + 1,
                                  _contentBG.bottom + VERTICAL_GAP,
                                  self.width - PADDING_LEFT - PADDING_RIGHT - 2,
                                  TOOLBAR_HEIGHT);
    
    if (_image)
    {
        _textView.frame = CGRectMake(PADDING_LEFT,
                                     PADDING_TOP + 1,
                                     _picBG.left - HORIZONTAL_GAP - PADDING_LEFT,
                                     _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT - VERTICAL_GAP - 1);
    }
    else
    {
        _textView.frame = CGRectMake(PADDING_LEFT,
                                     PADDING_TOP + 1,
                                     _contentBG.right - PADDING_RIGHT - PADDING_LEFT,
                                     _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT - VERTICAL_GAP - 1);
    }
    
    //_toolbar.frame = CGRectMake(_toolbarBG.left + 2, _toolbarBG.top, _toolbarBG.width - 4, _toolbarBG.height);
    
    _atButton.frame = CGRectMake(_contentBG.left + AT_BUTTON_PADDING_LEFT, _contentBG.bottom - AT_BUTTON_PADDING_BOTTOM - AT_BUTTON_HEIGHT, AT_BUTTON_WIDTH, AT_BUTTON_HEIGHT);
    _atTipsLabel.frame = CGRectMake(_atButton.right + AT_BUTTON_HORIZONTAL_GAP,
                                    _atButton.top + (_atButton.height - _atTipsLabel.height) / 2,
                                    _atTipsLabel.width,
                                    _atTipsLabel.height);
    _wordCountLabel.frame = CGRectMake(_contentBG.right - WORD_COUNT_LABEL_PADDING_RIGHT - _wordCountLabel.width,
                                       _contentBG.bottom - WORD_COUNT_LABEL_PADDING_BOTTOM - _wordCountLabel.height,
                                       _wordCountLabel.width,
                                       _wordCountLabel.height);
    
    [UIView commitAnimations];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateWordCount];
}

@end
