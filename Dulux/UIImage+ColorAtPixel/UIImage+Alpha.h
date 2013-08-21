//
//  UIImage+Alpha.h
//  ShapedButtonDemo
//
//  Created by Dreambuild on 8/21/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage(Alpha)


- (NSData *)ARGBData;
- (BOOL)isPointTransparent:(CGPoint)point;

@property NSData* argbData;

@end
