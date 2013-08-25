//
//  WeiboAuthentication.m
//  WeiboSDK
//
//  Created by Liu Jim on 8/3/13.
//  Copyright (c) 2013 openlab. All rights reserved.
//

#import "WeiboAuthentication.h"
#import "WeiboAccount.h"
#import "WeiboAccounts.h"

@implementation WeiboAuthentication


- (id)initWithAuthorizeURL:(NSString *)authorizeURL revokeAuthorizeURL:(NSString*)revokeAuthorizeURL accessTokenURL:(NSString *)accessTokenURL
                    AppKey:(NSString *)appKey appSecret:(NSString *)appSecret {
    self = [super init];
    if (self) {
        self.authorizeURL = authorizeURL;
        self.revokeAuthorizeURL = revokeAuthorizeURL;
        self.accessTokenURL = accessTokenURL;
        self.appKey = appKey;
        self.appSecret = appSecret;
        self.redirectURI = @"http://www.sharesdk.cn";
    }
    return self;
}

- (NSString *)authorizeRequestUrl {
    return [NSString stringWithFormat:@"%@?client_id=%@&response_type=code&redirect_uri=%@&display=mobile", self.authorizeURL,
            [self.appKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            [self.redirectURI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString *)revokeAuthorizeRequestUrl{
    
    NSString* access_token = [[WeiboAccounts shared]currentAccount].accessToken;
    
    return [NSString stringWithFormat:@"%@?client_id=%@&response_type=code&redirect_uri=%@&display=mobile&access_token=%@", self.revokeAuthorizeURL,
            [self.appKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            [self.redirectURI stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
            self.accessToken];
}

@end
