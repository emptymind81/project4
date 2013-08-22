//
//  AppDelegate.m
//  Dulux
//
//  Created by Alun You on 8/6/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "RoomViewController.h"

#import <RennSDK/RennSDK.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   /**
    注册SDK应用，此应用请到http://www.sharesdk.cn中进行注册申请。
    此方法必须在启动时调用，否则会限制SDK的使用。
    **/
   [ShareSDK registerApp:@"7779bce032c"];
   
   //如果使用服务中配置的app信息，请把初始化代码改为下面的初始化方法。
   //    [ShareSDK registerApp:@"api20" useAppTrusteeship:YES];
   
   //转换链接标记
   //    [ShareSDK convertUrlEnabled:YES];
   [self initializePlat];
   
   //如果使用服务器中配置的app信息，请把初始化平台代码改为下面的方法
   //    [self initializePlatForTrusteeship];
   
  // _interfaceOrientationMask = SSInterfaceOrientationMaskAll;
   //横屏设置
   //    [ShareSDK setInterfaceOrientationMask:UIInterfaceOrientationMaskLandscape];
   
   //监听用户信息变更
   [ShareSDK addNotificationWithName:SSN_USER_INFO_UPDATE
                              target:self
                              action:@selector(userInfoUpdateHandler:)];
   
   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
   
   RoomViewController* room_view_controller = [[RoomViewController alloc]initWithNibName:@"RoomViewController" bundle:nil];
   room_view_controller.seriIndex = 0;
   room_view_controller.roomIndex = 2;
   self.viewController = room_view_controller;
    //self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    
    self.navigationController.navigationBarHidden = true;
    //[self.navigationController setWantsFullScreenLayout:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)initializePlat
{
   /**
    连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
    http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectSinaWeiboWithAppKey:@"1181359548"
                              appSecret:@"de330123e67881dbb8941eaa377eeaf0"
                            redirectUri:@"http://dulux.com"];
   /**
    连接腾讯微博开放平台应用以使用相关功能，此应用需要引用TencentWeiboConnection.framework
    http://dev.t.qq.com上注册腾讯微博开放平台应用，并将相关信息填写到以下字段
    
    如果需要实现SSO，需要导入libWeiboSDK.a，并引入WBApi.h，将WBApi类型传入接口
    **/
   [ShareSDK connectTencentWeiboWithAppKey:@"801402304"
                                 appSecret:@"4e3f1866cbffcb3e8600c38d55bb8a2d"
                               redirectUri:@"http://dulux.com"
                                  wbApiCls:[WBApi class]];
   /**
    连接QQ空间应用以使用相关功能，此应用需要引用QZoneConnection.framework
    http://connect.qq.com/intro/login/上申请加入QQ登录，并将相关信息填写到以下字段
    
    如果需要实现SSO，需要导入TencentOpenAPI.framework,并引入QQApiInterface.h和TencentOAuth.h，将QQApiInterface和TencentOAuth的类型传入接口
    **/
   [ShareSDK connectQZoneWithAppKey:@"100371282"
                          appSecret:@"aed9b0303e3ed1e27bae87c33761161d"
                  qqApiInterfaceCls:[QQApiInterface class]
                    tencentOAuthCls:[TencentOAuth class]];
   /**
    连接网易微博应用以使用相关功能，此应用需要引用T163WeiboConnection.framework
    http://open.t.163.com上注册网易微博开放平台应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connect163WeiboWithAppKey:@"T5EI7BXe13vfyDuy"
                             appSecret:@"gZxwyNOvjFYpxwwlnuizHRRtBRZ2lV1j"
                           redirectUri:@"http://www.shareSDK.cn"];
   /**
    连接搜狐微博应用以使用相关功能，此应用需要引用SohuWeiboConnection.framework
    http://open.t.sohu.com上注册搜狐微博开放平台应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectSohuWeiboWithConsumerKey:@"SAfmTG1blxZY3HztESWx"
                              consumerSecret:@"yfTZf)!rVwh*3dqQuVJVsUL37!F)!yS9S!Orcsij"
                                 redirectUri:@"http://www.sharesdk.cn"];
   
   /**
    连接豆瓣应用以使用相关功能，此应用需要引用DouBanConnection.framework
    http://developers.douban.com上注册豆瓣社区应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectDoubanWithAppKey:@"02e2cbe5ca06de5908a863b15e149b0b"
                           appSecret:@"9f1e7b4f71304f2f"
                         redirectUri:@"http://www.sharesdk.cn"];
   
   /**
    连接人人网应用以使用相关功能，此应用需要引用RenRenConnection.framework
    http://dev.renren.com上注册人人网开放平台应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectRenRenWithAppId:@"240068"
                             appKey:@"e1834b8353e64f429eb34e4bc6288d51"
                          appSecret:@"ef502b855f50444e89fcd6a0bbaaf377"
                  renrenClientClass:[RennClient class]];
   /**
    连接开心网应用以使用相关功能，此应用需要引用KaiXinConnection.framework
    http://open.kaixin001.com上注册开心网开放平台应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectKaiXinWithAppKey:@"358443394194887cee81ff5890870c7c"
                           appSecret:@"da32179d859c016169f66d90b6db2a23"
                         redirectUri:@"http://www.sharesdk.cn/"];
   /**
    连接Instapaper应用以使用相关功能，此应用需要引用InstapaperConnection.framework
    http://www.instapaper.com/main/request_oauth_consumer_token上注册Instapaper应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectInstapaperWithAppKey:@"4rDJORmcOcSAZL1YpqGHRI605xUvrLbOhkJ07yO0wWrYrc61FA"
                               appSecret:@"GNr1GespOQbrm8nvd7rlUsyRQsIo3boIbMguAl9gfpdL0aKZWe"];
   /**
    连接有道云笔记应用以使用相关功能，此应用需要引用YouDaoNoteConnection.framework
    http://note.youdao.com/open/developguide.html#app上注册应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectYouDaoNoteWithConsumerKey:@"dcde25dca105bcc36884ed4534dab940"
                               consumerSecret:@"d98217b4020e7f1874263795f44838fe"
                                  redirectUri:@"http://www.sharesdk.cn/"];
   /**
    连接Facebook应用以使用相关功能，此应用需要引用FacebookConnection.framework
    https://developers.facebook.com上注册应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectFacebookWithAppKey:@"107704292745179"
                             appSecret:@"38053202e1a5fe26c80c753071f0b573"];
   
   /**
    连接Twitter应用以使用相关功能，此应用需要引用TwitterConnection.framework
    https://dev.twitter.com上注册应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectTwitterWithConsumerKey:@"mnTGqtXk0TYMXYTN7qUxg"
                            consumerSecret:@"ROkFqr8c3m1HXqS3rm3TJ0WkAJuwBOSaWhPbZ9Ojuc"
                               redirectUri:@"http://www.sharesdk.cn"];
   
   /**
    连接搜狐随身看应用以使用相关功能，此应用需要引用SohuConnection.framework
    https://open.sohu.com上注册应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectSohuKanWithAppKey:@"e16680a815134504b746c86e08a19db0"
                            appSecret:@"b8eec53707c3976efc91614dd16ef81c"
                          redirectUri:@"http://sharesdk.cn"];
   
   /**
    连接Pocket应用以使用相关功能，此应用需要引用PocketConnection.framework
    http://getpocket.com/developer/上注册应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectPocketWithConsumerKey:@"11496-de7c8c5eb25b2c9fcdc2b627"
                              redirectUri:@"pocketapp1234"];
   
   /**
    连接印象笔记应用以使用相关功能，此应用需要引用EverNoteConnection.framework
    http://dev.yinxiang.com上注册应用，并将相关信息填写到以下字段
    **/
   [ShareSDK connectEvernoteWithType:SSEverNoteTypeSandbox
                         consumerKey:@"sharesdk-7807"
                      consumerSecret:@"d05bf86993836004"];
   
   /**
    连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
    http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
    **/
   
   //旧版中申请的AppId（如：QQxxxxxx类型），可以通过下面方法进行初始化
   //    [ShareSDK connectQQWithAppId:@"QQ075BCD15" qqApiCls:[QQApi class]];
   
   [ShareSDK connectQQWithQZoneAppKey:@"100371282"
                    qqApiInterfaceCls:[QQApiInterface class]
                      tencentOAuthCls:[TencentOAuth class]];
   
   /**
    连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
    http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
    **/
   [ShareSDK connectWeChatWithAppId:@"wx4c060f2542dfb0bc" wechatCls:[WXApi class]];
}

