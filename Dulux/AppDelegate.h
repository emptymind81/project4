//
//  AppDelegate.h
//  Dulux
//
//  Created by Alun You on 8/6/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShareSDK_v2.3.1/ShareSDK.framework/Headers/ShareSDK.h"
#import "WXApi.h"
#import "WBApi.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "AGViewDelegate.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (nonatomic,readonly) AGViewDelegate *viewDelegate;

@end
