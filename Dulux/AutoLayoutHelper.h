//
//  AutoLayoutHelper.h
//  Dulux
//
//  Created by You Alun on 8/8/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoLayoutHelper : NSObject

+(NSLayoutConstraint*) viewEqualsToNumber:(UIView*)view number:(int)number attr:(NSLayoutAttribute)attr;

+(NSLayoutConstraint*) viewEqualsToAnother:(UIView*)view another:(UIView*)another attr:(NSLayoutAttribute)attr;

+(NSLayoutConstraint*) viewEqualsToAnother:(UIView*)view another:(UIView*)another attr:(NSLayoutAttribute)attr anotherAttr:(NSLayoutAttribute)anotherAttr;

+(NSLayoutConstraint*) viewOffsetsToAnother:(UIView*)view another:(UIView*)another attr:(NSLayoutAttribute)attr anotherAttr:(NSLayoutAttribute)anotherAttr offset:(int)offset;

@end
