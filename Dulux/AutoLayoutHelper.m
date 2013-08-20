//
//  AutoLayoutHelper.m
//  Dulux
//
//  Created by You Alun on 8/8/13.
//  Copyright (c) 2013 dangdang. All rights reserved.
//

#import "AutoLayoutHelper.h"

@implementation AutoLayoutHelper

+(NSLayoutConstraint*) viewEqualsToNumber:(UIView*)view number:(int)number attr:(NSLayoutAttribute)attr 
{
   NSLayoutConstraint* cn = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:attr
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1
                                                          constant:number];
   return cn;
}

+(NSLayoutConstraint*) viewEqualsToAnother:(UIView*)view another:(UIView*)another attr:(NSLayoutAttribute)attr
{
   NSLayoutConstraint* cn = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:attr
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:another
                                                         attribute:attr
                                                        multiplier:1
                                                          constant:0];
   return cn;
}

+(NSLayoutConstraint*) viewEqualsToAnother:(UIView*)view another:(UIView*)another attr:(NSLayoutAttribute)attr anotherAttr:(NSLayoutAttribute)anotherAttr
{
   NSLayoutConstraint* cn = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:attr
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:another
                                                         attribute:anotherAttr
                                                        multiplier:1
                                                          constant:0];
   return cn;
}

+(NSLayoutConstraint*) viewOffsetsToAnother:(UIView*)view another:(UIView*)another attr:(NSLayoutAttribute)attr anotherAttr:(NSLayoutAttribute)anotherAttr offset:(int)offset
{
   NSLayoutConstraint* cn = [NSLayoutConstraint constraintWithItem:view
                                                         attribute:attr
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:another
                                                         attribute:anotherAttr
                                                        multiplier:1
                                                          constant:offset];
   return cn;
}

@end