/**
 *	@brief	托管模式下的初始化平台
 */
- (void)initializePlatForTrusteeship
{
   //导入QQ互联和QQ好友分享需要的外部库类型，如果不需要QQ空间SSO和QQ好友分享可以不调用此方法
   [ShareSDK importQQClass:[QQApiInterface class] tencentOAuthCls:[TencentOAuth class]];
   
   //导入人人网需要的外部库类型,如果不需要人人网SSO可以不调用此方法
   [ShareSDK importRenRenClass:[RennClient class]];
   
   //导入腾讯微博需要的外部库类型，如果不需要腾讯微博SSO可以不调用此方法
   [ShareSDK importTencentWeiboClass:[WBApi class]];
   
   //导入微信需要的外部库类型，如果不需要微信分享可以不调用此方法
   [ShareSDK importWeChatClass:[WXApi class]];
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
   return [ShareSDK handleOpenURL:url
                       wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
   return [ShareSDK handleOpenURL:url
                sourceApplication:sourceApplication
                       annotation:annotation
                       wxDelegate:self];
}

- (void)userInfoUpdateHandler:(NSNotification *)notif
{
   NSMutableArray *authList = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()]];
   if (authList == nil)
   {
      authList = [NSMutableArray array];
   }
   
   NSString *platName = nil;
   NSInteger plat = [[[notif userInfo] objectForKey:SSK_PLAT] integerValue];
   switch (plat)
   {
      case ShareTypeSinaWeibo:
         platName = @"新浪微博";
         break;
      case ShareType163Weibo:
         platName = @"网易微博";
         break;
      case ShareTypeDouBan:
         platName = @"豆瓣";
         break;
      case ShareTypeFacebook:
         platName = @"Facebook";
         break;
      case ShareTypeKaixin:
         platName = @"开心网";
         break;
      case ShareTypeQQSpace:
         platName = @"QQ空间";
         break;
      case ShareTypeRenren:
         platName = @"人人网";
         break;
      case ShareTypeSohuWeibo:
         platName = @"搜狐微博";
         break;
      case ShareTypeTencentWeibo:
         platName = @"腾讯微博";
         break;
      case ShareTypeTwitter:
         platName = @"Twitter";
         break;
      case ShareTypeInstapaper:
         platName = @"Instapaper";
         break;
      case ShareTypeYouDaoNote:
         platName = @"有道云笔记";
         break;
      default:
         platName = @"未知";
   }
   id<ISSUserInfo> userInfo = [[notif userInfo] objectForKey:SSK_USER_INFO];
   
   BOOL hasExists = NO;
   for (int i = 0; i < [authList count]; i++)
   {
      NSMutableDictionary *item = [authList objectAtIndex:i];
      ShareType type = [[item objectForKey:@"type"] integerValue];
      if (type == plat)
      {
         [item setObject:[userInfo nickname] forKey:@"username"];
         hasExists = YES;
         break;
      }
   }
   
   if (!hasExists)
   {
      NSDictionary *newItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               platName,
                               @"title",
                               [NSNumber numberWithInteger:plat],
                               @"type",
                               [userInfo nickname],
                               @"username",
                               nil];
      [authList addObject:newItem];
   }
   
   [authList writeToFile:[NSString stringWithFormat:@"%@/authListCache.plist",NSTemporaryDirectory()] atomically:YES];
}


#pragma mark - WXApiDelegate

-(void) onReq:(BaseReq*)req
{
   
}

-(void) onResp:(BaseResp*)resp
{
   
}
@end
