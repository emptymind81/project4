//
//  AGCustomUserItemView.m
//  AGShareSDKDemo
//
//  Created by 冯 鸿杰 on 13-3-6.
//  Copyright (c) 2013年 vimfung. All rights reserved.
//

#import "AGCustomUserItemView.h"
#import "UIView+Common.h"

#define ICON_WIDTH 30.0
#define ICON_HEIGHT 30.0

@implementation AGCustomUserItemView

-(int) width
{
    return self.frame.size.width;
}
-(int) height
{
    return self.frame.size.height;
}

@synthesize userInfo = _userInfo;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
            imageCacheManager:(CMImageCacheManager *)imageCacheManager
                    shareType:(ShareType)shareType
                 clickHandler:(void(^)(NSMutableDictionary *userInfo))clickHandler
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _shareType = shareType;
        _imageCacheManager = imageCacheManager;
        _clickHandler = [clickHandler copy];
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - ICON_WIDTH) / 2,
                                                                       (self.height - ICON_HEIGHT) / 2,
                                                                       ICON_WIDTH,
                                                                       ICON_HEIGHT)];
        _iconImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_iconImageView];
        
        CGRect temp = _iconImageView.frame;
        
        _maskImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UserIconBG.png"]];
        _maskImageView.frame = _iconImageView.frame;
        _maskImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_maskImageView];
        
        temp = _maskImageView.frame;
    }
    return self;
}

- (void)dealloc
{
    [_loader removeAllNotificationWithTarget:self];
    _iconImageView = nil;
    

}

- (void)setUserInfo:(NSMutableDictionary *)userInfo
{
    _userInfo = userInfo;
    
    _iconImageView.image = nil;
    
    _needLayout = YES;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_needLayout)
    {
        _needLayout = NO;
        
        NSString *icon = nil;
        switch (_shareType)
        {
            case ShareTypeSinaWeibo:
            {
                id value = [_userInfo objectForKey:@"avatar_large"];
                if ([value isKindOfClass:[NSString class]])
                {
                    icon = value;
                }
                break;
            }
            case ShareTypeTencentWeibo:
            {
                id value = [_userInfo objectForKey:@"head"];
                if ([value isKindOfClass:[NSString class]] && ![value isEqualToString:@""])
                {
                    icon = [NSString stringWithFormat:@"%@/120", value];
                }
                break;
            }
            case ShareTypeTwitter:
            {
                id value = [_userInfo objectForKey:@"profile_image_url"];
                if ([value isKindOfClass:[NSString class]])
                {
                    icon = value;
                }
                break;
            }
            default:
                break;
        }
        
        [_loader removeAllNotificationWithTarget:self];
        
        _loader = [_imageCacheManager getImage:icon cornerRadius:5.0 size:_iconImageView.frame.size];
        if (_loader.state == ImageLoaderStateReady)
        {
            _iconImageView.image = _loader.content;
        }
        else
        {
            [_loader addNotificationWithName:NOTIF_IMAGE_LOAD_COMPLETE
                                      target:self
                                      action:@selector(iconLoadCompleteHandler:)];
            [_loader addNotificationWithName:NOTIF_IMAGE_LOAD_ERROR
                                      target:self
                                      action:@selector(iconLoadErrorHandler:)];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if (_clickHandler)
    {
        ((void(^)(NSDictionary *userInfo))_clickHandler)(_userInfo);
    }
}

#pragma mark - Private

- (void)iconLoadCompleteHandler:(NSNotification *)notif
{
    _iconImageView.image = _loader.content;
    
    [_loader removeAllNotificationWithTarget:self];
}

- (void)iconLoadErrorHandler:(NSNotification *)notif
{
    [_loader removeAllNotificationWithTarget:self];
}

@end
